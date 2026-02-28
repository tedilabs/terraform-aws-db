#!/usr/bin/env sh

aws elasticache describe-cache-engine-versions > raw.json
cat raw.json | jq '
  .CacheEngineVersions | map({
    engine: .Engine,
    engine_version: .EngineVersion,
    parameter_group_family: .CacheParameterGroupFamily,
})' > cache-engine-versions.json
