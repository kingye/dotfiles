import express, { Request, RequestHandler } from "express";
import path from "path";
import fs from "fs";
const dwcApp = fs.readFileSync("./dwc-application.json", "utf-8");
process.env.DWC_APPLICATION = dwcApp;

process.env.CF_INSTANCE_CERT = "./cf-instance-cert.pem";
process.env.CF_INSTANCE_KEY = "./cf-instance-key.pem";
import { WebHdfs } from "./webhdfs";
import { downloadFile, fileStatus, listDir, RequestContext } from "./handlers";
import { ANONYMIZE_MAPPING, FileStatus } from "../types";
import { link } from "fs/promises";
import { Anonymizer } from "../anonymize";
const app = express();
const datalake = new WebHdfs({
  destination: {
    name: "datalake_provider_subaccount",
    level: "provider_subaccount",
  },
});
app.get(
  /^\/datalake\/(.*)$/,
  async (req: RequestContext, res, next) => {
    req.fullPath = `/${req.params[0]}`;
    console.log(`Request for path: ${req.fullPath}`);
    next();
  },
  fileStatus(datalake),
  listDir(datalake),
  downloadFile(
    datalake,
    new Anonymizer(ANONYMIZE_MAPPING),
    "12345678901234567890123456789012",
    "1234567890123456",
  ),
);
app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
