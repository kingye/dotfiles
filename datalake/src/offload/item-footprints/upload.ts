import * as xsenv from "@sap/xsenv";
import * as fs from "fs";
const dwcApp = fs.readFileSync("./dwc-application.json", "utf-8");
process.env.DWC_APPLICATION = dwcApp;
xsenv.loadEnv();
process.env.CF_INSTANCE_CERT = "./cf-instance-cert.pem";
process.env.CF_INSTANCE_KEY = "./cf-instance-key.pem";
import { DwcRequestContext } from "@dwc/nodejs-utils";
import { WebHdfs } from "../datalake";
import {
  Credentials,
  FootprintInventoryIdentifier,
  ODataReader,
} from "./client";
import { ANONYMIZE_MAPPING, FileStore } from "../types";
import cds from "@sap/cds";
import { Anonymizer } from "../anonymize";
import { WebHdfsWriter } from "../datalake/webhdfs";
import { KeyProviderBuilder } from "../encryption";
import {
  CredentialStoreEnvelopeEncryptionKeyProvider,
  DataEncryption,
} from "@sap/data-encryption-client-node";
const Logger = cds.log("/offload/upload");
export type UploadOptions = {
  tenant: string;
  inventory: FootprintInventoryIdentifier;
  store: FileStore;
  credentials: Credentials;
  rootDir: string;
  iv: string;
  aesKey: string;
};
export class UploadFootprint {
  private readonly aesKey: string;
  private readonly iv: string;
  private readonly tenant: string;
  private readonly inventory: FootprintInventoryIdentifier;
  private readonly store: FileStore;
  private readonly credentials: Credentials;
  private readonly rootDir: string;
  private readonly anonymizer = new Anonymizer(ANONYMIZE_MAPPING);
  private keyProvide?: CredentialStoreEnvelopeEncryptionKeyProvider;
  constructor(opts: UploadOptions) {
    this.credentials = opts.credentials;
    this.tenant = opts.tenant;
    this.inventory = opts.inventory;
    this.store = opts.store;
    this.rootDir = opts.rootDir;
    this.aesKey = opts.aesKey;
    this.iv = opts.iv;
  }
  public async init() {
    const credstore = xsenv.serviceCredentials({
      // name: "c21-sfm-credstore",
      name: "offloading-credstore",
    }) as Credentials;
    const dwcReq = await DwcRequestContext.getDwcRequestContextUsingTenantId(
      this.tenant,
    );
    console.log("DWC Request Context obtained for tenant", dwcReq);
    this.keyProvide = await new KeyProviderBuilder()
      .serviceCredentials(credstore)
      .subaccount(this.tenant)
      .build(dwcReq);
  }
  public async upload(api: string, chunkSize = 200) {
    if (!this.keyProvide) {
      throw new Error("UploadFootprint not initialized. Call init() first.");
    }
    console.time(`upload ${api}`);
    const path = `${this.rootDir}/${this.tenant}/${this.inventory.footprintInventory}-${this.inventory.periodStartDate}-${this.inventory.periodEndDate}/${api}.json`;
    // console.log("AES", this.aesKey);
    // console.log("IV", this.iv);
    // const cipher = crypto.createCipheriv("aes-256-cbc", this.aesKey, this.iv);
    const cipher = new DataEncryption().createEncryptionStream(this.keyProvide);
    const reader = new ODataReader(
      {
        credentials: this.credentials,
        rootPath: "analytics/v1/calculated-footprints",
        api,
        filter: `footprintInventory eq '${this.inventory.footprintInventory}' and periodStartDate eq ${this.inventory.periodStartDate} and periodEndDate eq ${this.inventory.periodEndDate}`,
        top: chunkSize,
      },
      (d) => {
        if (d.parentItemType === "SP") {
          d.parentItemId = this.anonymizer.anonymize(d.parentItemId);
          d.parentItemName = this.anonymizer.anonymize(d.parentItemName);
        }
        if (d.itemType === "SP") {
          d.itemId = this.anonymizer.anonymize(d.itemId);
          d.itemName = this.anonymizer.anonymize(d.itemName);
        }
        if (d.supplier) {
          d.supplier = this.anonymizer.anonymize(d.supplier);
        }
        if (d.supplierName) {
          d.supplierName = this.anonymizer.anonymize(d.supplierName);
        }
        return d;
      },
    );
    const writer = new WebHdfsWriter({
      highWaterMark: 1024 * 128,
      store: this.store,
      path,
    });
    const r = reader.pipe(cipher).pipe(writer);
    await new Promise<void>((resolve, reject) => {
      r.on("finish", () => {
        Logger.info(`Finished uploading ${api} to ${path}`);
        resolve();
      });
      r.on("error", (err) => {
        Logger.error(`Error uploading ${api} to ${path}: ${err.message}`);
        reject(err);
      });
      r.on("close", () => {
        Logger.info(`Closed uploading ${api} to ${path}`);
        resolve();
      });
    });
    Logger.info(`${api} has been uploaded to ${path}`);
    console.timeEnd(`upload ${api}`);
  }
}
(async () => {
  const datalake = new WebHdfs({
    destination: {
      name: "datalake_provider_subaccount",
      level: "provider_subaccount",
    },
  });
  const credentials = xsenv.serviceCredentials({
    name: "sfm-test-model-tenant",
  }) as Credentials;
  const credstore = xsenv.serviceCredentials({
    // name: "c21-sfm-credstore",
    name: "offloading-credstore",
  }) as Credentials;
  // const kp = await new KeyProviderBuilder()
  //   .serviceCredentials(credstore)
  //   .subaccount("fb2aa6ca-e62a-44b4-948f-c65dde39701a") // sfm-dev-eu20-goat-expfeatures
  //   // .build({
  //   //   dwcJwt:
  //   //     "eyJ0eXAiOiJKV1QiLCJqaWQiOiJSbmQ0akswZ3NTZnkwT0tKUzFjT0JaZkliUU51Ny9TYTFkOUgyWVBtRU40PSIsImFsZyI6IlJTMjU2Iiwiamt1IjoiaHR0cHM6Ly9zZm0tZGV2LWV1MjAtZ29hdC1leHBmZWF0dXJlcy5hdXRoZW50aWNhdGlvbi5ldTIwLmhhbmEub25kZW1hbmQuY29tL3Rva2VuX2tleXMiLCJraWQiOiJkZWZhdWx0LWp3dC1rZXktYzkwMTE2ZTI1ZSJ9.eyJzdWIiOiJzYi0zZDA2YTRkNS00ZjJjLTRhYjktOTZkOS1iNDRlYTFlMWIxNzchYjExNTA3OXxjMjFkZXYtMDAxIWIxMDg4MDIiLCJpc3MiOiJodHRwczovL3NmbS1kZXYtZXUyMC1nb2F0LWV4cGZlYXR1cmVzLmF1dGhlbnRpY2F0aW9uLmV1MjAuaGFuYS5vbmRlbWFuZC5jb20vb2F1dGgvdG9rZW4iLCJhdXRob3JpdGllcyI6WyJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWdoZy1kYXRhLWZvcm1zLWFwaSIsInVhYS5yZXNvdXJjZSIsImMyMWRldi0wMDEhYjEwODgwMi5jYXJib24tZGF0YS1leGNoYW5nZS1pbmJvdW5kLWZvb3RwcmludC1hZG1pbmlzdHJhdGlvbiIsImMyMWRldi0wMDEhYjEwODgwMi5jYXJib24tZGF0YS1leGNoYW5nZS1pbmJvdW5kLWltcG9ydC1hZG1pbmlzdHJhdGlvbiIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtZm9vdHByaW50LWRhdGEtYW5hbHl0aWNzLXNlcnZpY2UtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWVtaXNzaW9uLWZhY3RvcnMtcmVhZC1wdWJsaWMtYXBpIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1idXNpbmVzcy1kYXRhLXB1Ymxpc2hlciJdLCJjbGllbnRfaWQiOiJzYi0zZDA2YTRkNS00ZjJjLTRhYjktOTZkOS1iNDRlYTFlMWIxNzchYjExNTA3OXxjMjFkZXYtMDAxIWIxMDg4MDIiLCJhdWQiOlsic2ItM2QwNmE0ZDUtNGYyYy00YWI5LTk2ZDktYjQ0ZWExZTFiMTc3IWIxMTUwNzl8YzIxZGV2LTAwMSFiMTA4ODAyIiwidWFhIiwiYzIxZGV2LTAwMSFiMTA4ODAyIl0sImV4dF9hdHRyIjp7ImVuaGFuY2VyIjoiWFNVQUEiLCJzdWJhY2NvdW50aWQiOiJmYjJhYTZjYS1lNjJhLTQ0YjQtOTQ4Zi1jNjVkZGUzOTcwMWEiLCJ6ZG4iOiJzZm0tZGV2LWV1MjAtZ29hdC1leHBmZWF0dXJlcyIsInNlcnZpY2VpbnN0YW5jZWlkIjoiM2QwNmE0ZDUtNGYyYy00YWI5LTk2ZDktYjQ0ZWExZTFiMTc3In0sInppZCI6ImZiMmFhNmNhLWU2MmEtNDRiNC05NDhmLWM2NWRkZTM5NzAxYSIsImdyYW50X3R5cGUiOiJjbGllbnRfY3JlZGVudGlhbHMiLCJhenAiOiJzYi0zZDA2YTRkNS00ZjJjLTRhYjktOTZkOS1iNDRlYTFlMWIxNzchYjExNTA3OXxjMjFkZXYtMDAxIWIxMDg4MDIiLCJzY29wZSI6WyJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWdoZy1kYXRhLWZvcm1zLWFwaSIsInVhYS5yZXNvdXJjZSIsImMyMWRldi0wMDEhYjEwODgwMi5jYXJib24tZGF0YS1leGNoYW5nZS1pbmJvdW5kLWZvb3RwcmludC1hZG1pbmlzdHJhdGlvbiIsImMyMWRldi0wMDEhYjEwODgwMi5jYXJib24tZGF0YS1leGNoYW5nZS1pbmJvdW5kLWltcG9ydC1hZG1pbmlzdHJhdGlvbiIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtZm9vdHByaW50LWRhdGEtYW5hbHl0aWNzLXNlcnZpY2UtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWVtaXNzaW9uLWZhY3RvcnMtcmVhZC1wdWJsaWMtYXBpIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1idXNpbmVzcy1kYXRhLXB1Ymxpc2hlciJdLCJleHAiOjE3NjE4MTE4ODIsImlhdCI6MTc2MTgwODI4MiwianRpIjoiOTQxZWNhYzc0MDBhNDBlZWI2ZTIwZmZlOGUzNzM2NmQiLCJyZXZfc2lnIjoiMTU5OTY2M2IiLCJjaWQiOiJzYi0zZDA2YTRkNS00ZjJjLTRhYjktOTZkOS1iNDRlYTFlMWIxNzchYjExNTA3OXxjMjFkZXYtMDAxIWIxMDg4MDIifQ.m-DuhhxdVs1pSjRctUagY25tra_yUgQp6PooUo8sQ1W2jYxxzu_jM6Uo2-TkXbmhq6beQ3lBRfJZ-DAqpc6s3kQwdz6INNvAKR_eo4TmHUp-6KXEBusrqOFAvm214DkMGpgL979X0se0eJJmdE8ckzSuTiSsbjTfJufj7vsCocbiCfSfvcRrVJ1O6dsfRVDHcmtuLIodx7Yc_V4oNJcCRR8M-CvgppKTdNo0wggSG4c6fvaW0c9GnN63tqXFMfu5NHopJZ8Q2hWwnZdqD-HF73Kqx7J8P1m5HSwa7RSujADspRZDs-hBcK4Gnz2T8lqsIfcqnqWcV9W7cl6qSkiFFA",
  //   // } as DwcRequestContext);
  //   .build({
  //     dwcJwt:
  //       "eyJ0eXAiOiJKV1QiLCJqaWQiOiJ6NDQ1ekEvajVmcVkySGZUbXZER1VwYmN4aHVpSzRGSjlwWjZ3bWlBdW1VPSIsImFsZyI6IlJTMjU2Iiwiamt1IjoiaHR0cHM6Ly9zZm0tZGV2LWV1MjAtZ29hdC1leHBmZWF0dXJlcy5hdXRoZW50aWNhdGlvbi5ldTIwLmhhbmEub25kZW1hbmQuY29tL3Rva2VuX2tleXMiLCJraWQiOiJkZWZhdWx0LWp3dC1rZXktYzkwMTE2ZTI1ZSJ9.eyJzdWIiOiIyNjA4NmM1NC0xZmJlLTQ0YTItYjgxNy1jNGUxNzkxMWE3OTUiLCJ4cy51c2VyLmF0dHJpYnV0ZXMiOnt9LCJ1c2VyX25hbWUiOiJ5ZS5qaW5Ac2FwLmNvbSIsIm9yaWdpbiI6InNhcC5kZWZhdWx0IiwiaXNzIjoiaHR0cHM6Ly9zZm0tZGV2LWV1MjAtZ29hdC1leHBmZWF0dXJlcy5hdXRoZW50aWNhdGlvbi5ldTIwLmhhbmEub25kZW1hbmQuY29tL29hdXRoL3Rva2VuIiwieHMuc3lzdGVtLmF0dHJpYnV0ZXMiOnsieHMucm9sZWNvbGxlY3Rpb25zIjpbIlN1c3RhaW5hYmlsaXR5QnVzaW5lc3NTdXBwb3J0U3BlY2lhbGlzdFJDIiwiQ29uZmlndXJhdGlvbkV4cGVydFJDIiwiU3VzdGFpbmFiaWxpdHlBbmFseXN0UkMiLCJDaGllZlN1c3RhaW5hYmlsaXR5T2ZmaWNlclJDIiwiU3ViYWNjb3VudCBWaWV3ZXIiLCJTdXN0YWluYWJpbGl0eUdvdmVybmFuY2VTcGVjaWFsaXN0UkMiLCJTRk1JbnRlcm5hbFJDMDEiXX0sImNsaWVudF9pZCI6InNiLWMyMWRldi0wMDEhYjEwODgwMiIsImV4dF9hdHRyIjp7ImVuaGFuY2VyIjoiWFNVQUEiLCJzdWJhY2NvdW50aWQiOiJmYjJhYTZjYS1lNjJhLTQ0YjQtOTQ4Zi1jNjVkZGUzOTcwMWEiLCJ6ZG4iOiJzZm0tZGV2LWV1MjAtZ29hdC1leHBmZWF0dXJlcyJ9LCJ1c2VyX3V1aWQiOiJEMDMyNDU5IiwiemlkIjoiZmIyYWE2Y2EtZTYyYS00NGI0LTk0OGYtYzY1ZGRlMzk3MDFhIiwiZ3JhbnRfdHlwZSI6ImF1dGhvcml6YXRpb25fY29kZSIsImF6cCI6InNiLWMyMWRldi0wMDEhYjEwODgwMiIsInNjb3BlIjpbImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLXRyYW5zcG9ydC1vcGVyYXRpb24tZm9vdHByaW50cy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWZvb3RwcmludC1jb21tdW5pY2F0aW9uLXdyaXRlIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1pbXBvcnQtbWFzdGVyLWRhdGEtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtZ2hnLWRhdGEtY29sbGVjdGlvbi13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLXRyYW5zcG9ydC1zZXR0aW5ncy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtY2FsY3VsYXRlLXRyYW5zcG9ydC1mb290cHJpbnRzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLXRyYW5zcG9ydC1mb290cHJpbnQtdmlld2VyIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tYW5hZ2UtcHVyY2hhc2VkLXByb2R1Y3QtZm9vdHByaW50cy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtY2FyYm9uLWRhdGEtb3V0Ym91bmQtd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWNhbGN1bGF0ZS1mb290cHJpbnRzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1zdXBwbGllci1mb290cHJpbnRzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWNhbGN1bGF0ZS10cmFuc3BvcnQtZm9vdHByaW50cy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLXN1cy1mYWN0b3JzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLXZpZXctdHJhbnNwb3J0LWRhdGEiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1mb290cHJpbnQtcmVzdWx0cy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLXRyYW5zcG9ydC1zZXR0aW5ncy1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tYW5hZ2UtZm9vdHByaW50LWNvbW11bmljYXRpb24tcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtcHVyY2hhc2VkLWdvb2RzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWltcG9ydC1idXNpbmVzcy10cmFuc2FjdGlvbi1kYXRhLXJlYWQiLCJvcGVuaWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS10cmFuc3BvcnQtYWN0aXZpdGllcy1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLlN1c3RhaW5hYmlsaXR5Q29udGVudE1hbmFnZXIiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWNhcmJvbi1kYXRhLW91dGJvdW5kLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1mb290cHJpbnQtaW52ZW50b3J5LXNjb3Blcy1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1jYWxjdWxhdGUtdHJhbnNwb3J0LWZvb3RwcmludHMtbGlnaHQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS10cmFuc3BvcnQtYWN0aXZpdGllcy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLXB1cmNoYXNlZC1wcm9kdWN0LWZvb3RwcmludHMtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLXdhc3RlLWZvb3RwcmludHMtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWNhbGN1bGF0aW9uLXZhcmlhbnRzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS11bml0cy1vZi1tZWFzdXJlLXdyaXRlIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tYW5hZ2Utc3VwcGxpZXItZm9vdHByaW50cy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtdHJhbnNwb3J0LWZvb3RwcmludC1hZG1pbiIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbW9kZWwtZW5lcmd5LWZsb3dzLXdyaXRlIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tYW5hZ2Utd2FzdGUtZm9vdHByaW50cy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWVtaXNzaW9uLWZhY3RvcnMtd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLXdhc3RlLWdlbmVyYXRlZC1pbi1vcGVyYXRpb25zLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWNvcnBvcmF0ZS1iYWxhbmNlLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWFsdGVybmF0aXZlLWZ1ZWxzLXZpZXdlciIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtaW1wb3J0LWVtaXNzaW9uLWRhdGEtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtYnVzaW5lc3MtbG9nZ2luZy11aS1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tb2RlbC1lbmVyZ3ktZmxvd3MtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWFsbG9jYXRpb25zLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLXVwbG9hZGVyIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1naGctZm9ybS1kYXRhLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbnVhbC1idXNpbmVzcy1hY3Rpdml0eS1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tYW51YWwtYnVzaW5lc3MtYWN0aXZpdHktd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1mb290cHJpbnQtaW52ZW50b3J5LXNjb3Blcy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5QRk1QZXJzb25hbERhdGFNYW5hZ2VtZW50IiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tYW5hZ2UtcGxhbm5lZC1lbmVyZ3ktY29uc3VtcHRpb24tcmF0ZXMtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLXVuaXRzLW9mLW1lYXN1cmUtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtdmlldy10cmFuc3BvcnQtcm91dGUtZW1pc3Npb25zIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1pbXBvcnQtbWFzdGVyLWRhdGEtd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1kYXRhLXZpZXdlciIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtZm9vdHByaW50LW92ZXJ2aWV3LXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLXB1Ymxpc2gtcHJvZHVjdC1mb290cHJpbnRzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1wbGFubmVkLWVuZXJneS1jb25zdW1wdGlvbi1yYXRlcy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWNhbGN1bGF0aW9uLXZhcmlhbnRzLXdyaXRlIiwiYzIxZGV2LTAwMSFiMTA4ODAyLlRlbXBsYXRlVXNlciIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtZW5lcmd5LWNvbnN1bWVycy1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1wdWJsaXNoLXByb2R1Y3QtZm9vdHByaW50cy13cml0ZSIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtaW1wb3J0LWVtaXNzaW9uLWRhdGEtd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLXNjaGVkdWxlciIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtc2hpcG1lbnQtYmFzZWQtcmVwb3J0LXZpZXdlciIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtc29sZC1nb29kcy1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1tYW5hZ2UtYWxsb2NhdGlvbnMtd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWdoZy1mb3JtLWRhdGEtd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS10cmFuc3BvcnQtb3BlcmF0aW9uLWZvb3RwcmludHMtcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtY2FsY3VsYXRlLWZvb3RwcmludHMtd3JpdGUiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1lbWlzc2lvbi1mYWN0b3JzLXJlYWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLWdoZy1kYXRhLWNvbGxlY3Rpb24tcmVhZCIsImMyMWRldi0wMDEhYjEwODgwMi5jMjEtbWFuYWdlLWRhdGEtYWRtaW4iLCJjMjFkZXYtMDAxIWIxMDg4MDIuYzIxLW1hbmFnZS1mb290cHJpbnQtcmVzdWx0cy1yZWFkIiwiYzIxZGV2LTAwMSFiMTA4ODAyLmMyMS1pbXBvcnQtYnVzaW5lc3MtdHJhbnNhY3Rpb24tZGF0YS13cml0ZSJdLCJhdXRoX3RpbWUiOjE3NjE3OTI1MjYsImNuZiI6eyJ4NXQjUzI1NiI6ImNRalJsLUJYdEZRSlRiY2prQnBzNktVZjA3OHBfQ3hlTXVQZE0wQnNFekUifSwiZXhwIjoxNzYxNzk2MTI3LCJpYXQiOjE3NjE3OTI1MjcsImp0aSI6IjE1OTEzNzNiMTkyZTQ5NTA5YjJjMzVjNGQxNzI5YmU4IiwiZW1haWwiOiJ5ZS5qaW5Ac2FwLmNvbSIsImdpdmVuX25hbWUiOiJZZSIsImF1ZCI6WyJvcGVuaWQiLCJjMjFkZXYtMDAxIWIxMDg4MDIiLCJzYi1jMjFkZXYtMDAxIWIxMDg4MDIiXSwidXNlcl9pZCI6IjI2MDg2YzU0LTFmYmUtNDRhMi1iODE3LWM0ZTE3OTExYTc5NSIsImZhbWlseV9uYW1lIjoiSmluIiwicmV2X3NpZyI6IjcyYzViOTg2IiwiY2lkIjoic2ItYzIxZGV2LTAwMSFiMTA4ODAyIn0.lrz_ZLI1skmrXI7GxKyaEJCcJ9fBSj40SLqX_uPKRq370VT0lF-IrjLp7LLqY8TD9JdSqnyQFxD8LN1uYhSaKQfc-u6KZpVEVZNoXE9UGIhnGyAwEWMxAPu1md24pp2l5BcVAqyiMSrHUBxOEszQ07ubobmpGkSfdH6BZSfGHI7OMIvEElbgQVCpkz1a8Tf_nfNlfDyJlJEWZPWQM70p-dAlYshUZ7ETnQqusel2kPkkUQpWGhpSaiQcyFT0JprrDBF8TL-YFjZrUjrFkWxK9MwpdShyOvWBezKounqX6znCAGiGH7ndEnIoL6MvSuhQcZS32h8s99mPSI2ExoF_6A",
  //   } as any);
  const upload = new UploadFootprint({
    // tenant: "test-tenant-02",
    tenant: "fb2aa6ca-e62a-44b4-948f-c65dde39701a", // sfm-dev-eu20-goat-expfeatures
    inventory: {
      footprintInventory: "AL202401",
      periodStartDate: "2024-01-01",
      periodEndDate: "2024-01-31",
      // footprintInventory: "AL0125_SBTI",
      // periodStartDate: "2025-01-01",
      // periodEndDate: "2025-01-31",
    },
    store: datalake,
    credentials,
    rootDir: "/offload/footprints",
    aesKey: "12345678901234567890123456789012",
    iv: "1234567890123456",
  });
  await upload.init();
  await upload.upload("ItemFootprints");
  await upload.upload("ItemFootprintEnergyTransactions");
  await upload.upload("ItemFootprintProductTransactions");
  await upload.upload("ItemFootprintResourceTransactions");
  await upload.upload("ItemFootprintBreakdown");
  console.log("Uploaded ItemFootprints");
  process.exit(0);
})();
