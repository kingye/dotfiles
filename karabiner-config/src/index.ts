import { rule, writeToProfile } from "karabiner.ts";
import { hrm }  from "karabiner.ts-greg-mods";

writeToProfile("Default profile", [
  rule("Home row mods").manipulators(
    hrm(
      new Map([
        ["a", "l⌘"],
        ["s", "l⌥"],
        ["d", "l⇧"],
        ["f", "l⌃"],
        ["j", "r⌃"],
        ["k", "r⇧"],
        ["l", "r⌥"],
        [";", "r⌘"],
      ])
    )
      .lazy(true)
      .holdTapStrategy("permissive-hold")
      .chordalHold(true)
      .build()
  )
]);
