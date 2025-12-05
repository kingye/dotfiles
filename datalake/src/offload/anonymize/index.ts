import mustashe, { Context } from "mustache";
import cds from "@sap/cds";
export class Anonymizer {
  constructor(
    private readonly mappingInfo: { [key: string]: string } = {},
    private readonly pattern = "anonym",
  ) {}

  public anonymize(data: string, from: string = data): string {
    let id = Object.entries(this.mappingInfo).find(([k, v]) => v === from)?.[0];
    if (!id) {
      id = `${this.pattern}-${cds.utils.uuid()}`;
      this.mappingInfo[id] = from;
    }
    return data.replaceAll(from, `{{${id}}}`);
  }
  public restore(data: string): string {
    return mustashe.render(data, this.mappingInfo);
  }
  public maxMaskLength() {
    return Object.values(this.mappingInfo).reduce(
      (p, c) => Math.max(p, c.length),
      0,
    );
  }
  // to ensure that part1 not constains unclosed {{
  // If there is unclosed {{, this should be kept into part2
  public ensure(data: string): [part1: string, part2: string | undefined] {
    const ix = data.lastIndexOf("{{");
    const ix2 = data.indexOf("}}", ix + 2);
    if (ix2 > ix) {
      return [data.substring(0, ix), data.substring(ix)];
    }
    return [data, undefined];
  }
}
