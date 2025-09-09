# terraform-aws-db

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-db?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-db?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates db related resources on AWS.

- [elasticache-redis-cluster](./modules/elasticache-redis-cluster)
- [elasticache-redis-user](./modules/elasticache-redis-user)
- [elasticache-redis-user-group](./modules/elasticache-redis-user-group)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-db) were written to manage the following AWS Services with Terraform.

- **AWS RDS (Relational Database Service)**
  - (comming sooon!)
- **AWS ElastiCache**
  - Redis Cluster
  - Redis User RBAC


## Usage

### ElastiCache Redis

```tf
module "cluster" {
  source  = "tedilabs/db/aws//modules/elasticache-redis-cluster"
  version = "~> 0.2.0"

  name        = "example-redis-full"
  description = "Managed by Terraform."

  redis_version      = "6.2"
  node_instance_type = "cache.t4g.micro"
  # node_size          = 1
  sharding = {
    enabled    = true
    shard_size = 3
    replicas   = 2
  }


  ## Network
  port                         = 6379
  vpc_id                       = null
  subnet_group                 = null
  preferred_availability_zones = []

  default_security_group = {
    eanbled     = true
    name        = "example-redis-full-default-sg"
    description = "Managed by Terraform."

    ingress_rules = [
      {
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  security_groups = []


  ## Parameters
  parameter_group = {
    enabled     = true
    name        = "example-redis-full-parameter-group"
    description = "Managed by Terraform."
    parameters = {
      "lazyfree-lazy-eviction"   = "yes"
      "lazyfree-lazy-expire"     = "yes"
      "lazyfree-lazy-server-del" = "yes"
      "rename-commands"          = "KEYS BLOCKED"
    }
  }
  custom_parameter_group = null


  ## Auth
  password    = sensitive("helloworld!#!!1234")
  user_groups = []


  ## Encryption
  encryption_at_rest = {
    enabled = true
    kms_key = null
  }
  encryption_in_transit = {
    enabled = true
  }


  ## Backup
  backup_enabled             = true
  backup_window              = "16:00-17:00"
  backup_retention           = 1
  backup_final_snapshot_name = "example-redis-full-final"


  ## Source
  source_backup_name = null
  source_rdb_s3_arns = null


  ## Maintenance
  maintenance_window                 = "fri:18:00-fri:20:00"
  auto_upgrade_minor_version_enabled = true
  notification_sns_topic             = null


  ## Logging
  logging_slow_log = {
    enabled = false
    format  = "JSON"

    destination_type = "CLOUDWATCH_LOGS"
    destination      = null
  }
  logging_engine_log = {
    enabled = false
    format  = "JSON"

    destination_type = "CLOUDWATCH_LOGS"
    destination      = null
  }


  ## Attributes
  multi_az_enabled      = true
  auto_failover_enabled = true
  apply_immediately     = true

  timeouts = {
    create = "60m"
    update = "40m"
    delete = "40m"
  }

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
```


## Examples

### ElastiCache Redis

- [Singie Redis Instance](./examples/elasticache-redis-single)
- [Multi-AZs Redis Cluster (Sharding Disabled)](./examples/elasticache-redis-multi-az)
- [Full Redis Cluster (Sharding Enabled)](./examples/elasticache-redis-full)
- [Redis Cluster with RBAC(Role Based Access Control)](./examples/elasticache-redis-with-users)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-db). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022-2025, [Byungjin Park](https://www.posquit0.com).