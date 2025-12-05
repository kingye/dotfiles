import { DwcRequestContext } from "@dwc/nodejs-utils";
import fs from "fs";
(async () => {
  const dwcApp = fs.readFileSync("./dwc-application.json", "utf-8");
  process.env.DWC_APPLICATION = dwcApp;
  console.log(process.env.DWC_APPLICATION);
  process.env.CF_INSTANCE_CERT = "./cf-instance-cert.pem";
  process.env.CF_INSTANCE_KEY = "./cf-instance-key.pem";
  const req = await DwcRequestContext.getDwcRequestContextUsingTenantName(
    "c21-dev-eu20-phoenix-stabledata",
  );
  const url = `/v1/saas-registry-cc/v1/saas-manager/v1/application/subscriptions`;
  console.log("Requesting URL:", url);
  let currentPage = 1;
  let pageSize = 10;
  let totalPages = 1;
  let result: any[] = [];
  while (currentPage <= totalPages) {
    console.log(`reading page ${currentPage}`);
    const rt = (await req.requestToMegaclite(
      "get",
      `${url}?page=${currentPage}&size=${pageSize}`,
      {
        responseType: "json",
      },
    )) as any;

    if (!rt) {
      throw new Error("Failed to get destination configuration for datalake");
    }
    console.log(JSON.stringify(rt, null, 2));
    result.push(...rt.subscriptions);
    totalPages = rt.totalPages;
    currentPage++;
  }
  console.log("subscriptions", JSON.stringify(result, null, 2));
  console.log("length:", result.length);
})();
