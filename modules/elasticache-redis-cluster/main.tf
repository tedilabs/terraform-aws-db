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
  ip_address_types = {
    "IPv4"      = "ipv4"
    "IPv6"      = "ipv6"
    "DUALSTACK" = "dual_stack"
  }

  is_data_tiering_type = replace(var.node_instance_type, "/^cache\\.[a-z0-9]?d\\..*$/", "1") == "1" ? true : false

  logging_destination_types = {
    "CLOUDWATCH_LOGS"  = "cloudwatch-logs"
    "KINESIS_FIREHOSE" = "kinesis-firehose"
  }
}


###################################################
# ElastiCache Cluster for Redis
###################################################

# INFO: Not supported attributes
# - `security_group_names`
resource "aws_elasticache_replication_group" "this" {
  region = var.region

  replication_group_id = var.name
  description          = var.description


  ## Engine
  engine         = var.engine.type
  engine_version = var.engine.version


  ## Nodes
  cluster_mode = lower(var.cluster_mode.state)
  node_type    = var.node_instance_type

  num_cache_clusters = var.cluster_mode.state != "ENABLED" ? var.node_size : null

  num_node_groups = var.cluster_mode.state == "ENABLED" ? var.cluster_mode.shard_size : null
  replicas_per_node_group = (var.cluster_mode.state == "ENABLED"
    ? (length(var.cluster_mode.shard_configurations) > 0
      ? null
      : var.cluster_mode.replicas
    )
    : null
  )

  dynamic "node_group_configuration" {
    for_each = (var.cluster_mode.state == "ENABLED" && length(var.cluster_mode.shard_configurations) > 0
      ? var.cluster_mode.shard_configurations
      : []
    )
    iterator = shard

    content {
      node_group_id = shard.value.id
      slots         = shard.value.slots
      replica_count = shard.value.replicas != null ? shard.value.replicas : var.cluster_mode.replicas

      primary_availability_zone  = shard.value.primary_availability_zone
      replica_availability_zones = shard.value.secondary_availability_zones

      primary_outpost_arn  = shard.value.primary_outpost
      replica_outpost_arns = shard.value.secondary_outposts
    }
  }


  ## Network
  port         = var.port
  network_type = local.ip_address_types[var.ip_address_type]
  ip_discovery = local.ip_address_types[var.discovery_ip_address_type]

  subnet_group_name           = var.subnet_group
  preferred_cache_cluster_azs = var.preferred_availability_zones
  security_group_ids = (var.default_security_group.enabled
    ? concat(module.security_group[*].id, var.security_groups)
    : var.security_groups
  )


  ## Parameters
  parameter_group_name = (var.default_parameter_group.enabled
    ? aws_elasticache_parameter_group.this[0].name
    : var.parameter_group
  )


  ## Auth
  auth_token                 = length(var.password) > 0 ? var.password : null
  auth_token_update_strategy = length(var.password) > 0 ? var.password_update_strategy : null
  user_group_ids             = length(var.user_groups) > 0 ? var.user_groups : null


  ## Encryption
  at_rest_encryption_enabled = var.encryption_at_rest.enabled
  kms_key_id                 = var.encryption_at_rest.kms_key
  transit_encryption_enabled = var.encryption_in_transit.enabled
  transit_encryption_mode    = var.apply_immediately ? var.encryption_in_transit.mode : null


  ## Maintenance
  maintenance_window         = var.maintenance.window
  auto_minor_version_upgrade = var.maintenance.auto_upgrade_minor_version_enabled
  notification_topic_arn     = var.maintenance.notification_sns_topic


  ## Backup
  snapshot_retention_limit = (var.backup.enabled
    ? var.backup.retention
    : 0
  )
  snapshot_window           = var.backup.window
  final_snapshot_identifier = var.backup.final_snapshot_name


  ## Restore
  snapshot_name = var.restore.backup_name
  snapshot_arns = var.restore.rdb_s3_arns


  ## Logging
  dynamic "log_delivery_configuration" {
    for_each = var.logging_slow_log.enabled ? [var.logging_slow_log] : []
    iterator = logging

    content {
      log_type         = "slow-log"
      log_format       = lower(logging.value.format)
      destination_type = local.logging_destination_types[logging.value.destination.type]
      destination      = logging.value.destination.name
    }
  }
  dynamic "log_delivery_configuration" {
    for_each = var.logging_engine_log.enabled ? [var.logging_engine_log] : []
    iterator = logging

    content {
      log_type         = "engine-log"
      log_format       = lower(logging.value.format)
      destination_type = local.logging_destination_types[logging.value.destination.type]
      destination      = logging.value.destination.name
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
}
