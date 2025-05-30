process.env.CDS_TYPESCRIPT = "true";
process.env.NO_DEMODATA = "true";
process.env.SDF_LOCAL = "true";

import cds from "@sap/cds";
// import dataLoader from "./data-loader";
// import moment from "moment";

(cds as any).env.i18n.for_sqlite = [];

process.env.OTEL_OFF = "true";
const cdsTest = (cds as any).test.in(__dirname, "..", "..").run("serve");
(globalThis as any).__cdsTest__ = cdsTest;

// const logger = console.log;
// let messages: Array<Array<any>> = [];
// function collect(...data: Array<any>) {
//     messages.push(data);
// }
//
// beforeEach(async () => {
//     const testName = expect.getState().currentTestName;
//     logger(`\x1b[34m >>> [${moment().format("HH:MM:ss.SSS")}] running: ${testName}`);
//
//     // The console methods will be resetted after each test
//     console.trace = collect;
//     console.debug = collect;
//     console.log = collect;
//     console.info = collect;
//     console.warn = collect;
//     console.error = collect;
//     messages = [];
// });
//
// afterEach(async () => {
//     const state = expect.getState();
//
//     const testName = state.currentTestName;
//     if (state.assertionCalls === state.numPassingAsserts) {
//         logger(`\x1b[32m >>> [${moment().format("HH:MM:ss.SSS")}] success: ${testName}`);
//     } else {
//         messages.forEach((message) => {
//             logger(...message);
//         });
//         logger(`\x1b[31m >>> [${moment().format("HH:MM:ss.SSS")}] error: ${testName}`);
//     }
// });
//
// dataLoader.init();

{{{tests}}}
