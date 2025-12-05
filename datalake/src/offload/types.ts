export type FileStatus = {
  pathSuffix: string;
  type: "FILE" | "DIRECTORY";
  length: number;
  owner: string;
  group: string;
  permission: string;
  accessTime: number;
  blockSize?: number;
  replication?: number;
  eTag?: string;
  modificationTime: number;
};
export type PageOpts = {
  offset: number;
  length: number;
};
export interface FileStore {
  append(path: string, data: Buffer): Promise<void>;
  create(path: string, data?: Buffer): Promise<void>;
  delete(path: string): Promise<boolean>;
  status(path: string): Promise<FileStatus>;
  list(path: string): Promise<FileStatus[]>;
  open(path: string, opts?: PageOpts): Promise<Buffer>;
}
export interface Offload {
  upload(): Promise<void>;
  download(write: WritableStream): Promise<void>;
}

export const ANONYMIZE_MAPPING = {
  anonym1: "ALSU504",
  anonym2: "Finest Cocoa Corp",
  anonym3: "ALSU506",
  anonym4: "World of Cakes",
  anonym5: "ALSU501",
  anonym6: "Mayer Foods",
  anonym7: "ALSU503",
  anonym8: "Cocoa World",
  anonym9: "ALSU502",
  anonym10: "Malmer GmbH",
  anonym11: "ALSU508",
  anonym12: "Bauhaus Online",
  anonym13: "ALSU505",
  anonym14: "Indonesia Baking",
  anonym15: "ALSU507",
  anonym16: "Marketing Cakes AG",
};
