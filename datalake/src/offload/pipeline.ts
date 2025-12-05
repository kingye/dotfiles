import { Readable, ReadableOptions, Transform } from "stream";
import { FileStatus, FileStore } from "./types";
import { error, paging } from "./utils/helper";
import { Anonymizer } from "./anonymize";
import crypto from "crypto";

export const headAndTail = (head?: string, tail?: string) => {
  let started = false;
  return new Transform({
    transform(chunk, _, callback) {
      if (!started && head) {
        this.push(head);
      }
      started = true;
      this.push(chunk);
      callback();
    },
    flush(callback) {
      if (tail) {
        this.push(tail);
      }
      callback();
    },
  });
};
export const restoreAnonymization = (anonymizer: Anonymizer) => {
  let rest: string | undefined;
  return new Transform({
    transform(chunk, _, callback) {
      try {
        const str = chunk.toString("utf-8");
        const parts = anonymizer.ensure(str);
        let toRestore = parts[0];
        if (rest) {
          toRestore = rest + parts[0];
        }
        const buffer = Buffer.from(anonymizer.restore(toRestore), "utf-8");
        rest = parts[1];
        callback(null, buffer);
      } catch (err) {
        callback(error("Error restoring anonymization", err));
      }
    },
    flush(callback) {
      if (rest) {
        const buffer = Buffer.from(anonymizer.restore(rest), "utf-8");
        rest = undefined;
        this.push(buffer);
      }
      callback();
    },
  });
};

// export const decrypt = (aesKey: string, iv: string) => {
//   console.log("AES", aesKey);
//   console.log("IV", iv);
//   const decipher = crypto.createDecipheriv("aes-256-cbc", aesKey, iv);
//   decipher.setAutoPadding(true);
//   return new Transform({
//     transform(chunk, _, callback) {
//       try {
//         console.log("to decipher");
//         let decrypted: Buffer | null;
//         if (chunk !== null) {
//           decrypted = decipher.update(chunk);
//           // console.log(decrypted.toString());
//           this.push(decrypted);
//         }
//         callback();
//       } catch (err) {
//         callback(err as Error);
//       }
//     },
//     flush(callback) {
//       try {
//         console.log("final");
//         this.push(decipher.final());
//         callback();
//       } catch (err) {
//         callback(err as Error);
//       }
//     },
//   });
// };
// export const encrypt = (aesKey: string, iv: string) => {
//   console.log("AES", aesKey);
//   console.log("IV", iv);
//   const cipher = crypto.createCipheriv("aes-256-cbc", aesKey, iv);
//   cipher.setAutoPadding(true);
//   return new Transform({
//     transform(chunk, _, callback) {
//       try {
//         console.log("to cipher");
//         let encrypted: Buffer | null;
//         if (chunk !== null) {
//           encrypted = cipher.update(chunk);
//           //  console.log(encrypted.toString("hex"));
//           this.push(encrypted);
//         }
//         callback();
//       } catch (err) {
//         callback(err as Error);
//       }
//     },
//     flush(callback) {
//       try {
//         console.log("final");
//         this.push(cipher.final());
//         callback();
//       } catch (err) {
//         callback(err as Error);
//       }
//     },
//   });
// };
