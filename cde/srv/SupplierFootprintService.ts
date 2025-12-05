import cds, { ApplicationService, Request } from "@sap/cds";
import { SupplierFootprintInput, SupplierFootprintOutput } from "cds-models";
export class SupplierFootprintService extends ApplicationService {
  init() {
    cds.log("init").info("Initializing SupplierFootprintService");
    // this.on("push", this.push); // with on must use static
    return super.init();
  }
  async push(
    req: SupplierFootprintInput[],
  ): Promise<SupplierFootprintOutput[]> {
    cds.log("push").info("Received push request for supplier footprints");
    console.log(req);
    // req.reply("Accepted for processing");
    const footprints = req;
    // Implement your logic to handle the pushed supplier footprints here
    return footprints.map((footprint) => ({
      id: footprint.id,
      status: "OK",
    }));
  }
}
// module.exports = SupplierFootprintService;
