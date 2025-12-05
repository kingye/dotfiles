import * as xsenv from "@sap/xsenv";
import { Handler, NextFunction, Request, Response } from "express";
import { WebHdfsReader } from "./webhdfs";
import path from "path";
import { FileStatus, FileStore } from "../types";
import { headAndTail, restoreAnonymization } from "../pipeline";
import crypto from "crypto";
import cds from "@sap/cds";
import { Anonymizer } from "../anonymize";
import { KeyProviderBuilder } from "../encryption";
import { DataEncryption } from "@sap/data-encryption-client-node";
const Logger = cds.log("/offload/datalake/server");
export type RequestContext = Request & {
  fileStatus?: FileStatus;
  fullPath?: string;
};

type HandlerFunc = (
  req: RequestContext,
  res: Response,
  next: NextFunction,
) => void | Promise<void>;

export const downloadFile =
  (
    datalake: FileStore,
    anonymizer: Anonymizer,
    aesKey: string,
    iv: string,
  ): HandlerFunc =>
  async (req, res, next) => {
    // const decipher = decrypt(aesKey, iv);
    if (!req.fileStatus || !req.fullPath) {
      next("file path cannot be undefined");
      return;
    }
    if (req.fileStatus.type !== "FILE") {
      Logger.info(`${req.fullPath} is not a file, skip downloading`);
      next();
      return;
    }
    const tenant = req.fullPath.split("/").reverse()[2];
    console.log("read file for Tenant", tenant);
    const credstore = xsenv.serviceCredentials({
      // name: "c21-sfm-credstore",
      name: "offloading-credstore",
    });
    const keyProvide = new KeyProviderBuilder()
      .serviceCredentials(credstore)
      .subaccount(tenant)
      .build();
    // const decipher = crypto.createDecipheriv("aes-256-cbc", aesKey, iv);
    const decipher = new DataEncryption().createDecryptionStream([keyProvide]);
    // res.setHeader("Content-Type", "application/octet-stream");
    res.setHeader("Content-Type", "application/json");
    res.setHeader("Transfer-Encoding", "chunked");
    const filename = path.basename(req.fullPath);
    // res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
    let pipeline;
    console.log(req.query);
    const input = new WebHdfsReader({
      store: datalake,
      path: req.fullPath,
    });
    if (req.query["restore"] === "true") {
      input.pipe(decipher).pipe(restoreAnonymization(anonymizer)).pipe(res);
    } else if (req.query["raw"] === "true") {
      input.pipe(res);
    } else {
      input.pipe(decipher).pipe(headAndTail('{"value": [\n', "\n]}")).pipe(res);
    }
    input.on("error", (err) => res.status(500).end("Error: " + err.message));
    res.on("finish", () => console.log("Response sent."));
    // input.on("end", () => {
    //   res.end();
    // });
  };
export const listDir =
  (datalake: FileStore): HandlerFunc =>
  async (req, res, next) => {
    if (!req.fileStatus || !req.fullPath) {
      next("file path cannot be undefined");
      return;
    }
    if (req.fileStatus.type !== "DIRECTORY") {
      Logger.info(`${req.fullPath} is not a directory, skip ls`);
      next();
      return;
    }
    const list = await datalake.list(req.fullPath);
    let rt = "<html><body>";
    const parentHref = path.posix.join(
      "/datalake",
      path.posix.dirname(req.fullPath),
    );
    rt = rt.concat(`<div><a href="${parentHref}">..</a></div>`);
    for (const l of list) {
      const href = path.posix.join("/datalake", req.fullPath, l.pathSuffix);
      rt = rt.concat(
        `<div><a href="${href}">${l.pathSuffix}</a> (${l.type}, ${l.length} bytes) <a href="${href}?restore=true">restored</a> <a href="${href}?raw=true">raw</a></div>`,
      );
    }
    rt = rt.concat("</body></html>");
    res.setHeader("Content-Type", "text/html");
    res.send(rt);
  };
export const fileStatus =
  (datalake: FileStore): HandlerFunc =>
  async (req, res, next) => {
    if (!req.fullPath) {
      next("file path cannot be undefined");
      return;
    }
    if (req.fullPath.includes("..")) {
      res.status(400).send("Invalid path");
      return;
    }
    const stats = await datalake.status(req.fullPath);
    req.fileStatus = stats;
    next();
  };
