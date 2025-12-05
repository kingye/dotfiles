import { PageOpts } from "../types";

export const error = (msg: string, error: any): Error => {
  return new Error(
    `${msg}: ${(error as Error).message}, ${(error as any).response?.body}`,
    { cause: error },
  );
};

export const paging = (
  fileLength: number,
  blockSize = 512 * 1024,
): PageOpts[] => {
  const chunks = Math.floor(fileLength / blockSize);
  const rest = fileLength % blockSize;
  const res = [] as { offset: number; length: number }[];
  for (let i = 0; i < chunks; i++) {
    res.push({ offset: i * blockSize, length: blockSize });
  }
  if (rest > 0) {
    res.push({ offset: chunks * blockSize, length: rest });
  }
  return res;
};
