import { error } from "../utils/helper";
import { AccessTokenRetriever, UaaOptions } from "./access-token";
import got from "got";
import cds from "@sap/cds";
import { Readable, ReadableOptions } from "stream";
const Logger = cds.log("/offload/itemfootprints");
export type Credentials = {
  endpoints: { apihost: string };
  uaa: UaaOptions;
};
export type Input = {
  top?: number;
  skip?: number;
  filter?: string;
};
export type Output<T = any> = {
  value: T[];
};
export class Client<I extends Input, O = any> {
  protected accessToken: AccessTokenRetriever;
  constructor(
    protected readonly credentials: Credentials,
    protected readonly rootPath: string,
    protected readonly api: string,
  ) {
    this.accessToken = new AccessTokenRetriever(credentials.uaa);
  }
  public async query(options: I): Promise<Output<O>> {
    const params: string[] = [];
    if (options.top || options.top === 0) {
      params.push(`$top=${options.top}`);
    }
    if (options.skip || options.skip === 0) {
      params.push(`$skip=${options.skip}`);
    }
    if (options.filter) {
      params.push("$filter=" + encodeURIComponent(options.filter));
    }
    const url = `${this.credentials.endpoints.apihost}/${this.rootPath}/${this.api}?${params.join("&")}`;
    const token = await this.accessToken.getAccessToken();
    Logger.debug(url);
    try {
      const res = await got
        .get(url, {
          headers: {
            Authorization: `Bearer ${token}`,
            Accept: "application/json",
          },
        })
        .json();
      return res as Output<O>;
    } catch (err) {
      throw error("Error during query ItemFootprints API", err);
    }
  }
}
export type FootprintInventoryIdentifier = {
  footprintInventory: string;
  periodStartDate: string;
  periodEndDate: string;
};

export type ODataReaderOptions = ReadableOptions & {
  credentials: Credentials;
  rootPath: string;
  api: string;
  filter?: string;
  top?: number;
};
export class ODataReader<I extends Input, O = any> extends Readable {
  private readonly client: Client<I, O>;
  private isReading = false;
  private readonly top: number;
  private queryFilter?: string;
  private skip = 0;
  private readonly transform?: (data: O) => O;
  public constructor(options: ODataReaderOptions, transform?: (data: O) => O) {
    super(options);
    this.client = new Client<I, O>(
      options.credentials,
      options.rootPath,
      options.api,
    );
    this.top = options.top ?? 1000;
    this.queryFilter = options.filter;
    this.transform = transform;
  }

  public async _read() {
    // Implementation for reading data goes here
    try {
      if (this.isReading) {
        return;
      }
      this.isReading = true;
      const r = await this.client.query({
        top: this.top,
        skip: this.skip,
        filter: this.queryFilter,
      } as I);
      if (r.value.length === 0) {
        this.push(null);
        return;
      }
      const str = r.value
        .map((item) => {
          return this.transform ? this.transform(item) : item;
        })
        .map((item) => JSON.stringify(item, null, 2))
        .join(",\n");
      this.skip += r.value.length;
      this.push(Buffer.from(str, "utf-8"));
    } catch (err) {
      this.destroy(error("Error reading from OData API", err));
    } finally {
      this.isReading = false;
    }
  }
}
