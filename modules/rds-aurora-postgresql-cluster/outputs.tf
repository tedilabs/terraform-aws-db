output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_rds_cluster.this.region
}

output "id" {
  description = "The ID of the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.this.id
}

output "arn" {
  description = "The ARN of the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.this.arn
}

output "name" {
  description = "The name of the Aurora PostgreSQL cluster."
  value       = aws_rds_cluster.this.cluster_identifier
}

output "engine" {
  description = <<EOF
  The engine configuration of the cluster.
    `type` - The engine type. Always `aurora-postgresql`.
    `mode` - The engine mode of the cluster.
    `version` - The running engine version.
    `version_actual` - The running engine version (identical to `version`).
    # `extended_support_enabled` - Whether RDS Extended Support is enabled.
  EOF
  value = {
    type           = aws_rds_cluster.this.engine
    mode           = aws_rds_cluster.this.engine_mode
    version        = aws_rds_cluster.this.engine_version
    version_actual = aws_rds_cluster.this.engine_version_actual
    # extended_support_enabled = var.extended_support_enabled
  }
}

output "database" {
  description = <<EOF
  The database configuration of the cluster.
    `name` - The name of the default database.
    `port` - The port on which the DB accepts connections.
  EOF
  value = {
    name = aws_rds_cluster.this.database_name
    port = aws_rds_cluster.this.port
  }
}

output "admin_user" {
  description = <<EOF
  The master user configuration of the cluster.
  EOF
  value = {
    username = aws_rds_cluster.this.master_username
    password = {
      mode = (aws_rds_cluster.this.manage_master_user_password
        ? "SECRETS_MANAGER"
        : "TO_BE_CONTINUE"
      )
      secrets_manager_secret = (aws_rds_cluster.this.manage_master_user_password
        ? {
          arn     = aws_rds_cluster.this.master_user_secret[0].secret_arn
          name    = trimprefix(provider::aws::arn_parse(aws_rds_cluster.this.master_user_secret[0].secret_arn).resource, "secret:")
          status  = upper(aws_rds_cluster.this.master_user_secret[0].secret_status)
          kms_key = aws_rds_cluster.this.master_user_secret[0].kms_key_id
        }
        : null
      )
    }
  }
}

output "endpoints" {
  description = <<EOF
  The endpoint configuration of the cluster.
    `writer` - The cluster writer endpoint.
    `reader` - The cluster reader endpoint.
    `custom` - A map of custom endpoints keyed by identifier.
  EOF
  value = {
    writer = {
      address = aws_rds_cluster.this.endpoint
      port    = aws_rds_cluster.this.port
    }
    reader = {
      address = aws_rds_cluster.this.reader_endpoint
      port    = aws_rds_cluster.this.port
    }
    custom = {
      for name, endpoint in aws_rds_cluster_endpoint.this :
      name => {
        arn     = endpoint.arn
        name    = name
        address = endpoint.endpoint
        port    = aws_rds_cluster.this.port
        type    = endpoint.custom_endpoint_type
      }
    }
  }
}

output "network" {
  description = <<EOF
  The network configuration of the cluster.
    `db_subnet_group` - The name of the DB subnet group.
    `network_type` - The network type of the cluster.
    `vpc_security_groups` - The list of VPC security group IDs associated with the cluster.
    `hosted_zone_id` - The Route53 hosted zone ID of the cluster endpoint.
  EOF
  value = {
    db_subnet_group     = aws_rds_cluster.this.db_subnet_group_name
    network_type        = aws_rds_cluster.this.network_type
    vpc_security_groups = aws_rds_cluster.this.vpc_security_group_ids
    hosted_zone_id      = aws_rds_cluster.this.hosted_zone_id
  }
}

output "storage" {
  description = <<EOF
  The storage configuration of the cluster.
    `type` - The storage type.
    `encrypted` - Whether the cluster storage is encrypted.
    `kms_key` - The ARN of the KMS key used to encrypt the cluster storage.
  EOF
  value = {
    type      = aws_rds_cluster.this.storage_type
    encrypted = aws_rds_cluster.this.storage_encrypted
    kms_key   = aws_rds_cluster.this.kms_key_id
  }
}

output "cluster_parameter_group" {
  description = <<EOF
  The cluster parameter group configuration.
    `id` - The ID of the cluster parameter group.
    `arn` - The ARN of the cluster parameter group.
    `name` - The name of the cluster parameter group.
  EOF
  value = (var.cluster_parameter_group.create
    ? {
      id   = aws_rds_cluster_parameter_group.this[0].id
      arn  = aws_rds_cluster_parameter_group.this[0].arn
      name = aws_rds_cluster_parameter_group.this[0].name
    }
    : {
      id   = null
      arn  = null
      name = aws_rds_cluster.this.db_cluster_parameter_group_name
    }
  )
}

output "db_parameter_group" {
  description = <<EOF
  The DB parameter group configuration.
    `id` - The ID of the DB parameter group.
    `arn` - The ARN of the DB parameter group.
    `name` - The name of the DB parameter group.
  EOF
  value = (var.db_parameter_group.create
    ? {
      id   = aws_db_parameter_group.this[0].id
      arn  = aws_db_parameter_group.this[0].arn
      name = aws_db_parameter_group.this[0].name
    }
    : {
      id   = null
      arn  = null
      name = var.db_parameter_group.name
    }
  )
}

output "instances" {
  description = <<EOF
  A map of Aurora cluster instances keyed by identifier.
    `id` - The ID of the instance.
    `arn` - The ARN of the instance.
    `identifier` - The identifier of the instance.
    `instance_class` - The instance class.
    `availability_zone` - The Availability Zone of the instance.
    `endpoint` - The DNS address for the instance.
    `port` - The database port.
    `writer` - Whether the instance is the primary writer.
    `promotion_tier` - The failover priority.
  EOF
  value = {
    for identifier, instance in aws_rds_cluster_instance.this :
    identifier => {
      id                = instance.id
      arn               = instance.arn
      identifier        = instance.identifier
      instance_class    = instance.instance_class
      availability_zone = instance.availability_zone
      endpoint          = instance.endpoint
      port              = instance.port
      writer            = instance.writer
      promotion_tier    = instance.promotion_tier
    }
  }
}

output "maintenance" {
  description = <<EOF
  The configuration for maintenance of the RDS Aurora cluster.
    `window` - The weekly time range for when maintenance on the RDS Aurora cluster is performed.
  EOF
  value = {
    window = aws_rds_cluster.this.preferred_maintenance_window
  }
}

output "backup" {
  description = <<EOF
  The backup configuration of the RDS Aurora cluster.
    `window` - The daily time range during which automated backups are created if automated backups are enabled.
    `retention` - The number of days for which automated backups are retained.
    `copy_tags_to_snapshot` - Whether to copy tags to snapshots.
    `final_snapshot` - The configuration for the final snapshot when the cluster is deleted.
  EOF
  value = {
    window    = aws_rds_cluster.this.preferred_backup_window
    retention = aws_rds_cluster.this.backup_retention_period

    copy_tags_to_snapshot = aws_rds_cluster.this.copy_tags_to_snapshot

    final_snapshot = {
      enabled = !aws_rds_cluster.this.skip_final_snapshot
      name    = aws_rds_cluster.this.final_snapshot_identifier
    }
  }
}

output "iam_database_authentication_enabled" {
  description = "Whether IAM database authentication is enabled."
  value       = aws_rds_cluster.this.iam_database_authentication_enabled
}

output "deletion_protection_enabled" {
  description = "Whether deletion protection is enabled."
  value       = aws_rds_cluster.this.deletion_protection
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

output "sharing" {
  description = <<EOF
  The configuration for sharing of the RDS Aurora cluster.
    `status` - An indication of whether the RDS Aurora cluster is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.
    `shares` - The list of resource shares via RAM (Resource Access Manager).
  EOF
  value = {
    status = length(module.share) > 0 ? "SHARED_BY_ME" : "NOT_SHARED"
    shares = module.share
  }
}

output "debug" {
  value = {
    cluster = {
      for k, v in aws_rds_cluster.this :
      k => v
      if !contains(["arn", "id", "cluster_identifier", "master_password", "tags", "tags_all", "timeouts", "region", "master_username", "manage_master_user_password", "master_user_secret_kms_key_id", "master_user_secret", "endpoint", "reader_endpoint", "port", "backup_retention_period", "cluster_identifier_prefix", "copy_tags_to_snapshot", "final_snapshot_identifier", "preferred_backup_window", "preferred_maintenance_window", "skip_final_snapshot", "engine", "engine_version", "engine_version_actual", "engine_mode"], k)
    }
    endpoints = {
      for name, endpoint in aws_rds_cluster_endpoint.this :
      name => {
        for k, v in endpoint :
        k => v
        if !contains(["arn", "id", "cluster_identifier", "region", "cluster_endpoint_identifier", "custom_endpoint_type", "tags", "tags_all", "endpoint", "excluded_members", "static_members"], k)
      }
    }
  }
}
