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

locals {
  is_data_tiering_type = replace(var.node_instance_type, "/^cache\\.[a-z0-9]?d\\..*$/", "1") == "1" ? true : false
}


###################################################
# Parameter Group of ElastiCache Cluster for Redis
###################################################

locals {
  supported_families = [
    { name = "redis2.8", prefix = "2.8" },
    { name = "redis3.2", prefix = "3.2" },
    { name = "redis4.0", prefix = "4.0" },
    { name = "redis5.0", prefix = "5.0" },
    { name = "redis6.x", prefix = "6." },
  ]
  family = [
    for f in local.supported_families :
    f.name
    if startswith(var.redis_version, f.prefix)
  ][0]

  logging_destination_types = {
    "CLOUDWATCH_LOGS"  = "cloudwatch-logs"
    "KINESIS_FIREHOSE" = "kinesis-firehose"
  }
}

resource "aws_elasticache_parameter_group" "this" {
  count = var.parameter_group.enabled ? 1 : 0

  name        = coalesce(var.parameter_group.name, var.name)
  description = coalesce(var.parameter_group.description, "Customized Parameter Group for ${var.name} redis cluster. (v${var.redis_version})")
  family      = local.family

  dynamic "parameter" {
    for_each = var.parameter_group.parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# ElastiCache Cluster for Redis
###################################################

# INFO: Not supported attributes
# - `availability_zones` (Deprecated)
# - `cluster_mode` (Deprecated)
# - `number_cache_clusters ` (Deprecated)
# - `replication_group_description` (Deprecated)
# - `security_group_names` (Deprecated)
#
# Only need for secondary replicas
# - `global_replication_group_id`
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.name
  description          = var.description

  engine                  = "redis"
  engine_version          = var.redis_version
  node_type               = var.node_instance_type
  num_cache_clusters      = !var.sharding.enabled ? var.node_size : null
  num_node_groups         = var.sharding.enabled ? var.sharding.shard_size : null
  replicas_per_node_group = var.sharding.enabled ? var.sharding.replicas : null


  ## Network
  port                        = var.port
  subnet_group_name           = var.subnet_group
  preferred_cache_cluster_azs = var.preferred_availability_zones
  security_group_ids = (var.default_security_group.enabled
    ? concat(module.security_group.*.id, var.security_groups)
    : var.security_groups
  )


  ## Parameters
  parameter_group_name = (var.parameter_group.enabled
    ? aws_elasticache_parameter_group.this[0].name
    : var.custom_parameter_group
  )


  ## Auth
  auth_token     = length(var.password) > 0 ? var.password : null
  user_group_ids = length(var.user_groups) > 0 ? var.user_groups : null


  ## Encryption
  at_rest_encryption_enabled = var.encryption_at_rest.enabled
  kms_key_id                 = var.encryption_at_rest.kms_key
  transit_encryption_enabled = var.encryption_in_transit.enabled


  ## Backup
  snapshot_window           = var.backup_window
  snapshot_retention_limit  = var.backup_enabled ? var.backup_retention : 0
  final_snapshot_identifier = var.backup_final_snapshot_name


  ## Source
  snapshot_arns = var.source_rdb_s3_arns
  snapshot_name = var.source_backup_name


  ## Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_upgrade_minor_version_enabled
  notification_topic_arn     = var.notification_sns_topic


  ## Logging
  dynamic "log_delivery_configuration" {
    for_each = var.logging_slow_log.enabled ? [var.logging_slow_log] : []
    iterator = logging

    content {
      log_type         = "slow-log"
      log_format       = lower(logging.value.format)
      destination_type = local.logging_destination_types[logging.value.destination_type]
      destination      = logging.value.destination
    }
  }
  dynamic "log_delivery_configuration" {
    for_each = var.logging_engine_log.enabled ? [var.logging_engine_log] : []
    iterator = logging

    content {
      log_type         = "engine-log"
      log_format       = lower(logging.value.format)
      destination_type = local.logging_destination_types[logging.value.destination_type]
      destination      = logging.value.destination
    }
  }


  ## Attributes
  multi_az_enabled           = var.multi_az_enabled
  automatic_failover_enabled = var.auto_failover_enabled
  data_tiering_enabled       = local.is_data_tiering_type

  apply_immediately = var.apply_immediately

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
    precondition {
      condition = anytrue([
        !var.multi_az_enabled,
        var.multi_az_enabled && var.auto_failover_enabled,
      ])
      error_message = "If Muti-AZ Support is enabled, `auto_failover_enabled` must also be enabled."
    }
    precondition {
      condition = (length(var.password) > 0
        ? var.encryption_in_transit.enabled
        : true
      )
      error_message = "Password can be specified only if in-transit encryption is enabled."
    }
  }
}
