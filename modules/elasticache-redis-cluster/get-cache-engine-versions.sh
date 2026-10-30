#!/usr/bin/env sh

set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
temp_dir=$(mktemp -d "$script_dir/.cache-engine-versions.XXXXXX")
trap 'rm -rf "$temp_dir"' 0
trap 'exit 1' HUP INT TERM

AWS_PAGER="" aws elasticache describe-cache-engine-versions --output json > "$temp_dir/raw.json"
jq -e '
  .CacheEngineVersions
  | if type == "array" and length > 0 then . else error("Expected a non-empty CacheEngineVersions array") end
  | map({
    engine: .Engine,
    engine_version: .EngineVersion,
    parameter_group_family: .CacheParameterGroupFamily
  })
  | if all(.[]; all(.[]; type == "string" and length > 0)) then . else error("Invalid cache engine version mapping") end
' "$temp_dir/raw.json" > "$temp_dir/cache-engine-versions.json"

mv "$temp_dir/cache-engine-versions.json" "$script_dir/cache-engine-versions.json"
