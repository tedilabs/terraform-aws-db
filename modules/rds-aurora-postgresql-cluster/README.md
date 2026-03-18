# rds-aurora-postgresql-cluster

This module creates following resources.

- `aws_rds_cluster`
- `aws_rds_cluster_instance`
- `aws_rds_cluster_parameter_group` (optional)
- `aws_db_parameter_group` (optional)
- `aws_rds_cluster_endpoint` (optional)

## Usage

### Provisioned Cluster

```hcl
module "aurora_postgresql" {
  source = "tedilabs/rds/aws//modules/aurora-postgresql-cluster"

  name           = "my-aurora-pg"
  engine_version = "16.6"

  admin_username = "clusteradmin"
  database       = "myapp"

  db_subnet_group    = "my-db-subnet-group"
  vpc_security_groups = ["sg-0123456789abcdef0"]

  cluster_parameter_group = {
    create = true
    family = "aurora-postgresql16"
    parameters = [
      {
        name  = "shared_preload_libraries"
        value = "pg_stat_statements,pg_hint_plan"
      },
    ]
  }

  db_parameter_group = {
    create = true
    family = "aurora-postgresql16"
    parameters = [
      {
        name  = "log_min_duration_statement"
        value = "1000"
      },
    ]
  }

  instances = [
    {
      identifier     = "my-aurora-pg-1"
      instance_class = "db.r6g.large"
      promotion_tier = 0
    },
    {
      identifier     = "my-aurora-pg-2"
      instance_class = "db.r6g.large"
      promotion_tier = 1
    },
  ]

  backup_retention_period = 14

  performance_insights = {
    enabled          = true
    retention_period = 7
  }

  monitoring = {
    interval = 60
    role_arn = "arn:aws:iam::123456789012:role/rds-monitoring-role"
  }
}
```

### Serverless v2 Cluster

```hcl
module "aurora_postgresql_serverless" {
  source = "tedilabs/rds/aws//modules/aurora-postgresql-cluster"

  name           = "my-aurora-pg-serverless"
  engine_version = "16.6"

  admin_username = "clusteradmin"

  db_subnet_group    = "my-db-subnet-group"
  vpc_security_groups = ["sg-0123456789abcdef0"]

  serverless_v2_scaling = {
    min_capacity = 0.5
    max_capacity = 16
  }

  instances = [
    {
      identifier     = "my-aurora-pg-serverless-1"
      instance_class = "db.serverless"
    },
  ]
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
