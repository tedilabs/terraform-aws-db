variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the ElastiCache Redis cluster. The name is stored as a lowercase string."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the ElastiCache Redis cluster. Defaults to `Managed by Terraform.`."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "engine" {
  description = <<EOF
  (Required) A configuration for the cache engine of the ElastiCache Redis cluster. `engine` as defined below.
    (Required) `type` - A name of the cache engine to be used for the clusters in this replication group. Valid values are `redis` or `valkey`.
    (Required) `version` - The version number of Redis used for the ElastiCache Redis cluster.
  EOF
  type = object({
    type    = string
    version = string
  })
  nullable = false

  validation {
    condition     = contains(["redis", "valkey"], var.engine.type)
    error_message = "Valid values for `engine.type` are `redis` or `valkey`."
  }
}

# INFO: https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheNodes.SupportedTypes.html
variable "node_instance_type" {
  description = "(Required) The instance type to be deployed for the ElastiCache Redis cluster."
  type        = string
  nullable    = false
}

variable "node_size" {
  description = "(Optional) The number of cache nodes (primary and replicas) for this ElastiCache Redis cluster will have. If Multi-AZ is enabled, this value must be at least 2. Updates will occur before other modifications. Defaults to `1`. Conflicts with `cluster_mode` when `cluster_mode.enabled` is `true`. In that case, use `cluster_mode.shard_size` to specify the number of shards and replicas for the cluster."
  type        = number
  default     = 1
  nullable    = false

  validation {
    condition = alltrue([
      var.node_size >= 1
    ])
    error_message = "`node_size` should be greater than `0`."
  }
}

variable "cluster_mode" {
  description = <<EOF
  The configuration for cluster mode of the ElastiCache Redis cluster.
    (Optional) `state` - The state of cluster mode. Valid values are `ENABLED`, `DISABLED`, or `COMPATIABLE`. It enables replication across multiple shards for enhanced scalability and availability. Defaults to `DISABLED`.
     - `ENABLED` - Cluster mode enabled with multiple shards and replicas.
     - `DISABLED` - Cluster mode disabled with a single shard and optional replicas.
     - `COMPATIABLE` - Cluster mode enabled with a single shard and optional replicas. This mode allows for easier migration to cluster mode in the future by enabling cluster mode features while maintaining a single shard configuration.
    (Optional) `shard_size` - The number of shards in this cluster. Changing this number will trigger a resizing operation before other settings modifications. Valid value is from `1` to `500`. Defaults to `3`.
    (Optional) `replicas` - The number of replicas for each shard. Changing this number will trigger a resizing operation before other settings modifications. Valid value is from `0` to `5`. Defaults to `2`.
    (Optional) `shard_configurations` - A configurations for shard customization. Can be specified only if `shard_size` is set. Each block of `shard_configurations` as defined below.
       (Required) `id` - The ID for the shard. The shard ID is a 1 to 4 character alphanumeric string.
       (Required) `slots` - The keyspace for this shard. Format is start-end (e.g., 0-5460).
       (Optional) `replicas` - The number of replicas for this shard. If not provided, defaults to the value of `cluster_mode.replicas`.
       (Optional) `primary_availability_zone` - Availability zone for the primary node in this shard.
       (Optional) `primary_outpost_arn` - ARN of the Outpost for the primary node in this shard.
       (Optional) `secondary_availability_zones` - A list of availability zones for replica nodes in this shard.
       (Optional) `secondary_outposts` - A list of ARNs of the Outposts for replica nodes in this shard.
  EOF
  type = object({
    state      = optional(string, "DISABLED")
    shard_size = optional(number, 3)
    replicas   = optional(number, 2)
    shard_configurations = optional(list(object({
      id       = string
      slots    = string
      replicas = optional(number)

      primary_availability_zone    = string
      primary_outpost              = optional(string)
      secondary_availability_zones = list(string)
      secondary_outposts           = optional(list(string))
    })), [])
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ENABLED", "DISABLED", "COMPATIABLE"], var.cluster_mode.state)
    error_message = "Valid values for `state` are `ENABLED`, `DISABLED`, or `COMPATIABLE`."
  }
  validation {
    condition = alltrue([
      var.cluster_mode.shard_size >= 1,
      var.cluster_mode.shard_size <= 500,
    ])
    error_message = "The number of shards should be between `1` and `500`."
  }
  validation {
    condition = alltrue([
      var.cluster_mode.replicas >= 0,
      var.cluster_mode.replicas <= 5,
    ])
    error_message = "The number of replicas for each shard should be between `0` and `5`."
  }
}

variable "port" {
  description = "(Optional) The port number on which each of the cache nodes will accept connections. The default port is `6379`."
  type        = number
  default     = 6379
  nullable    = false

  validation {
    condition = alltrue([
      var.port >= 1,
      var.port <= 65535
    ])
    error_message = "Valid values range for `port` from 1 through 65535."
  }
}

variable "ip_address_type" {
  description = "(Optional) The IP versions for cache cluster connections. Valid values are `IPv4`, `IPv6` and `DUALSTACK`. Defaults to `IPv4`"
  type        = string
  default     = "IPv4"
  nullable    = false

  validation {
    condition     = contains(["IPv4", "IPv6", "DUALSTACK"], var.ip_address_type)
    error_message = "Valid values are `IPv4`, `IPv6` and `DUALSTACK`."
  }
}

variable "discovery_ip_address_type" {
  description = "(Optional) The IP version to advertise in the discovery protocol. Valid values are `IPv4` or `IPv6`. Defaults to `IPv4`."
  type        = string
  default     = "IPv4"
  nullable    = false

  validation {
    condition     = contains(["IPv4", "IPv6"], var.discovery_ip_address_type)
    error_message = "Valid values for `discovery_ip_address_type` are `IPv4` or `IPv6`."
  }
}

variable "subnet_group" {
  description = "(Required) The name of the cache subnet group to be used for the ElastiCache Redis cluster."
  type        = string
  nullable    = false
}

variable "preferred_availability_zones" {
  description = "(Optional) A list of AZs(Availability Zones) in which the ElastiCache Redis cluster nodes will be created. The order of the availability zones in the list is considered. The first item in the list will be the primary node. Ignored when updating."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "default_security_group" {
  description = <<EOF
  (Optional) The configuration of the default security group for the ElastiCache Redis cluster. `default_security_group` block as defined below.
    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.
    (Optional) `name` - The name of the default security group. If not provided, the cluster name is used for the name of security group.
    (Optional) `description` - The description of the default security group.
    (Optional) `ingress_rules` - A list of ingress rules in a security group. You don't need to specify `protocol`, `from_port`, `to_port`. Just specify source information. Defaults to `[{ id = "default", ipv4_cidrs = ["0.0.0.0/0"] }]`. Each block of `ingress_rules` as defined below.
      (Required) `id` - The ID of the ingress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The source security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    description = optional(string, "Managed by Terraform.")
    ingress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      [{
        id         = "default"
        ipv4_cidrs = ["0.0.0.0/0"]
      }]
    )
  })
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "(Optional) A list of security group IDs to assign to the instance."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "default_parameter_group" {
  description = <<EOF
  The configuration for default parameter group of the ElastiCache Redis cluster. Use `parameter_group` if `default_parameter_group.enabled` is `false`. `default_parameter_group` as defined below.

    (Optional) `enabled` - Whether to enable managed parameter group by this module.
    (Optional) `name` - The name of the managed parameter group. If not provided, the name is configured with the cluster name.
    (Optional) `description` - The description of the managed parameter group. Defaults to `Managed by Terraform.`.
    (Optional) `parameters` - The key/value set for Redis parameters of ElastiCache Redis cluster. Each key is the name of the redis parameter. Each value is the value of the redis parameter.
    (Optional) `tags` - A map of tags to add to the parameter group.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
    parameters  = optional(map(string), {})
    tags        = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "parameter_group" {
  description = "(Optional) The name of the parameter group to associate with the ElastiCache Redis cluster. Only required if `default_parameter_group.enabled` is `false`. If this argument is omitted, the default cache parameter group for the specified engine is used. To enable `cluster_mode`, use a parameter group that has the parameter `cluster-enabled` set to `true`."
  type        = string
  default     = null
  nullable    = true
}

variable "password" {
  description = "(Optional) Password used to access a password protected ElastiCache Redis cluster. Can be specified only if `encryption_in_transit.enabled` is `true`."
  type        = string
  default     = ""
  nullable    = false
  sensitive   = true

  validation {
    condition = anytrue([
      length(var.password) == 0,
      length(var.password) >= 16 && length(var.password) <= 128
    ])
    error_message = "`password` must contain from 16 to 128 alphanumeric characters or symbols (excluding @, \", and /)."
  }
  validation {
    condition = (length(var.password) > 0
      ? var.encryption_in_transit.enabled
      : true
    )
    error_message = "When `password` is specified, `encryption_in_transit.enabled` must be `true`."
  }
}

variable "password_update_strategy" {
  description = "(Optional) Strategy used when modifying `password` on an existing replication group. Not used during initial create. Valid values are `SET`, `ROTATE`, and `DELETE`. Defaults to `ROTATE`. If value is `DELETE` then `password` must be omitted."
  type        = string
  default     = "ROTATE"
  nullable    = false

  validation {
    condition     = contains(["SET", "ROTATE", "DELETE"], var.password_update_strategy)
    error_message = "Valid values for `password_update_strategy` are `SET`, `ROTATE`, or `DELETE`."
  }
}

variable "user_groups" {
  description = "(Optional) A set of User Group IDs to associate with the ElastiCache Redis cluster. Only a maximum of one user group ID is valid. The AWS specification allows for multiple IDs, but AWS only allows a maximum size of one."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "encryption_at_rest" {
  description = <<EOF
  (Optional) A configuration for at-rest encryption of the ElastiCache Redis cluster. `encryption_at_rest` as defined below.
    (Optional) `enabled` - Whether to enable at-rest encryption. Defaults to `true`.
    (Optional) `kms_key` - The ARN of the key to use for at-rest encryption. If not supplied, uses service managed encryption key. Can be specified only if `encryption_at_rest.enabled` is `true`.
  EOF
  type = object({
    enabled = optional(bool, true)
    kms_key = optional(string)
  })
  default  = {}
  nullable = false
}

variable "encryption_in_transit" {
  description = <<EOF
  (Optional) A configuration for in-transit encryption of the ElastiCache Redis cluster. `encryption_in_transit` as defined below.
    (Optional) `enabled` - Whether to enable in-transit encryption. Defaults to `false`.
    (Optional) `mode` - A setting that enables clients to migrate to in-transit encryption with no downtime. Valid values are `preferred` and `required`. When enabling encryption on an existing replication group, this must first be set to `preferred` before setting it to `required` in a subsequent apply.
  EOF
  type = object({
    enabled = optional(bool, false)
    mode    = optional(string, "preferred")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["preferred", "required"], var.encryption_in_transit.mode)
    error_message = "Valid values for `mode` are `preferred` or `required`."
  }
}

variable "maintenance" {
  description = <<EOF
  (Optional) A configuration for maintenance of the ElastiCache Redis cluster. `maintenance` as defined below.
    (Optional) `window` - The weekly time range for when maintenance on the ElastiCache Redis cluster is performed. The format is `ddd:hh24:mi-ddd:hh24:mi` (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: `sun:05:00-sun:09:00`. Defaults to `fri:18:00-fri:20:00`.
    (Optional) `auto_upgrade_minor_version_enabled` - Whether automatically schedule cluster upgrade to the latest minor version, once it becomes available. Cluster upgrade will only be scheduled during the maintenance window. Defaults to `true`.
    (Optional) `notification_sns_topic` - The ARN of an SNS topic to send ElastiCache notifications to.
  EOF
  type = object({
    window                             = optional(string, "fri:18:00-fri:20:00")
    auto_upgrade_minor_version_enabled = optional(bool, true)
    notification_sns_topic             = optional(string)
  })
  default  = {}
  nullable = false
}

variable "backup" {
  description = <<EOF
  (Optional) A configuration for backup of the ElastiCache Redis cluster. `backup` as defined below.
    (Optional) `enabled` - Whether to automatically create a daily backup of a set of replicas. Defaults to `false`.
    (Optional) `window` - The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of the ElastiCache Redis cluster. The minimum snapshot window is a 60 minute period. Example: 05:00-09:00. Defaults to `16:00-17:00`.
    (Optional) `retention` - The number of days for which automated backups are retained before they are automatically deleted. Valid value is between `1` and `35`. Defaults to 1.
    (Optional) `final_snapshot_name` - The name of your final node group (shard) snapshot. ElastiCache creates the snapshot from the primary node in the cluster when the replication group is deleted. If omitted, no final snapshot will be made.
  EOF
  type = object({
    enabled             = optional(bool, false)
    window              = optional(string, "16:00-17:00")
    retention           = optional(number, 1)
    final_snapshot_name = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.backup.retention >= 1,
      var.backup.retention <= 35,
    ])
    error_message = "The value of `backup.retention` must be between 1 and 35."
  }
}

variable "restore" {
  description = <<EOF
  (Optional) A configuration for source backup of the ElastiCache Redis cluster to restore from. `restore` block as defined below.
    (Optional) `backup_name` - The name of a snapshot from which to restore data into the new node group. Changing the `restore.backup_name` forces a new resource.
    (Optional) `rdb_s3_arns` - A list of ARNs that identify Redis RDB snapshot files stored in Amazon S3. The object names cannot contain any commas.
  EOF
  type = object({
    backup_name = optional(string)
    rdb_s3_arns = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "logging_slow_log" {
  description = <<EOF
  The configuration for streaming Redis Slow Log of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable streaming Redis Slow Log. Defaults to `false`.
    (Optional) `format` - The format of Redis Slow Log. Valid values are `JSON` or `TEXT`. Defaults to `JSON`.
    (Optional) `destination` - A configuration for streaming Redis Slow Log of the ElastiCache Redis cluster. `destination` block as defined below.
       (Optional) `type` - The destination type for streaming Redis Slow Log. For CloudWatch Logs use `CLOUDWATCH_LOGS` or for Kinesis Data Firehose use `KINESIS_FIREHOSE`. Defaults to `CLOUDWATCH_LOGS`.
       (Optional) `name` - The name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.
  EOF
  type = object({
    enabled = optional(bool, false)
    format  = optional(string, "JSON")
    destination = optional(object({
      type = optional(string, "CLOUDWATCH_LOGS")
      name = optional(string)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["TEXT", "JSON"], var.logging_slow_log.format)
    error_message = "Valid value for `format` is `TEXT` or `JSON`."
  }
  validation {
    condition     = contains(["CLOUDWATCH_LOGS", "KINESIS_FIREHOSE"], var.logging_slow_log.destination.type)
    error_message = "Valid value for `destination.type` s `CLOUDWATCH_LOGS` or `KINESIS_FIREHOSE`."
  }
}

variable "logging_engine_log" {
  description = <<EOF
  The configuration for streaming Redis Engine Log of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable streaming Redis Engine Log. Defaults to `false`.
    (Optional) `format` - The format of Redis Engine Log. Valid values are `JSON` or `TEXT`. Defaults to `JSON`.
    (Optional) `destination` - A configuration for streaming Redis Engine Log of the ElastiCache Redis cluster. `destination` block as defined below.
       (Optional) `type` - The destination type for streaming Redis Engine Log. For CloudWatch Logs use `CLOUDWATCH_LOGS` or for Kinesis Data Firehose use `KINESIS_FIREHOSE`. Defaults to `CLOUDWATCH_LOGS`.
       (Optional) `name` - The name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.
  EOF
  type = object({
    enabled = optional(bool, false)
    format  = optional(string, "JSON")
    destination = optional(object({
      type = optional(string, "CLOUDWATCH_LOGS")
      name = optional(string)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["TEXT", "JSON"], var.logging_engine_log.format)
    error_message = "Valid value for `format` is `TEXT` or `JSON`."
  }
  validation {
    condition     = contains(["CLOUDWATCH_LOGS", "KINESIS_FIREHOSE"], var.logging_engine_log.destination.type)
    error_message = "Valid value for `destination.type` s `CLOUDWATCH_LOGS` or `KINESIS_FIREHOSE`."
  }
}

variable "multi_az_enabled" {
  description = "(Optional) Whether to enable Multi-AZ Support for the ElastiCache Redis cluster. If true, `auto_failover_enabled` must also be enabled. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false

  validation {
    condition = anytrue([
      !var.multi_az_enabled,
      var.multi_az_enabled && var.auto_failover_enabled,
    ])
    error_message = "If Muti-AZ Support is enabled, `auto_failover_enabled` must also be enabled."
  }
}

variable "auto_failover_enabled" {
  description = "(Optional) Whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If enabled, `node_size` must be greater than 1. Must be enabled for Redis (cluster mode enabled) cluster. Defaults to `false`. ElastiCache Auto Failover provides enhanced high availability through automatic failover to a read replica in case of a primary node failover."
  type        = bool
  default     = false
  nullable    = false
}

variable "apply_immediately" {
  description = "(Optional) Whether any modifications are applied immediately, or during the next maintenance window. Default to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "global_datastore" {
  description = <<EOF
  (Optional) A configuration for Global Datastore of the ElastiCache Redis cluster. `global_datastore` as defined below.
    (Optional) `enabled` - Whether to enable Global Datastore for the ElastiCache Redis cluster. Defaults to `false`.
    (Optional) `name` - The global datastore that is created is named using an autogenerated prefix and the suffix you provide.
    (Optional) `description` - A user-created description for the global replication group.
  EOF
  type = object({
    enabled     = optional(bool, false)
    name        = optional(string)
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}

variable "timeouts" {
  description = "(Optional) How long to wait for the instance to be created/updated/deleted."
  type = object({
    create = optional(string, "60m")
    update = optional(string, "45m")
    delete = optional(string, "40m")
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}
