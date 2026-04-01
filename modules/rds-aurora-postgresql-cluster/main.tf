locals {
  metadata = {
    package = "terraform-aws-db"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# Aurora PostgreSQL Cluster
###################################################

# INFO: Not supported attributes
# - `cluster_identifier_prefix`
# - `master_password` (use `manage_master_user_password`)
# - `replication_source_identifier` (use dedicated cross-region read replica module)
# - `snapshot_identifier` (use dedicated restore module)
# - `restore_to_point_in_time` (use dedicated restore module)
# - `global_cluster_identifier` (use dedicated global cluster module)
resource "aws_rds_cluster" "this" {
  region = var.region

  cluster_identifier = var.name

  engine         = "aurora-postgresql"
  engine_version = var.engine_version
  # INFO: Only `provisioned` is currently supported for Aurora PostgreSQL.
  # `serverless` — Only for Aurora Serverless v1, which reached end of life on March 31, 2025. Use provisioned with db.serverless instance class for Serverless v2 instead.
  # `parallelquery` — Legacy mode for Aurora MySQL 5.6 only. Since Aurora MySQL 2.09+, parallel query is available in provisioned mode via the aurora_parallel_query parameter.
  # `global` — Legacy mode for Aurora MySQL 5.6 (≤1.21) only. Current Aurora Global Database uses provisioned mode with global_cluster_identifier.
  # `multimaster` — Deprecated. Was limited to Aurora MySQL 5.6.10a with max 2 writer instances and significant limitations.
  engine_mode = "provisioned"

  ## NOTE: `engine_lifecycle_support` controls the extended support policy.
  ## - `open-source-rds-extended-support` (default): Extended support available.
  ## - `open-source-rds-extended-support-disabled`: No extended support. The cluster
  ##   will be automatically upgraded to a higher engine version if the minor engine
  ##   version is past the end of standard support date.
  engine_lifecycle_support = (var.extended_support_enabled
    ? "open-source-rds-extended-support"
    : "open-source-rds-extended-support-disabled"
  )


  ###################################################
  # Database
  ###################################################

  database_name = var.database
  port          = var.port


  ## Admin User
  master_username             = var.admin_user.username
  manage_master_user_password = var.admin_user.password.mode == "SECRETS_MANAGER"
  master_user_secret_kms_key_id = (var.admin_user.password.mode == "SECRETS_MANAGER"
    ? var.admin_user.password.secrets_manager_secret.kms_key
    : null
  )


  ###################################################
  # Network
  ###################################################

  db_subnet_group_name   = var.subnet_group
  availability_zones     = var.availability_zones
  network_type           = var.network_type
  vpc_security_group_ids = var.vpc_security_groups


  ###################################################
  # Storage
  ###################################################

  storage_type      = var.storage_type
  allocated_storage = var.storage_type == "aurora-iopt1" ? var.allocated_storage : null
  iops              = var.storage_type == "aurora-iopt1" ? var.iops : null
  storage_encrypted = true
  kms_key_id        = var.storage_encryption_kms_key


  ###################################################
  # Cluster Parameter Group
  ###################################################

  db_cluster_parameter_group_name = (var.cluster_parameter_group.create
    ? aws_rds_cluster_parameter_group.this[0].name
    : var.cluster_parameter_group.name
  )


  ## Maintenance
  preferred_maintenance_window = var.maintenance.window


  ## Backup
  preferred_backup_window = var.backup.window
  backup_retention_period = var.backup.retention

  copy_tags_to_snapshot = var.backup.copy_tags_to_snapshot

  skip_final_snapshot = !var.backup.final_snapshot.enabled
  final_snapshot_identifier = (var.backup.final_snapshot.enabled
    ? coalesce(var.backup.final_snapshot.name, "${var.name}-final")
    : null
  )


  ###################################################
  # Deletion Protection
  ###################################################

  deletion_protection = var.deletion_protection_enabled
  ## NOTE: `allow_major_version_upgrade` is required to update `engine_version`
  ## to a different major version.
  allow_major_version_upgrade = var.allow_major_version_upgrade


  ###################################################
  # Auto Minor Version Upgrade
  ###################################################

  ## NOTE: Cluster-level setting is not directly available. Managed per instance.


  ###################################################
  # CloudWatch Logs Export
  ###################################################

  enabled_cloudwatch_logs_exports = var.cloudwatch_log_exports


  ###################################################
  # Performance Insights
  ###################################################

  ## NOTE: Performance Insights is configured per instance.


  ###################################################
  # Enhanced Monitoring
  ###################################################

  ## NOTE: Enhanced Monitoring is configured per instance.


  ###################################################
  # IAM Database Authentication
  ###################################################

  iam_database_authentication_enabled = var.iam_database_authentication_enabled


  ###################################################
  # Serverless v2 Scaling
  ###################################################

  dynamic "serverlessv2_scaling_configuration" {
    for_each = var.serverless_v2_scaling != null ? [var.serverless_v2_scaling] : []

    content {
      min_capacity             = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity             = serverlessv2_scaling_configuration.value.max_capacity
      seconds_until_auto_pause = serverlessv2_scaling_configuration.value.seconds_until_auto_pause
    }
  }


  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    ignore_changes = [
      availability_zones,
    ]
  }
}
