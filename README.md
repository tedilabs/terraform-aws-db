# terraform-aws-db

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-db?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-db?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

## ElastiCache modules have moved

The ElastiCache modules and examples are now maintained in [tedilabs/terraform-aws-elasticache](https://github.com/tedilabs/terraform-aws-elasticache). They have been removed from this repository's `main` branch. The `elasticache-` prefix has been removed from module and example directory names in the new repository.

| Previous module source | New module source |
| --- | --- |
| `tedilabs/db/aws//modules/elasticache-redis-cluster` | `tedilabs/elasticache/aws//modules/redis-cluster` |
| `tedilabs/db/aws//modules/elasticache-redis-user` | `tedilabs/elasticache/aws//modules/redis-user` |
| `tedilabs/db/aws//modules/elasticache-redis-user-group` | `tedilabs/elasticache/aws//modules/redis-user-group` |

See the [migration guide](https://github.com/tedilabs/terraform-aws-elasticache/blob/main/MIGRATION.md) for source changes, Git sources before the first registry release, and state and Resource Group considerations. After the new package's first registry release, use `version = "~> 0.1.0"` with its module sources.

Keep your existing module block labels and inputs when changing sources, then run `terraform init` and review `terraform plan`. Module metadata tags and default Resource Group names change with the new package and module names; set `resource_group.name` to its existing value if you need to retain that name.

Existing published versions, including [v0.5.1](https://github.com/tedilabs/terraform-aws-db/tree/v0.5.1), remain available at their original tags. Configurations pinned to those releases can continue using the old sources. Configurations following this repository's `main` branch must migrate.

## Examples

- [Single Redis instance](https://github.com/tedilabs/terraform-aws-elasticache/tree/main/examples/redis-single)
- [Multi-AZ Redis cluster](https://github.com/tedilabs/terraform-aws-elasticache/tree/main/examples/redis-muti-az)
- [Redis cluster with sharding](https://github.com/tedilabs/terraform-aws-elasticache/tree/main/examples/redis-full)
- [Valkey with users and a user group](https://github.com/tedilabs/terraform-aws-elasticache/tree/main/examples/valkey-with-users)

## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-db). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.

## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022-2026, [Byungjin Park](https://www.posquit0.com).
