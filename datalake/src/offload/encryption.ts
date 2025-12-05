import { DwcRequestContext } from "@dwc/nodejs-utils";
import {
  CredentialStoreClient,
  CredentialStoreNamespace,
} from "@sap/credential-store-client-node";
import {
  EnvelopeEncryptionKeyProviderOptions,
  KeyringGenerateOptions,
  DefaultKeyCache,
  KeyCache,
  CredentialStoreEncryptionKeyId,
  CredentialStoreDecryptionKeyId,
  CredentialStoreEnvelopeEncryptionKeyProvider,
  DataEncryption,
} from "@sap/data-encryption-client-node";
import { name } from "mustache";

export class KeyProviderBuilder {
  private _subaccountId?: string;
  private _credentials: any;
  private _namespace?: string; // = "c21.sfm.cdd";
  private _keyring: string = "c21-sfm-footprint-offloading-keyring";
  private _keyLength: number = 32;
  private keyCache: KeyCache<
    CredentialStoreEncryptionKeyId,
    CredentialStoreDecryptionKeyId
  >;
  constructor() {
    const encryptionKeysMaxCapacity = 1000;
    const decryptionKeysMaxCapacity = 5000;
    const encryptionKeyExpiryInSec = 1800;
    const decryptionKeyExpiryInSec = 1800;
    this.keyCache = new DefaultKeyCache(
      encryptionKeysMaxCapacity,
      decryptionKeysMaxCapacity,
      encryptionKeyExpiryInSec,
      decryptionKeyExpiryInSec,
    );
  }
  public keyLength(length: number): KeyProviderBuilder {
    this._keyLength = length;
    return this;
  }
  public keyring(keyring: string): KeyProviderBuilder {
    this._keyring = keyring;
    return this;
  }
  public namespace(namespace: string): KeyProviderBuilder {
    this._namespace = namespace;
    return this;
  }
  public subaccount(tenant: string): KeyProviderBuilder {
    this._subaccountId = tenant;
    // this.namespace(tenant); // in multi-tenancy mode: platform, namespace should not be, and only in case of delete scope
    return this;
  }
  public serviceCredentials(credentials: any): KeyProviderBuilder {
    this._credentials = credentials;
    return this;
  }

  public async build(req?: DwcRequestContext) {
    if (!this._credentials) {
      throw new Error("Service credentials is not set");
    }
    const credentialStoreClient: CredentialStoreClient =
      new CredentialStoreClient(this._credentials);
    let namespace: CredentialStoreNamespace;
    if (this._namespace) {
      namespace = credentialStoreClient.getNamespace(this._namespace);
    } else if (req) {
      console.log(
        "Get namespace for platform tenant from DwcRequestContext",
        req.dwcJwt,
      );
      namespace = await credentialStoreClient.getNamespaceForPlatformTenant({
        value: req.dwcJwt!,
      });
    } else {
      throw new Error("Namespace is not set");
    }
    const keyringGenerateOptions: KeyringGenerateOptions = {
      length: this._keyLength,
      subaccountId: this._subaccountId,
    };
    const envelopeEncryptionKeyProviderOptions: EnvelopeEncryptionKeyProviderOptions =
      {
        namespace: namespace,
        keyring: `${this._keyring}`,
        keyringGenerateOptions: keyringGenerateOptions,
        keyCache: this.keyCache,
      };
    return new CredentialStoreEnvelopeEncryptionKeyProvider(
      envelopeEncryptionKeyProviderOptions,
    );
  }
}
