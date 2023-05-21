#! /bin/bash

if ! git submodule --quiet foreach "$(realpath cwm4/scripts/update_submodule.sh)"' --quiet --commit $name "$path" $sha1 "$toplevel"'; then
  echo >&2 "cwm4/scripts/upsm-push.sh: fatal error."
  exit 1
fi

exec git push "$@"
