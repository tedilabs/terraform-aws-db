variable "name" {
  description = "(Required) The name of the ElastiCache Redis cluster. This parameter is stored as a lowercase string."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the ElastiCache Redis cluster."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "redis_version" {
  description = "(Optional) The version number of Redis to be used for each nodes in the ElastiCache Redis cluster. If the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute `redis_version_actual`."
  type        = string
  default     = "7.0"
  nullable    = false
}

# INFO: https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheNodes.SupportedTypes.html
variable "node_instance_type" {
  description = "(Required) The instance type to be deployed for the ElastiCache Redis cluster."
  type        = string
  nullable    = false
}

variable "node_size" {
  description = "(Optional) The number of cache nodes (primary and replicas) for this ElastiCache Redis cluster will have. If Multi-AZ is enabled, this value must be at least 2. Updates will occur before other modifications. Defaults to `1`."
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

variable "sharding" {
  description = <<EOF
  The configuration for sharding of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable sharding (cluster mode). It enables replication across multiple shards for enhanced scalability and availability. Defaults to `false`.
    (Optional) `shard_size` - The number of shards in this cluster. Valid value is from `1` to `500`. Defaults to `3`.
    (Optional) `replicas` - The number of replicas for each shard. Valid value is from `0` to `5`. Defaults to `2`.
  EOF
  type = object({
    enabled    = optional(bool, false)
    shard_size = optional(number, 3)
    replicas   = optional(number, 2)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.sharding.shard_size >= 1,
      var.sharding.shard_size <= 500,
    ])
    error_message = "The number of shards should be between `1` and `500`."
  }

  validation {
    condition = alltrue([
      var.sharding.replicas >= 0,
      var.sharding.replicas <= 5,
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

variable "vpc_id" {
  description = "(Optional) The ID of the associated VPC. You must provide the `vpc_id` when `default_security_group.enabled` is `true`. It will used to provision the default security group."
  type        = string
  default     = null
}

variable "subnet_group" {
  description = "(Optional) The name of the cache subnet group to be used for the ElastiCache Redis cluster. If not provided, configured to use `default` subnet group in the default VPC."
  type        = string
  default     = null
}

variable "preferred_availability_zones" {
  description = "(Optional) A list of AZs(Availability Zones) in which the ElastiCache Redis cluster nodes will be created. The order of the availability zones in the list is considered. The first item in the list will be the primary node. Ignored when updating."
  type        = list(string)
  default     = []
}

variable "default_security_group" {
  description = <<EOF
  (Optional) The configuration of the default security group for the ElastiCache Redis cluster. `default_security_group` block as defined below.
    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.
    (Optional) `name` - The name of the default security group. If not provided, the cluster name is used for the name of security group.
    (Optional) `description` - The description of the default security group.
    (Optional) `ingress_rules` - A list of ingress rules in a security group. You don't need to specify `protocol`, `from_port`, `to_port`. Just specify source information. Defauls to `[{ cidr_blocks = "0.0.0.0/0" }]`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, null)
    description = optional(string, "Managed by Terraform.")
    ingress_rules = optional(any, [{
      cidr_blocks = ["0.0.0.0/0"]
    }])
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

variable "parameter_group" {
  description = <<EOF
  The configuration for parameter group of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable managed parameter group by this module.
    (Optional) `name` - The name of the managed parameter group. If not provided, the name is configured with the cluster name.
    (Optional) `description` - The description of the managed parameter group.
    (Optional) `parameters` - The key/value set for Redis parameters of ElastiCache Redis cluster. Each key is the name of the redis parameter. Each value is the value of the redis parameter.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "")
    parameters  = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "custom_parameter_group" {
  description = "(Optional) The name of the parameter group to associate with the ElastiCache Redis cluster. If this argument is omitted, the default cache parameter group for the specified engine is used. To enable `cluster mode` (sharding), use a parameter group that has the parameter `cluster-enabled` set to `true`."
  type        = string
  default     = null
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
}

variable "user_groups" {
  description = "(Optional) A set of User Group IDs to associate with the ElastiCache Redis cluster. Only a maximum of one user group ID is valid. The AWS specification allows for multiple IDs, but AWS only allows a maximum size of one."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "encryption_at_rest" {
  description = <<EOF
  The configuration for at-rest encryption of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable at-rest encryption. Defaults to `false`.
    (Optional) `kms_key` - The ARN of the key to use for at-rest encryption. If not supplied, uses service managed encryption key. Can be specified only if `encryption_at_rest.enabled` is `true`.
  EOF
  type = object({
    enabled = optional(bool, false)
    kms_key = optional(string, null)
  })
  default  = {}
  nullable = false
}

variable "encryption_in_transit" {
  description = <<EOF
  The configuration for in-transit encryption of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable in-transit encryption. Defaults to `false`.
  EOF
  type = object({
    enabled = optional(bool, false)
  })
  default  = {}
  nullable = false
}

variable "backup_enabled" {
  description = "(Optional) Whether to automatically create a daily backup of a set of replicas. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "backup_window" {
  description = "(Optional) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of the ElastiCache Redis cluster. The minimum snapshot window is a 60 minute period. Example: 05:00-09:00. Defaults to `16:00-17:00`."
  type        = string
  default     = "16:00-17:00"
  nullable    = false
}

variable "backup_retention" {
  description = "(Optional) The number of days for which automated backups are retained before they are automatically deleted. Valid value is between `1` and `35`. Defaults to 1."
  type        = number
  default     = 1
  nullable    = false

  validation {
    condition = alltrue([
      var.backup_retention >= 1,
      var.backup_retention <= 35,
    ])
    error_message = "The value of `backup_retention` must be between 1 and 35."
  }
}

variable "backup_final_snapshot_name" {
  description = "(Optional) The name of your final node group (shard) snapshot. ElastiCache creates the snapshot from the primary node in the cluster. If omitted, no final snapshot will be made."
  type        = string
  default     = null
}

variable "source_backup_name" {
  description = "(Optional) The name of a snapshot from which to restore data into the new node group. Changing the `source_backup_name` forces a new resource."
  type        = string
  default     = null
}

variable "source_rdb_s3_arns" {
  description = "(Optional) A list of ARNs that identify Redis RDB snapshot files stored in Amazon S3. The object names cannot contain any commas."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "maintenance_window" {
  description = "(Optional) The weekly time range for when maintenance on the ElastiCache Redis cluster is performed. The format is `ddd:hh24:mi-ddd:hh24:mi` (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: `sun:05:00-sun:09:00`. Defaults to `fri:18:00-fri:20:00`."
  type        = string
  default     = "fri:18:00-fri:20:00"
  nullable    = false
}

variable "auto_upgrade_minor_version_enabled" {
  description = "(Optional) Whether automatically schedule cluster upgrade to the latest minor version, once it becomes available. Cluster upgrade will only be scheduled during the maintenance window. Defaults to `true`. Only supported if the redis version is 6 or higher."
  type        = bool
  default     = true
  nullable    = false
}

variable "notification_sns_topic" {
  description = "(Optional) The ARN of an SNS topic to send ElastiCache notifications to."
  type        = string
  default     = null
}

variable "logging_slow_log" {
  description = <<EOF
  The configuration for streaming Redis Slow Log of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable streaming Redis Slow Log. Defaults to `false`.
    (Optional) `format` - The format of Redis Slow Log. Valid values are `JSON` or `TEXT`. Defaults to `JSON`.
    (Optional) `destination_type` - The destination type for streaming Redis Slow Log. For CloudWatch Logs use `CLOUDWATCH_LOGS` or for Kinesis Data Firehose use `KINESIS_FIREHOSE`. Defaults to `CLOUDWATCH_LOGS`.
    (Optional) `destination` - The name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.
  EOF
  type = object({
    enabled          = optional(bool, false)
    format           = optional(string, "JSON")
    destination_type = optional(string, "CLOUDWATCH_LOGS")
    destination      = optional(string, null)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["TEXT", "JSON"], var.logging_slow_log.format)
    error_message = "Valid value for `format` is `TEXT` or `JSON`."
  }
  validation {
    condition     = contains(["CLOUDWATCH_LOGS", "KINESIS_FIREHOSE"], var.logging_slow_log.destination_type)
    error_message = "Valid value for `destination_type` s `CLOUDWATCH_LOGS` or `KINESIS_FIREHOSE`."
  }
}

variable "logging_engine_log" {
  description = <<EOF
  The configuration for streaming Redis Engine Log of the ElastiCache Redis cluster.
    (Optional) `enabled` - Whether to enable streaming Redis Engine Log. Defaults to `false`.
    (Optional) `format` - The format of Redis Engine Log. Valid values are `JSON` or `TEXT`. Defaults to `JSON`.
    (Optional) `destination_type` - The destination type for streaming Redis Engine Log. For CloudWatch Logs use `CLOUDWATCH_LOGS` or for Kinesis Data Firehose use `KINESIS_FIREHOSE`. Defaults to `CLOUDWATCH_LOGS`.
    (Optional) `destination` - The name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource.
  EOF
  type = object({
    enabled          = optional(bool, false)
    format           = optional(string, "JSON")
    destination_type = optional(string, "CLOUDWATCH_LOGS")
    destination      = optional(string, null)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["TEXT", "JSON"], var.logging_engine_log.format)
    error_message = "Valid value for `format` is `TEXT` or `JSON`."
  }
  validation {
    condition     = contains(["CLOUDWATCH_LOGS", "KINESIS_FIREHOSE"], var.logging_engine_log.destination_type)
    error_message = "Valid value for `destination_type` s `CLOUDWATCH_LOGS` or `KINESIS_FIREHOSE`."
  }
}

variable "multi_az_enabled" {
  description = "(Optional) Whether to enable Multi-AZ Support for the ElastiCache Redis cluster. If true, `auto_failover_enabled` must also be enabled. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
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

variable "timeouts" {
  description = "(Optional) How long to wait for the instance to be created/updated/deleted."
  type = object({
    create = optional(string, "60m")
    update = optional(string, "40m")
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
