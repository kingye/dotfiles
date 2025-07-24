import {
    AllOrNoneFieldFilledCheck,
    CheckMessage,
    CheckResult,
    CodeCheck,
    DateCheck,
    MandatoryFieldCheck,
    PeriodFromBeforeToCheck,
    runner,
    StandardCheckResult
} from "@suma/c21-sfm-reuse-lib/validity";

import { Service } from "@sap/cds/apis/services";
import { entity } from "@sap/cds/apis/csn";
import { Importer, ImportOptions, ImportResponse, ImportStatus, MessageType, RequestInformation } from "@sap/generic-import";
import cds, { Request } from "@sap/cds";
import { CheckErrorType } from "../checks/types";
import {
    Co2eQuantityCheck,
    DecimalCheck,
    MandatoryAndEmissionFactorCheck,
    ProductAndProductGroupCheck,
    ProductGroupRelatedCheck,
    ProductRelatedCheck
} from "../checks/ImportCheck";
import { Constants } from "@suma/c21-sfm-reuse-lib/common";
import { HelperUtil } from "@suma/c21-sfm-reuse-lib/helper";
import { PpfOverlppingAmongEachOtherCheck } from "../checks/PpfOverlappingAmongEachOtherCheck";
import { PurchasedProductFootprintUnitConversions } from "../common/PurchasedProductFootprintUnitConversions";
import { buildConverter, convertMessages, persistPPFs, setMissingCarbonDistributions, ToPersist } from "./ImportUtil";
import { QuantityAndUoMCheck } from "../checks/QuantityAndUoMCheck";
import { ExtendedPurchasedProductFootprint, PurchasedProductFootprint } from "../types";
import _ from "lodash";
import { EmissionFactorAssignmentImpl } from "./EmissionFactorAssignmentImpl";

import { PurchaseProuctFootPrintsMasterDataCheck } from "../checks/PurchaseProuctFootPrintsMasterDataCheck";
import { invalidateProposedPpfBeforeHandler } from "../proposal/InvalidatePurchasedProposedProductFootprints";
import { collectUsageOnIFRS } from "../release/ReleasePurchasedProductFootprints";
import { collectOtelCounterHandler, collectOtelGaugeHandler } from "../common/helper";
import { AdjustValidityForPurchasedProductFootprintExcelImport } from "./AdjustValidityForPurchasedProductFootprintExcelImport";
const LoggerPath = "PPFImpoft";
type StepResult<T> = {
    data: T[];
    checkResult: CheckResult;
};
type StepFn<T, O = T> = (data: T[], offset: number) => Promise<StepResult<O>>;
const MESSAGE_CHECK_LIMIT = 500;
const CHUNK_SIZE = 3000;
export default class PurchasedProductFootprintImporter extends Importer {
    private req: RequestInformation;
    private productCheck = new PurchaseProuctFootPrintsMasterDataCheck(Constants.MasterDataEntities.Products, {
        field: "Product_identifier",
        messages: {
            invalid: CheckErrorType.ProductNotFound,
            inconsistent: CheckErrorType.ProductInconsistent
        }
    });
    private supplierCheck = new PurchaseProuctFootPrintsMasterDataCheck(Constants.MasterDataEntities.Suppliers, {
        field: "Supplier_identifier",
        messages: {
            invalid: CheckErrorType.SupplierNotFound,
            inconsistent: CheckErrorType.SupplierInconsistent
        }
    });
    private plantsCheck = new PurchaseProuctFootPrintsMasterDataCheck(Constants.MasterDataEntities.Plants, {
        field: "Plant_identifier",
        messages: {
            invalid: CheckErrorType.PlantNotFound,
            inconsistent: CheckErrorType.PlantInconsistent
        }
    });

    private productGroupCheck = new PurchaseProuctFootPrintsMasterDataCheck(Constants.MasterDataEntities.ProductGroups, {
        field: "ProductGroup_identifier",
        messages: {
            invalid: CheckErrorType.ProductGroupNotFound,
            inconsistent: CheckErrorType.ProductGroupInconsistent
        }
    });
    constructor(srv: Service, entity: entity, options: ImportOptions, req: RequestInformation) {
        super(srv, entity, options);
        this.req = req;
    }

    public raiseError(checkResult: CheckResult | undefined) {
        if (checkResult && checkResult.messages.length > 0) {
            checkResult.messages.forEach((message) => {
                super.addMessage({
                    message: message.message,
                    parameter: message.arguments,
                    type: MessageType.Error,
                    index: message.index
                });
            });
            throw new Error(JSON.stringify(Object.values(this.context.messages)));
        }
    }
    public async step<T, O>(name: string, data: T[], processor: StepFn<T, O>): Promise<O[]> {
        const logger = cds.log(`${LoggerPath}/${name}`);
        const chunks = _.chunk(data, CHUNK_SIZE); // Adjust chunk size as needed
        const results = [] as O[];
        const checkResults = new StandardCheckResult();
        logger.info("start to process in chunks");
        let rowOffset = 0;
        for (let i = 0; i < chunks.length; i++) {
            logger.info(`Processing chunk ${i + 1} of ${chunks.length}`);
            const result = await processor(chunks[i], rowOffset);
            checkResults.messages.push(...result.checkResult.messages);
            if (checkResults.messages.length > MESSAGE_CHECK_LIMIT) {
                logger.warn(`Check messages exceeded limit of ${MESSAGE_CHECK_LIMIT}, stopping further checks.`);
                break;
            }
            results.push(...result.data);
            rowOffset += chunks[i].length;

            // wait 10ms to avoid blocking the event loop
            await new Promise((resolve) => setTimeout(resolve, 10));
        }
        checkResults.sort();
        this.raiseError(checkResults);
        return results;
    }
    private prepare: StepFn<ExtendedPurchasedProductFootprint> = async (chunk, offset) => {
        const converter = await buildConverter(chunk);
        this.productCheck.clearBuffer();
        this.supplierCheck.clearBuffer();
        this.plantsCheck.clearBuffer();
        this.productGroupCheck.clearBuffer();
        await this.productCheck.prepare(chunk);
        await this.supplierCheck.prepare(chunk);
        await this.plantsCheck.prepare(chunk);
        await this.productGroupCheck.prepare(chunk);
        const dataWithID = chunk.map((d) => {
            return {
                ...d,
                Product_ID: this.productCheck.get(d)?.ID,
                Supplier_ID: this.supplierCheck.get(d)?.ID,
                Plant_ID: this.plantsCheck.get(d)?.ID,
                // if product_identifier is filled, then it means the reocord is in product level, set ProductGroup_identifier null
                ProductGroup_ID: HelperUtil.isNotEmpty(d.Product_identifier) ? null : this.productGroupCheck.get(d)?.ID,
                ProductGroup_identifier: HelperUtil.isNotEmpty(d.Product_identifier) ? null : d.ProductGroup_identifier
            };
        });
        const results = await this.preCheck(dataWithID, offset, converter);

        return { data: dataWithID as ExtendedPurchasedProductFootprint[], checkResult: results };
    };

    async preCheck(
        data: Array<ExtendedPurchasedProductFootprint>,
        rowOffset: number,
        converter?: PurchasedProductFootprintUnitConversions | undefined
    ): Promise<CheckResult> {
        return runner(
            [
                new ProductAndProductGroupCheck(),
                new CodeCheck("sap.sme.bem.common.codelists.PurchasedProductUoMSource", {
                    name: "uomSource_code",
                    message: CheckErrorType.InvalidUoMSourceCode
                }),
                new CodeCheck(Constants.CodeLists.CalculationMethodCodes, {
                    name: "calculationMethod_code",
                    message: CheckErrorType.CalculationMethodNotFound
                }),
                new CodeCheck(Constants.CodeLists.CurrencyCodes, {
                    name: "spendBasedCurrency_code",
                    message: CheckErrorType.SpendBasedCurrencyNotFound
                }),
                new DecimalCheck([
                    { name: "co2eQuantity", message: "invalidCo2eQuantity" },
                    { name: "productQuantity", message: "invalidProductQuantity" },
                    { name: "spendBasedAmount", message: "invalidSpendBasedAmount" }
                ]),
                new AllOrNoneFieldFilledCheck({
                    fields: ["validityPeriod_validFrom", "validityPeriod_validTo"],
                    message: "missingValidityPeriod"
                }),
                new DateCheck({
                    name: "validityPeriod_validFrom",
                    message: "invalidPeriodFrom"
                }),
                new DateCheck({
                    name: "validityPeriod_validTo",
                    message: "invalidPeriodTo"
                }),
                new PeriodFromBeforeToCheck(),
                //efm 3 columns check
                new AllOrNoneFieldFilledCheck({
                    fields: ["packageID", "packageVersion", "dataSetSourceID"],
                    message: "emissionFactorReferenceNotComplete"
                }),
                new MandatoryAndEmissionFactorCheck(),
                new MandatoryFieldCheck([{ name: "calculationMethod_code", message: CheckErrorType.CalculationMethodEmpty }]),
                new ProductRelatedCheck(this.productCheck, this.supplierCheck, this.plantsCheck, converter),
                new ProductGroupRelatedCheck(this.productGroupCheck)
            ],
            {
                rowOffset,
                logger: cds.log(`${LoggerPath}/prepare/preCheck`)
            }
        ).checkAll(data as any, true);
    }

    async postCheck(data: Array<ExtendedPurchasedProductFootprint>, rowOffset: number): Promise<CheckResult> {
        // the check is necessary if no efm assigned or prduct quantity is < 0 during efm assignment
        return runner([new QuantityAndUoMCheck(), new Co2eQuantityCheck()], {
            rowOffset,
            logger: cds.log(`${LoggerPath}/postCheck`)
        }).checkAll(data);
    }
    public enrichData(data: Array<ExtendedPurchasedProductFootprint>) {
        return data
            .map((p) => {
                return {
                    ...p,
                    releaseStatus_code: "RELEASED",
                    efUpdateStatus_code: null,
                    co2eQuantityUoM_code: Constants.CO2eUoM.Kilogram,
                    inputMethod_code: Constants.PurchasedProductFootprintInputMethodCodes.FileImport,
                    CarbonDistributions: setMissingCarbonDistributions(p, this.req),
                    valuationLevel_code:
                        p.Supplier_identifier && p.Product_identifier
                            ? Constants.PurchasedProductFootprintValuationLevel.Supplier
                            : Constants.PurchasedProductFootprintValuationLevel.Product
                };
            })
            .map((d) => _.omit(d, ["Product_identifier", "ProductGroup_identifier", "Supplier_identifier", "Plant_identifier"]));
    }

    async adjustValidity(data: Array<PurchasedProductFootprint>, indexOffset: number): Promise<{ toPersist: ToPersist; adjustCheckResult: CheckResult }> {
        const adjustValidityForExcelImport = new AdjustValidityForPurchasedProductFootprintExcelImport(indexOffset);
        //const adjustValidityForExcelImport = new AdjustValidityForSPurchasedProductFootprintExcelImportByIdentifier(indexOffset);
        return adjustValidityForExcelImport.adjust(data as Array<PurchasedProductFootprint>);
    }

    public async run(data: Record<string, unknown>[]): Promise<ImportResponse> {
        const logger = cds.log(LoggerPath);
        logger.info(`start to preprocess for import`);
        try {
            collectOtelCounterHandler("PPF_FILEUPLOAD_ITEMS", "Itmes of upload PPF files", "1", (req) => req.data?.ppfToImport?.length ?? 0);
            collectOtelCounterHandler("PPF_FILEUPLOAD_FILES", "number of PPF upload files", "1", () => 1);
        } catch (e) {
            const exceptionResult = convertMessages(e as Error);
            this.raiseError(exceptionResult);
        }
        /********* run in trunk **********************/
        // prepare and preCheck
        const dataWithID = await this.step("prepare", data, this.prepare.bind(this));

        // call api to retrieve ef and assgin to ppf
        const dataWithEfm = await this.step("retrieveEmissionFactor", dataWithID, async (chunk, offset) => {
            const assignment = new EmissionFactorAssignmentImpl(`${LoggerPath}/retrieveEmissionFactor`, this.req as Request);
            return assignment.run(chunk, offset);
        });
        /********* end run in trunk **********************/

        // check wo chunk
        logger.info(`Step4: check overlapping within excel`);
        const overlappingCheckResult = await runner([new PpfOverlppingAmongEachOtherCheck()], {
            logger: cds.log(`${LoggerPath}/overlappingCheck`)
        }).checkAll(
            dataWithEfm.map((d, index) => {
                return {
                    ...d,
                    ID: `${index}` // for overlapping check purpose
                };
            }),
            true
        );
        this.raiseError(overlappingCheckResult);

        /********* run in trunk **********************/
        const postCheckData = await this.step("postCheck", dataWithEfm, async (chunk, offset) => {
            // postCheck: check quantity and uom
            const postCheckResult = await this.postCheck(chunk as Array<ExtendedPurchasedProductFootprint>, offset);
            // enrich data
            const enrichData = this.enrichData(chunk as Array<ExtendedPurchasedProductFootprint>);
            // adjust validity period
            const { toPersist, adjustCheckResult } = await this.adjustValidity(enrichData as PurchasedProductFootprint[], offset);
            adjustCheckResult.messages.forEach((message) => {
                postCheckResult.add(message);
            });

            return { data: [toPersist], checkResult: postCheckResult };
        });
        /********* end run in trunk **********************/

        const toPersist: ToPersist = postCheckData.reduce(
            (r, current) => {
                r.ppfToInsert.push(...current.ppfToInsert);
                r.ppfToUpdate.push(...current.ppfToUpdate);
                return r;
            },
            { ppfToInsert: [], ppfToUpdate: [] } as ToPersist
        );

        // persist
        logger.info(`Step8: preprocess for import finished, handover to generic import`);
        await persistPPFs(this.req as any, LoggerPath, toPersist);

        // post persist
        logger.info(`Step9: post persist`);
        (this.req as any).data = toPersist;
        try {
            await invalidateProposedPpfBeforeHandler(this.req as any);
            collectUsageOnIFRS(this.req as any);
            collectOtelCounterHandler("PPF_FILEUPLOAD_FILES_SUCCESS", "Number of successfully uploaded PPF files", "1", () => 1);
            collectOtelGaugeHandler(
                "PPF_FILEUPLOAD_RATE",
                "Amount of uploaded PPFs per second",
                "ppfs/s",
                (req) => (req.data.ppfToImport?.length ?? 0) / ((Date.now() - req.timestamp.getTime()) / 1000)
            );
        } catch (e) {
            const exceptionResult = convertMessages(e as Error);
            this.raiseError(exceptionResult);
        }

        return {
            status: ImportStatus.Success, // Return a dummy success response as the return type is mandatory
            messages: []
        };
        //return super.run([] as any);
    }
}
