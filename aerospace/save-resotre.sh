#!/bin/sh
# save/restore windows through an aerospace restart
# - won't work for app restarts or OS reboots where window IDs are reset (i.e. no good for browser updates)
# - could go most of the way there by saving and restoring windows based on their titles
#   however aerospace does not provide a CLI facility to do that
# - https://github.com/nikitabobko/AeroSpace/issues/57

STATEFILE=~/.aerospace-windows.json

save()
{
  echo "writing current window state to ${STATEFILE}" >&2
  aerospace list-windows --all --json --format '%{window-id}%{workspace}%{app-name}' > "$STATEFILE"
}

restore()
{
  echo "restoring current window state from ${STATEFILE}" >&2
  # for reasons unknown aerospace can (will) read from stdin (and consume the
  # remaining jq output being fed to the read loop) - very important to redirect
  # stdin
  jq -r '.[] | [."window-id",."workspace",."app-name"] | @tsv' < "$STATEFILE" |
    while IFS="$(printf '\t')" read -r windowid workspace appname; do
      echo "${appname} (${windowid}) -> ${workspace}"
      aerospace move-node-to-workspace --window-id "$windowid" "$workspace" </dev/null >/dev/null 2>&1
    done
}

case "$1" in
  save)
    save
    ;;
  restore)
    restore
    ;;
  *)
    echo "$0 (save|restore)" >&2
    ;;
esac
