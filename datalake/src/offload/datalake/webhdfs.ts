import got, { Method, OptionsOfTextResponseBody } from "got";
import { DwcEnvContext, DwcRequestContext } from "@dwc/nodejs-utils";
import { error } from "../utils/helper";
import cds from "@sap/cds";
import { FileStore, FileStatus, PageOpts } from "../types";
import { Readable, ReadableOptions, Writable, WritableOptions } from "stream";
const Logger = cds.log("/offload/webhdfs");
type Destination = {
  certificates: {
    Content: string;
  }[];
  destinationConfiguration: {
    URL: string;
  };
};
type DatalakeCredentials = {
  url: string;
  cert: string;
  key: string;
  container: string;
};
const Tenants: Record<string, string> = {
  "dev-eu20-001": "sfm-dev-eu20-goat-stabledata",
};
export type DatalakeConfig = {
  destination?: {
    name?: string;
    level?:
      | "subaccount"
      | "provider_instance"
      | "provider_subaccount"
      | "instance";
  };
  tenant?: string;
};
export class WebHdfs implements FileStore {
  private credentials: DatalakeCredentials | null = null;
  private readonly destinationLevel: string;
  private readonly tenant: string;
  private readonly destinationName: string;
  constructor(config: DatalakeConfig = {}) {
    if (config.destination?.level) {
      this.destinationLevel = config.destination.level;
    } else {
      this.destinationLevel = "provider_subaccount";
    }
    if (config.tenant) {
      this.tenant = config.tenant;
    } else {
      this.tenant = WebHdfs.getTenantName();
    }
    if (config.destination?.name) {
      this.destinationName = config.destination.name;
    } else {
      this.destinationName = "datalake";
    }
  }
  public static getTenantName(): string {
    const landscape = DwcEnvContext.getDwcLandscape();
    if (!landscape) {
      throw new Error("DWC_LANDSCAPE is not set");
    }
    const t = Tenants[landscape];
    if (!t) {
      throw new Error(`No tenant mapping for landscape ${landscape}`);
    }
    return t;
  }
  public async getCredentials(): Promise<DatalakeCredentials> {
    if (this.credentials) {
      return this.credentials;
    }
    const dwcCxt = await DwcRequestContext.getDwcRequestContextUsingTenantName(
      this.tenant,
    );
    try {
      const url = `/v1/destination-provider/v1/destination-configuration/v2/destinations/${this.destinationName}@${this.destinationLevel}`;
      Logger.debug(url);
      const rt: Destination | undefined = await dwcCxt.requestToMegaclite(
        "get",
        url,
        { responseType: "json" },
      );
      if (!rt) {
        throw new Error("Failed to get destination configuration for datalake");
      }
      const buffer = Buffer.from(rt.certificates[0].Content, "base64");
      const pem = buffer.toString("utf-8");
      const lines = pem.split(/\r\n|\n/);
      const keyStart = lines.indexOf("-----BEGIN PRIVATE KEY-----");
      const keyEnd = lines.indexOf("-----END PRIVATE KEY-----");
      const certStart = lines.indexOf("-----BEGIN CERTIFICATE-----");
      const key = lines.slice(keyStart, keyEnd + 1).join("\n");
      const cert = lines.slice(certStart).join("\n");
      const containerStart = rt.destinationConfiguration.URL.indexOf("://") + 3;
      const containerEnd = rt.destinationConfiguration.URL.indexOf(
        ".",
        containerStart,
      );
      this.credentials = {
        url: rt.destinationConfiguration.URL,
        cert,
        key,
        container: rt.destinationConfiguration.URL.substring(
          containerStart,
          containerEnd,
        ),
      };
      return this.credentials;
    } catch (error) {
      throw new Error(
        `Failed to get destination configuration for datalake: ${
          (error as Error).message
        }`,
        { cause: error },
      );
    }
  }
  public checkPath(path: string) {
    if (!path.startsWith("/")) {
      throw new Error("Path must start with /");
    }
  }
  public checkDirPath(path: string) {
    this.checkPath(path);
    if (!path.endsWith("/")) {
      throw new Error("Directory path must end with /");
    }
  }
  private async buildCallOptions(
    op: string,
    path: string,
  ): Promise<{ url: string; opts: OptionsOfTextResponseBody }> {
    this.checkPath(path);
    const creds = await this.getCredentials();
    return {
      url: `${creds.url}/webhdfs/v1${path}?op=${op}`,
      opts: {
        headers: {
          Accept: "application/json",
          "x-sap-filecontainer": creds.container,
        },
        https: {
          certificate: creds.cert,
          key: creds.key,
        },
        followRedirect: true,
      },
    };
  }
  private error(op: string, path: string, err: any): Error {
    return error(`Failed to ${op} file: ${path}`, err);
  }
  public async append(path: string, data: Buffer): Promise<void> {
    this.checkPath(path);
    const opts = await this.buildCallOptions("APPEND", path);
    try {
      await got(opts.url, {
        ...opts.opts,
        method: "POST",
        headers: {
          ...opts.opts.headers,
          "Content-Type": "application/octet-stream",
        },
        body: data,
      });
    } catch (error) {
      throw this.error("append", path, error as Error);
    }
  }
  public async create(path: string, data?: Buffer): Promise<void> {
    this.checkPath(path);
    const opts = await this.buildCallOptions("CREATE", path);
    try {
      await got(opts.url, {
        ...opts.opts,
        method: "PUT",
        headers: {
          ...opts.opts.headers,
          "Content-Type": "application/octet-stream",
        },
        body: data,
      });
    } catch (error) {
      throw this.error("create", path, error as Error);
    }
  }
  public async delete(path: string): Promise<boolean> {
    this.checkPath(path);
    const opts = await this.buildCallOptions("DELETE", path);
    try {
      const rt = (await got(opts.url, {
        ...opts.opts,
        method: "DELETE",
      }).json()) as any;
      return rt.boolean;
    } catch (err) {
      throw this.error("delete", path, err as Error);
    }
  }
  public async status(path: string): Promise<FileStatus> {
    this.checkPath(path);
    const opts = await this.buildCallOptions("GETFILESTATUS", path);
    try {
      const rt = (await got(opts.url, {
        ...opts.opts,
        method: "GET",
      }).json()) as any;
      return rt.FileStatus;
    } catch (err) {
      throw this.error("status", path, err as Error);
    }
  }
  public async list(path: string): Promise<FileStatus[]> {
    const opts = await this.buildCallOptions("LISTSTATUS", path);
    try {
      const rt = (await got(opts.url, {
        ...opts.opts,
        method: "GET",
      }).json()) as any;
      return rt.FileStatuses.FileStatus;
    } catch (err) {
      throw this.error("list", path, err as Error);
    }
  }

  public async open(path: string, opts?: PageOpts): Promise<Buffer> {
    const callOpts = await this.buildCallOptions("OPEN", path);
    const url = opts
      ? `${callOpts.url}&offset=${opts.offset}&length=${opts.length}`
      : callOpts.url;
    try {
      const rt = await got(url, {
        ...callOpts.opts,
        headers: {
          ...callOpts.opts.headers,
          "Content-Type": "application/octet-stream",
        },
        method: "GET",
      }).buffer();
      return rt;
    } catch (err) {
      throw this.error("open", path, err as Error);
    }
  }
}

export type WebHdfsReaderOptions = ReadableOptions & {
  store: FileStore;
  path: string;
  blockSize?: number;
};
export class WebHdfsReader extends Readable {
  private fileSize: number | null = null;
  private currentOffset = 0;
  private readonly blockSize: number;
  private readonly store: FileStore;
  private readonly path: string;
  private isReading: boolean = false;
  constructor(opts: WebHdfsReaderOptions) {
    super({});
    this.store = opts.store;
    this.path = opts.path;
    this.blockSize = opts.blockSize ?? 512 * 1024;
  }

  async _read(): Promise<void> {
    try {
      if (this.isReading) {
        return;
      }
      this.isReading = true;
      console.log(`Fetching chunk at offset ${this.currentOffset}`);
      if (this.fileSize === null) {
        const status: FileStatus = await this.store.status(this.path);
        this.fileSize = status.length;
      }
      if (this.currentOffset >= this.fileSize) {
        console.log("No more data to read, pushing null to end the stream.");
        this.push(null);
        return;
      }
      const remaining = this.fileSize - this.currentOffset;
      const chunkLength = Math.min(this.blockSize, remaining);
      console.time(`read block at ${this.currentOffset}`);

      const buffer = await this.store.open(this.path, {
        offset: this.currentOffset,
        length: chunkLength,
      });

      console.timeEnd(`read block at ${this.currentOffset}`);
      console.log("read block length", buffer.length);
      this.currentOffset += buffer.length;
      this.push(buffer);
    } catch (err) {
      this.destroy(error("Error reading from WebHDFS", err));
    } finally {
      this.isReading = false;
    }
  }
}
export type WebHdfsWriterOptions = WritableOptions & {
  store: FileStore;
  path: string;
  update?: boolean;
  blockSize?: number;
};
export class WebHdfsWriter extends Writable {
  private readonly store: FileStore;
  private readonly path: string;
  private isWriting: boolean = false;
  private readonly create: boolean;
  private initialized: boolean = false;
  private buffer = Buffer.alloc(0);
  private readonly blockSize;
  constructor(opts: WebHdfsWriterOptions) {
    super({ ...opts, objectMode: false });
    this.store = opts.store;
    this.path = opts.path;
    this.create = opts.update ? false : true;
    this.blockSize = opts.blockSize ?? 512 * 1024;
  }
  async _write(
    chunk: any,
    encoding: BufferEncoding,
    callback: (error?: Error | null) => void,
  ): Promise<void> {
    try {
      if (this.create && !this.initialized) {
        await this.store.create(this.path);
        this.initialized = true;
      }
      this.buffer = Buffer.concat([this.buffer, chunk]);
      if (this.buffer.length >= this.blockSize) {
        const block = this.buffer.subarray(0, this.blockSize);
        await this.store.append(this.path, block);
        Logger.info(`Wrote chunk of size ${block.length} to ${this.path}`);
        this.buffer = this.buffer.subarray(this.blockSize);
      }
      callback();
    } catch (err) {
      callback(error("Error writing to WebHDFS", err));
    }
  }
  async _final(callback: (error?: Error | null) => void): Promise<void> {
    try {
      if (this.buffer.length > 0) {
        await this.store.append(this.path, this.buffer);
        Logger.info(
          `Wrote final chunk of size ${this.buffer.length} to ${this.path}`,
        );
        this.buffer = Buffer.alloc(0);
      }
      Logger.info(`Finished writing to ${this.path}`);
      callback();
    } catch (err) {
      callback(error("Error finalizing write to WebHDFS", err));
    }
  }
}
