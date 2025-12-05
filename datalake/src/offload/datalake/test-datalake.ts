import * as fs from "fs";
const dwcApp = fs.readFileSync("./dwc-application.json", "utf-8");
process.env.DWC_APPLICATION = dwcApp;

process.env.CF_INSTANCE_CERT = "./cf-instance-cert.pem";
process.env.CF_INSTANCE_KEY = "./cf-instance-key.pem";
import { DwcEnvContext, DwcRequestContext } from "@dwc/nodejs-utils";
import got, { Options as GotOptions, RequestError } from "got";
import { WebHdfs } from "./webhdfs";
(async () => {
  const dwcReq = await DwcRequestContext.getDwcRequestContextUsingTenantName(
    "sfm-dev-eu20-goat-expfeatures",
  );
  const megacliteurl = DwcEnvContext.getDwcMegacliteUrl();
  const url = `${megacliteurl}/config/v1/connectivity/token`;
  console.log(`megaclite url: ${megacliteurl}`);
  console.log(`token url: ${url}`);
  const { certificate, key } =
    await DwcRequestContext.mtlsCertificateCache.getInstanceCertAndKey();
  const requestOptions = {
    responseType: "json",
    resolveBodyOnly: true,
    https: {
      certificate,
      key,
    },
    headers: {
      ...dwcReq.headers,
    },
  } as GotOptions;
  try {
    const response = await got.get(url, requestOptions);
    console.log(response as any);
  } catch (e) {
    console.error((e as RequestError).message);
    console.error((e as RequestError).response?.body);
    throw new Error(
      `Retrieval of Request-Context failed with the following error: ${e}`,
    );
  }
  //megaclite-c21-dev-eu20-001.cert.cfapps.eu20-001.hana.ondemand.com/config/v1/connectivity/token

  // https: const datalake = new WebHdfs({
  //   destination: {
  //     name: "datalake_provider_subaccount",
  //     level: "provider_subaccount",
  //   },
  // });
  // const dest2 = await datalake.getCredentials();
  // console.log(dest2);

  // await datalake.create(
  //   "/test/../test-travese-dir/test1.txt",
  //   Buffer.from("Hello World", "utf-8"),
  // );
  // await datalake.create(
  //   "/test/test-dir/test2.txt",
  //   Buffer.from("Hello World2", "utf-8"),
  // );
  // // const rt = await datalake.list("/test/pipeline-env.json");
  // // console.log(JSON.stringify(rt));
  // // const rt2 = await datalake.list("/test/");
  // // console.log(JSON.stringify(rt2));
  // console.log(
  //   (await datalake.open("/test/test-dir/test1.txt")).toString("utf-8"),
  // );
  // console.log(
  //   (await datalake.open("/test/test-dir/test2.txt")).toString("utf-8"),
  // );
  // const rt = await datalake.list("/test/");
  // console.log(JSON.stringify(rt, null, 2));
  // await datalake.delete("/test/test-dir/test1.txt");
  // const rt3 = await datalake.list("/test/");
  // console.log(JSON.stringify(rt3, null, 2));
  // const rt4 = await datalake.status("/test/test-dir/test2.txt");
  // console.log(JSON.stringify(rt4, null, 2));
  // console.time("write large file");
  // await datalake.create("/test/test-dir/large-file1.json");
  // fs.openSync("./copy-large-file.json", "w");
  // // File size: 26MB. block size 1MB: totoal 59.315s, avg 2.3s per chunk
  // // File size: 26MB. block size 512KB: total 2:01.973m, avg 2.3s per chunk
  // // The speed is not much different between 512KB and 1MB, maybe the overhead is from the network latency.
  // const stream = fs.createReadStream("./large-file.json", {
  //   highWaterMark: 512 * 1024,
  // });
  // const pipeline = new Pipeline(datalake);
  // const written = await pipeline.write(
  //   stream,
  //   "/test/test-dir/large-file1.json",
  // );
  // console.timeEnd("write large file");
  // console.log(`Total length: ${written}`);
  // const rtBig = await datalake.status("/test/test-dir/large-file1.json");
  // console.log(JSON.stringify(rtBig, null, 2));

  // const out = fs.createWriteStream("./downloaded-large-file.json", {
  //   flags: "w",
  //   encoding: "binary",
  // });
  // console.time("read large file");
  // const lenRead = await pipeline.read("/test/test-dir/large-file1.json", out);
  // console.log(`Total length read: ${lenRead}`);
  // console.timeEnd("read large file");

  // const dwcCxt = await DwcRequestContext.getDwcRequestContextUsingTenantName(
  //   "sfm-dev-eu20-goat-stabledata",
  // );
  // try {
  //   const rt: any = await dwcCxt.requestToMegaclite(
  //     "get",
  //     "/v1/destination-provider/v1/destination-configuration/v2/destinations/datalake@subaccount",
  //     { responseType: "json" },
  //   );
  //   //   "get",
  //   //   "/v1/destination/v1/webhdfs/v1/test/pipeline-env.json?op=OPEN",
  //   //   {
  //   //     responseType: "json",
  //   //     headers: {
  //   //       Accept: "application/json",
  //   //       "x-sap-filecontainer": "d44d43f6-45db-42dd-8d0a-cf96d7361a33",
  //   //       "destination-name": "datalake",
  //   //     },
  //   //   },
  //   // );
  //   // console.log(rt);
  //   const buffer = Buffer.from((rt as any).certificates[0].Content, "base64");
  //   const pem = buffer.toString("utf-8");
  //   // console.log(pem);
  //   const lines = pem.split(/\r\n|\n/);
  //   const keyStart = lines.indexOf("-----BEGIN PRIVATE KEY-----");
  //   const keyEnd = lines.indexOf("-----END PRIVATE KEY-----", keyStart);
  //   const certs = lines.slice(keyEnd + 1).join("\n");
  //   const privateKey = lines.slice(keyStart, keyEnd + 1).join("\n");
  //   // const start = keyEnd;
  //   // let cert = undefined;
  //   // while (!cert) {
  //   //   const certStart = lines.indexOf("-----BEGIN CERTIFICATE-----", start);
  //   //   const certEnd = lines.indexOf("-----END CERTIFICATE-----", certStart);
  //   //   const certificate = lines.slice(certStart, certEnd + 1).join("\n");
  //   //   const pki = forge.pki.certificateFromPem(certificate);
  //   //   if (
  //   //     pki.subject.attributes.some(
  //   //       (a) => a.shortName === "CN" && a.value === "SFM",
  //   //     )
  //   //   ) {
  //   //     cert = certificate;
  //   //     console.log(pki.subject.attributes);
  //   //   }
  //   // }

  //   // console.log(privateKey);
  //   console.log(certs);
  //   const rt2 = await got(
  //     `${rt.destinationConfiguration.URL}/webhdfs/v1/test/pipeline-env.json?op=OPEN`,
  //     {
  //       method: "GET",
  //       headers: {
  //         Accept: "application/json",
  //         "x-sap-filecontainer": "d44d43f6-45db-42dd-8d0a-cf96d7361a33",
  //       },
  //       https: {
  //         certificate: certs,
  //         key: privateKey,
  //       },
  //     },
  //   );
  //   console.log(rt2.body);
  // } catch (err) {
  //   console.error(err);
  //   console.log((err as any).response.body);
  // }
})();
