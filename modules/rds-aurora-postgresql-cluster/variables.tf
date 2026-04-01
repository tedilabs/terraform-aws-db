variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the Aurora PostgreSQL cluster. Used as the cluster identifier."
  type        = string
  nullable    = false

  validation {
    condition = alltrue([
      length(var.name) >= 1,
      length(var.name) <= 63,
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.name)),
    ])
    error_message = "The cluster identifier must be 1-63 characters, start with a letter, end with a letter or digit, and only contain lowercase letters, digits, and hyphens."
  }
}

variable "engine_version" {
  description = "(Required) The Aurora PostgreSQL engine version. For example, `16.6`, `15.10`, `14.15`."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.engine_version))
    error_message = "The engine version must be in the format `MAJOR.MINOR` (e.g., `16.6`)."
  }
}

variable "extended_support_enabled" {
  description = "(Optional) Whether to enable RDS Extended Support for the cluster. When disabled, the cluster will be automatically upgraded to a higher engine version if the minor engine version is past the end of standard support date. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Database
###################################################

variable "database" {
  description = "(Optional) The name of the database to create when the cluster is created. If not specified, no database is created."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (var.database != null
      ? can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database))
      : true
    )
    error_message = "The database name must begin with a letter, and contain only alphanumeric characters and underscores."
  }
}

variable "port" {
  description = "(Optional) The port on which the DB accepts connections. Defaults to `5432`."
  type        = number
  default     = 5432
  nullable    = false

  validation {
    condition = alltrue([
      var.port >= 1150,
      var.port <= 65535,
    ])
    error_message = "Valid value for `port` is between `1150` and `65535`."
  }
}

variable "admin_user" {
  description = <<EOF
  (Optional) The master user configuration. `admin_user` as defined below.
    (Optional) `username` - The master username for the Aurora cluster. Defaults to `postgres`.
    (Optional) `password` - A configuration for the master user password. `password` as defined below.
      (Optional) `mode` - The mode for managing the master user password. Valid values are `SECRETS_MANAGER`. When `SECRETS_MANAGER`, the password is stored in AWS Secrets Manager. Additional charges apply for `SECRETS_MANAGER`. Defaults to `SECRETS_MANAGER`.

      Managing master user passwords with Secrets Manager isn't supported for the following features:
      - Amazon RDS Blue/Green Deployments
      - DB clusters that are part of an Aurora global database
      - Aurora Serverless v1 DB clusters
      - Cross-Region read replicas
      - Binary log external replication

      (Optional) `secrets_manager_secret` - A configuration for the AWS Secrets Manager secret to store the master user password when `mode` is `SECRETS_MANAGER`. `secrets_manager_secret` as defined below.
        (Optional) `kms_key` - The ARN of the KMS key used to encrypt the master user password secret in AWS Secrets Manager. If not specified, the default KMS key for Secrets Manager is used.
  EOF
  type = object({
    username = optional(string, "postgres")
    password = optional(object({
      mode = optional(string, "SECRETS_MANAGER")
      secrets_manager_secret = optional(object({
        kms_key = optional(string)
      }))
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["SECRETS_MANAGER"], var.admin_user.password.mode)
    error_message = "Valid values for `admin_user.password.mode` are `SECRETS_MANAGER`."
  }
}


###################################################
# Network
###################################################

variable "subnet_group" {
  description = "(Required) The name of the DB subnet group to be used for the RDS Aurora PostgreSQL cluster."
  type        = string
  nullable    = false
}

variable "availability_zones" {
  description = "(Optional) A set of AZs(Availability Zones) which the DB cluster instances will be created. RDS automatically assigns 3 AZs if less than 3 AZs are configured."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "network_type" {
  description = "(Optional) The network type of the cluster. Valid values are `IPV4` and `DUAL`. Defaults to `IPV4`."
  type        = string
  default     = "IPV4"
  nullable    = false

  validation {
    condition     = contains(["IPV4", "DUAL"], var.network_type)
    error_message = "Valid values for `network_type` are `IPV4`, `DUAL`."
  }
}

variable "vpc_security_groups" {
  description = "(Optional) A list of VPC security group IDs to associate with the cluster."
  type        = list(string)
  default     = []
  nullable    = false
}


###################################################
# Storage
###################################################

variable "storage_type" {
  description = "(Optional) The storage type for the Aurora cluster. Valid values are `aurora` (standard) and `aurora-iopt1` (I/O Optimized). Defaults to `aurora`."
  type        = string
  default     = "aurora"
  nullable    = false

  validation {
    condition     = contains(["aurora", "aurora-iopt1"], var.storage_type)
    error_message = "Valid values for `storage_type` are `aurora`, `aurora-iopt1`."
  }
}

variable "allocated_storage" {
  description = "(Optional) The amount of storage in gibibytes (GiB) to allocate. Only applicable when `storage_type` is `aurora-iopt1`."
  type        = number
  default     = null
  nullable    = true
}

variable "iops" {
  description = "(Optional) The amount of Provisioned IOPS to be initially allocated. Only applicable when `storage_type` is `aurora-iopt1`."
  type        = number
  default     = null
  nullable    = true
}

variable "storage_encryption_kms_key" {
  description = "(Optional) The ARN of the KMS key used to encrypt the cluster storage. If not specified, the default RDS KMS key is used."
  type        = string
  default     = null
  nullable    = true
}


###################################################
# Cluster Parameter Group
###################################################

variable "cluster_parameter_group" {
  description = <<EOF
  (Optional) A configuration of the cluster parameter group. `cluster_parameter_group` as defined below.
    (Optional) `create` - Whether to create a new cluster parameter group. Defaults to `false`.
    (Optional) `name` - The name of the cluster parameter group. When `create` is `true` and `name` is not provided, defaults to `$${cluster_name}-cluster`. When `create` is `false`, the name of an existing cluster parameter group to use.
    (Optional) `family` - The family of the cluster parameter group. Required when `create` is `true`. For example, `aurora-postgresql16`.
    (Optional) `description` - The description of the cluster parameter group.
    (Optional) `parameters` - A list of parameter objects to apply. Each object has `name`, `value`, and optional `apply_method` (`immediate` or `pending-reboot`).
  EOF
  type = object({
    create      = optional(bool, false)
    name        = optional(string)
    family      = optional(string)
    description = optional(string, "Managed by Terraform.")
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate")
    })), [])
  })
  default  = {}
  nullable = false

  validation {
    condition = (var.cluster_parameter_group.create
      ? var.cluster_parameter_group.family != null
      : true
    )
    error_message = "The `family` is required when `create` is `true`."
  }
  validation {
    condition = alltrue([
      for param in var.cluster_parameter_group.parameters :
      contains(["immediate", "pending-reboot"], param.apply_method)
    ])
    error_message = "Valid values for `apply_method` are `immediate`, `pending-reboot`."
  }
}


###################################################
# DB Parameter Group (Instance Level)
###################################################

variable "db_parameter_group" {
  description = <<EOF
  (Optional) A configuration of the DB parameter group for instances. `db_parameter_group` as defined below.
    (Optional) `create` - Whether to create a new DB parameter group. Defaults to `false`.
    (Optional) `name` - The name of the DB parameter group. When `create` is `true` and `name` is not provided, defaults to `$${cluster_name}-instance`. When `create` is `false`, the name of an existing DB parameter group to use.
    (Optional) `family` - The family of the DB parameter group. Required when `create` is `true`. For example, `aurora-postgresql16`.
    (Optional) `description` - The description of the DB parameter group.
    (Optional) `parameters` - A list of parameter objects to apply. Each object has `name`, `value`, and optional `apply_method` (`immediate` or `pending-reboot`).
  EOF
  type = object({
    create      = optional(bool, false)
    name        = optional(string)
    family      = optional(string)
    description = optional(string, "Managed by Terraform.")
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate")
    })), [])
  })
  default  = {}
  nullable = false

  validation {
    condition = (var.db_parameter_group.create
      ? var.db_parameter_group.family != null
      : true
    )
    error_message = "The `family` is required when `create` is `true`."
  }
  validation {
    condition = alltrue([
      for param in var.db_parameter_group.parameters :
      contains(["immediate", "pending-reboot"], param.apply_method)
    ])
    error_message = "Valid values for `apply_method` are `immediate`, `pending-reboot`."
  }
}


###################################################
# Instances
###################################################

variable "instances" {
  description = <<EOF
  (Required) A list of Aurora cluster instances to create. Each item as defined below.
    (Required) `identifier` - The identifier for the cluster instance.
    (Required) `instance_class` - The instance class to use. For example, `db.r6g.large`, `db.serverless`.
    (Optional) `availability_zone` - The EC2 Availability Zone that the instance is created in.
    (Optional) `publicly_accessible` - Whether the instance is publicly accessible. Defaults to `false`.
    (Optional) `promotion_tier` - The failover priority for the instance. A lower tier is preferred. Valid values are `0`-`15`. Defaults to `0`.
    (Optional) `monitoring_interval` - The interval, in seconds, between points when Enhanced Monitoring metrics are collected. Valid values are `0`, `1`, `5`, `10`, `15`, `30`, `60`. Overrides the cluster-level `monitoring.interval`.
    (Optional) `monitoring_role_arn` - The ARN for the IAM role for Enhanced Monitoring. Overrides the cluster-level `monitoring.role_arn`.
    (Optional) `performance_insights_enabled` - Whether Performance Insights is enabled. Overrides the cluster-level `performance_insights.enabled`.
    (Optional) `performance_insights_retention_period` - The number of days to retain Performance Insights data. Overrides the cluster-level `performance_insights.retention_period`.
    (Optional) `performance_insights_kms_key` - The ARN of the KMS key for Performance Insights data encryption. Overrides the cluster-level `performance_insights.kms_key`.
    (Optional) `preferred_maintenance_window` - The window to perform maintenance in. Overrides the cluster-level `preferred_maintenance_window`.
    (Optional) `auto_minor_version_upgrade` - Whether minor engine upgrades will be applied automatically during the maintenance window. Overrides the cluster-level `auto_minor_version_upgrade`.
  EOF
  type = list(object({
    identifier     = string
    instance_class = string

    availability_zone   = optional(string)
    publicly_accessible = optional(bool, false)
    promotion_tier      = optional(number, 0)

    monitoring_interval = optional(number)
    monitoring_role_arn = optional(string)

    performance_insights_enabled          = optional(bool)
    performance_insights_retention_period = optional(number)
    performance_insights_kms_key          = optional(string)

    preferred_maintenance_window = optional(string)
    auto_minor_version_upgrade   = optional(bool)
  }))
  default  = []
  nullable = false

  # validation {
  #   condition     = length(var.instances) > 0
  #   error_message = "At least one instance must be defined."
  # }
  validation {
    condition     = length(distinct(var.instances[*].identifier)) == length(var.instances)
    error_message = "Each instance `identifier` must be unique."
  }
  validation {
    condition = alltrue([
      for instance in var.instances :
      instance.promotion_tier >= 0 && instance.promotion_tier <= 15
    ])
    error_message = "Valid values for `promotion_tier` are between `0` and `15`."
  }
}


###################################################
# Backup & Maintenance
###################################################

variable "maintenance" {
  description = <<EOF
  (Optional) A configuration for maintenance of the RDS Aurora cluster. `maintenance` as defined below.
    (Optional) `window` - The weekly time range for when maintenance on the RDS Aurora cluster is performed. The format is `ddd:hh24:mi-ddd:hh24:mi` (24H Clock UTC). Example: `sun:05:00-sun:09:00`. Defaults to `fri:18:00-fri:20:00`.
  EOF
  type = object({
    window = optional(string, "fri:18:00-fri:20:00")
  })
  default  = {}
  nullable = false
}

variable "backup" {
  description = <<EOF
  (Optional) A configuration for backup of the RDS Aurora cluster. `backup` as defined below.
    (Optional) `window` - The daily time range (in UTC) during which automated backups are created. The minimum snapshot window is a 30 minute period. Must not overlap with `maintenance.window`. Example: 05:00-09:00. Defaults to `16:00-16:30`.
    (Optional) `retention` - The number of days for which automated backups are retained before they are automatically deleted. Valid value is between `1` and `35`. Aurora offers 1-day backup retention for free! Defaults to `1`.
    (Optional) `copy_tags_to_snapshot` - Whether to copy all cluster tags to snapshots. Defaults to `true`.
    (Optional) `final_snapshot` - A configuration for the final snapshot. `final_snapshot` as defined below.
       (Optional) `enabled` - Whether to create a final snapshot before the DB cluster is deleted. Defaults to `true`.
       (Optional) `name` - The name of your final DB snapshot when this DB cluster is deleted. Defaults to `$${cluster_name}-final`.
  EOF
  type = object({
    window                = optional(string, "16:00-16:30")
    retention             = optional(number, 1)
    copy_tags_to_snapshot = optional(bool, true)
    final_snapshot = optional(object({
      enabled = optional(bool, true)
      name    = optional(string)
    }), {})
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

variable "auto_minor_version_upgrade" {
  description = "(Optional) Whether minor engine upgrades will be applied automatically to instances during the maintenance window. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Deletion Protection
###################################################

variable "deletion_protection_enabled" {
  description = "(Optional) Whether deletion protection is enabled on the cluster. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false
}

variable "allow_major_version_upgrade" {
  description = "(Optional) Whether to allow major engine version upgrades when changing engine versions. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}


###################################################
# CloudWatch Logs Export
###################################################

variable "cloudwatch_log_exports" {
  description = "(Optional) A set of log types to enable exporting to CloudWatch Logs. Valid values for Aurora PostgreSQL are `postgresql`. Defaults to `[]`."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for log_type in var.cloudwatch_log_exports :
      contains(["postgresql"], log_type)
    ])
    error_message = "Valid values for `cloudwatch_log_exports` are `postgresql`."
  }
}


###################################################
# IAM Database Authentication
###################################################

variable "iam_database_authentication_enabled" {
  description = "(Optional) Whether to enable IAM database authentication for the cluster. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}


###################################################
# Monitoring (Cluster-level Defaults)
###################################################

variable "monitoring" {
  description = <<EOF
  (Optional) A cluster-level default configuration for Enhanced Monitoring. Can be overridden per instance. `monitoring` as defined below.
    (Optional) `interval` - The interval, in seconds, between points when Enhanced Monitoring metrics are collected. Valid values are `0`, `1`, `5`, `10`, `15`, `30`, `60`. `0` disables Enhanced Monitoring. Defaults to `0`.
    (Optional) `role_arn` - The ARN for the IAM role that permits RDS to send Enhanced Monitoring metrics to CloudWatch Logs.
  EOF
  type = object({
    interval = optional(number, 0)
    role_arn = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring.interval)
    error_message = "Valid values for `monitoring.interval` are `0`, `1`, `5`, `10`, `15`, `30`, `60`."
  }
  validation {
    condition = (var.monitoring.interval > 0
      ? var.monitoring.role_arn != null
      : true
    )
    error_message = "The `monitoring.role_arn` is required when `monitoring.interval` is greater than `0`."
  }
}


###################################################
# Performance Insights (Cluster-level Defaults)
###################################################

variable "performance_insights" {
  description = <<EOF
  (Optional) A cluster-level default configuration for Performance Insights. Can be overridden per instance. `performance_insights` as defined below.
    (Optional) `enabled` - Whether Performance Insights is enabled. Defaults to `false`.
    (Optional) `retention_period` - The number of days to retain Performance Insights data. Valid values are `7`, `31`, `62`, `93`, `124`, `155`, `186`, `217`, `248`, `279`, `310`, `341`, `372`, `403`, `434`, `465`, `496`, `527`, `558`, `589`, `620`, `651`, `682`, `713`, `731`. Defaults to `7`.
    (Optional) `kms_key` - The ARN of the KMS key used to encrypt Performance Insights data.
  EOF
  type = object({
    enabled          = optional(bool, false)
    retention_period = optional(number, 7)
    kms_key          = optional(string)
  })
  default  = {}
  nullable = false
}


###################################################
# Serverless v2 Scaling
###################################################

variable "serverless_v2_scaling" {
  description = <<EOF
  (Optional) A configuration for Aurora Serverless v2 scaling. Required when any instance uses `db.serverless` instance class. `serverless_v2_scaling` as defined below.
    (Required) `min_capacity` - The minimum capacity for an Aurora Serverless v2 DB instance. Must be between `0` and `256` in increments of `0.5`.
    (Required) `max_capacity` - The maximum capacity for an Aurora Serverless v2 DB instance. Must be between `0.5` and `256` in increments of `0.5`.
    (Optional) `seconds_until_auto_pause` - The number of seconds before an Aurora Serverless v2 instance is paused. Only valid when `min_capacity` is `0`. Valid values are between `300` and `86400`. Defaults to `300`.
  EOF
  type = object({
    min_capacity             = number
    max_capacity             = number
    seconds_until_auto_pause = optional(number, 300)
  })
  default  = null
  nullable = true
}

variable "custom_endpoints" {
  description = <<EOF
  (Optional) A list of custom endpoints for the Aurora cluster. Each item of `custom_endpoints` as defined below.
    (Required) `name` - The name of the custom endpoint. Used as the custom endpoint identifier. Must be lowercase.
    (Required) `type` - The type of the custom endpoint. Valid values are `READER`, `ANY`.
    (Optional) `selector` - A configuration for the custom endpoint selector. `selector` as defined below.
      (Optional) `mode` - The mode for selecting instances for the custom endpoint. Valid values are `STATIC`, `EXCEPT`. Defaults to `STATIC`.
      (Optional) `instances` - A set of instance identifiers to be included or excluded in the custom endpoint based on the `mode`. When `mode` is `STATIC`, the instances in `instances` are included in the custom endpoint. When `mode` is `EXCEPT`, the instances in `instances` are excluded from the custom endpoint. Must have at least one instance identifier when `mode` is `STATIC`.
    (Optional) `tags` - A map of tags to add to the custom endpoint.
  EOF
  type = list(object({
    name = string
    type = string
    selector = optional(object({
      mode      = optional(string, "STATIC")
      instances = optional(set(string), [])
    }), {})
    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for endpoint in var.custom_endpoints :
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", endpoint.name))
    ])
    error_message = "Each custom endpoint `name` must start with a letter, end with a letter or digit, and only contain lowercase letters, digits, and hyphens."
  }
  validation {
    condition = alltrue([
      for endpoint in var.custom_endpoints :
      contains(["READER", "ANY"], endpoint.type)
    ])
    error_message = "Valid values for custom endpoint `type` are `READER`, `ANY`."
  }
  validation {
    condition = alltrue([
      for endpoint in var.custom_endpoints :
      contains(["STATIC", "EXCEPT"], endpoint.selector.mode)
    ])
    error_message = "Valid values for custom endpoint selector `mode` are `STATIC`, `EXCEPT`."
  }
  validation {
    condition = alltrue([
      for endpoint in var.custom_endpoints :
      length(endpoint.selector.instances) > 0
      if endpoint.selector.mode == "STATIC"
    ])
    error_message = "When `selector.mode` is `STATIC`, `selector.instances` must have at least one instance identifier."
  }
}

variable "timeouts" {
  description = "(Optional) How long to wait for the cluster to be created/updated/deleted."
  type = object({
    create = optional(string, "120m")
    update = optional(string, "120m")
    delete = optional(string, "120m")
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


###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

variable "shares" {
  description = "(Optional) A list of resource shares via RAM (Resource Access Manager)."
  type = list(object({
    name = string

    permissions = optional(set(string), ["AWSRAMDefaultPermissionRDSCluster"])

    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false
}
