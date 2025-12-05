import got from "got";
import https from "https";
export enum MimeTypes {
  JSON = "application/json",
  X_WWW_FORM_URLENCODED = "application/x-www-form-urlencoded",
}
export type UaaOptions = {
  url: string;
  clientid: string;
  clientsecret?: string;
  certificate?: string;
  key?: string;
  certurl?: string;
};
export class AccessTokenRetriever {
  private accessToken?: string;
  constructor(private readonly options: UaaOptions) {}
  /**
   * validate the access token
   * @returns false if the access token has less than 5 minutes before it expires
   */
  private validateAccessToken(): boolean {
    if (!this.accessToken) {
      return false;
    }
    const expiryTime = JSON.parse(
      Buffer.from(this.accessToken.split(".")[1], "base64").toString("utf8"),
    ).exp;
    return expiryTime - Date.now() / 1000 >= 5 * 60; // access token should be still valid in five minutes
  }

  /**
   * fetchAccessToken from uaa based on the service credetials
   */
  private async fetchAccessToken(): Promise<string> {
    let response;
    if (this.options.certurl && this.options.certificate && this.options.key) {
      response = (await got(
        `${this.options.certurl}/oauth/token?grant_type=client_credentials&client_id=${this.options.clientid}`,
        {
          method: "POST",
          headers: {
            "Content-Type": MimeTypes.X_WWW_FORM_URLENCODED,
            Accept: MimeTypes.JSON,
          },
          https: {
            certificate: this.options.certificate,
            key: this.options.key,
          },
        },
      ).json()) as any;
    } else {
      response = (await got(
        `${this.options.url}/oauth/token?grant_type=client_credentials&token_format=jwt`,
        {
          method: "POST",
          headers: {
            "Content-Type": MimeTypes.X_WWW_FORM_URLENCODED,
            Accept: MimeTypes.JSON,
          },
          username: this.options.clientid,
          password: this.options.clientsecret!,
        },
      ).json()) as any;
    }
    if (!response || !response.access_token) {
      throw new Error("Access Token cannot be granted");
    }
    return response.access_token as string;
  }

  public async getAccessToken(): Promise<string> {
    if (!this.accessToken || !this.validateAccessToken()) {
      this.accessToken = await this.fetchAccessToken();
    }
    return this.accessToken;
  }
}
