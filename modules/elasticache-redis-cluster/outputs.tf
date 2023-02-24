output "id" {
  description = "The ID of the ElastiCache Redis cluster."
  value       = aws_elasticache_replication_group.this.id
}

output "arn" {
  description = "The ARN of the ElastiCache Redis cluster."
  value       = aws_elasticache_replication_group.this.arn
}

output "name" {
  description = "The name of the ElastiCache Redis cluster."
  value       = var.name
}

output "description" {
  description = "The description of the ElastiCache Redis cluster."
  value       = aws_elasticache_replication_group.this.description
}

output "redis_version" {
  description = "The version number of Redis used for the ElastiCache Redis cluster. The actual engine version used is returned in `redis_version_actual`."
  value       = aws_elasticache_replication_group.this.engine_version
}

output "redis_version_actual" {
  description = "The actual version number of Redis used for the ElastiCache Redis cluster. Because ElastiCache pulls the latest minor or patch for a version, this attribute returns the running version of the cache engine."
  value       = aws_elasticache_replication_group.this.engine_version_actual
}

output "node_instance_type" {
  description = "The instance type used for the ElastiCache Redis cluster."
  value       = aws_elasticache_replication_group.this.node_type
}

output "node_size" {
  description = "The number of cache nodes (primary and replicas) for this ElastiCache Redis cluster will have."
  value       = aws_elasticache_replication_group.this.num_cache_clusters
}

output "nodes" {
  description = "The list of all nodes are part of the ElastiCache Redis cluster."
  value       = aws_elasticache_replication_group.this.member_clusters
}

output "sharding" {
  description = "The configuration for sharding of the ElastiCache Redis cluster."
  value = {
    enabled    = aws_elasticache_replication_group.this.cluster_enabled
    shard_size = aws_elasticache_replication_group.this.num_node_groups
    replicas   = aws_elasticache_replication_group.this.replicas_per_node_group
  }
}

output "network" {
  description = <<EOF
  The configuration for network of the ElastiCache Redis cluster.
    `port` - The port number on each cache nodes to accept connections.
    `subnet_group` - The name of the cache subnet group used for.
    `preferred_availability_zones` - The list of AZs(Availability Zones) in which the ElastiCache Redis cluster nodes will be created.
  EOF
  value = {
    port                         = aws_elasticache_replication_group.this.port
    vpc_id                       = var.vpc_id
    subnet_group                 = aws_elasticache_replication_group.this.subnet_group_name
    preferred_availability_zones = aws_elasticache_replication_group.this.preferred_cache_cluster_azs

    default_security_group = one(module.security_group[*].id)
    security_groups        = aws_elasticache_replication_group.this.security_group_ids
  }
}

output "parameter_group" {
  description = "The name of the parameter group associated with the ElastiCache Redis cluster."
  value       = aws_elasticache_replication_group.this.parameter_group_name
}

output "auth" {
  description = <<EOF
  The configuration for auth of the ElastiCache Redis cluster.
    `user_groups` - A set of User Group IDs to associate with the ElastiCache Redis cluster.
  EOF
  value = {
    # password = aws_elasticache_replication_group.this.auth_token
    user_groups = aws_elasticache_replication_group.this.user_group_ids
  }
}

output "encryption" {
  description = <<EOF
  The configuration for encryption of the ElastiCache Redis cluster.
    `at_rest` - The configuration for at-rest encryption.
    `in_transit` - The configuration for in-transit encryption.
  EOF
  value = {
    at_rest = {
      enabled = aws_elasticache_replication_group.this.at_rest_encryption_enabled
      kms_key = aws_elasticache_replication_group.this.kms_key_id
    }
    in_transit = {
      enabled = aws_elasticache_replication_group.this.transit_encryption_enabled
    }
  }
}

output "backup" {
  description = <<EOF
  The configuration for backup of the ElastiCache Redis cluster.
    `enabled` - Whether to automatically create a daily backup of a set of replicas.
    `window` - The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of the ElastiCache Redis cluster.
    `retention` - The number of days for which automated backups are retained before they are automatically deleted.
  EOF
  value = {
    enabled   = aws_elasticache_replication_group.this.snapshot_retention_limit != 0
    window    = aws_elasticache_replication_group.this.snapshot_window
    retention = aws_elasticache_replication_group.this.snapshot_retention_limit

    final_snapshot_name = aws_elasticache_replication_group.this.final_snapshot_identifier
  }
}

output "source" {
  description = <<EOF
  The configuration for source backup of the ElastiCache Redis cluster to restore from.
    `backup_name` - The name of a snapshot from which to restore data into the new node group.
    `rdb_s3_arns` - The list of ARNs that identify Redis RDB snapshot files stored in Amazon S3.
  EOF
  value = {
    backup_name = aws_elasticache_replication_group.this.snapshot_name
    rdb_s3_arns = aws_elasticache_replication_group.this.snapshot_arns
  }
}

output "maintenance" {
  description = <<EOF
  The configuration for maintenance of the ElastiCache Redis cluster.
    `window` - The weekly time range for when maintenance on the ElastiCache Redis cluster is performed.
    `auto_upgrade_minor_version_enabled` - Whether automatically schedule cluster upgrade to the latest minor version, once it becomes available.
    `notification_sns_arn` - The ARN of an SNS topic to send ElastiCache notifications to.
  EOF
  value = {
    window                             = aws_elasticache_replication_group.this.maintenance_window
    auto_upgrade_minor_version_enabled = aws_elasticache_replication_group.this.auto_minor_version_upgrade
    notification_sns_topic             = aws_elasticache_replication_group.this.notification_topic_arn
  }
}

output "logging" {
  description = <<EOF
  The configuration for logging of the ElastiCache Redis cluster.
    `slow_log` - The configuration for streaming Redis Slow Log.
    `engine_log` - The configuration for streaming Redis Engine Log.
  EOF
  value = {
    slow_log   = var.logging_slow_log
    engine_log = var.logging_engine_log
  }
}

output "attributes" {
  description = "A set of attributes that applied to the ElastiCache Redis cluster."
  value = {
    apply_immediately     = aws_elasticache_replication_group.this.apply_immediately
    auto_failover_enabled = aws_elasticache_replication_group.this.automatic_failover_enabled
    muti_az_enabled       = aws_elasticache_replication_group.this.multi_az_enabled

    data_tiering_enabled = aws_elasticache_replication_group.this.data_tiering_enabled
  }
}

output "endpoints" {
  description = <<EOF
  The connection endpoints to the ElastiCache Redis cluster.
    `primary` - Address of the endpoint for the primary node in the cluster, if the cluster mode is disabled.
    `reader` - Address of the endpoint for the reader node in the cluster, if the cluster mode is disabled.
    `configuration` - Address of the replication group configuration endpoint when cluster mode is enabled.
  EOF
  value = {
    primary       = aws_elasticache_replication_group.this.primary_endpoint_address
    reader        = aws_elasticache_replication_group.this.reader_endpoint_address
    configuration = aws_elasticache_replication_group.this.configuration_endpoint_address
  }
}
