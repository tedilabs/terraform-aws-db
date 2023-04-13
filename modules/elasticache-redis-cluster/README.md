# elasticache-redis-cluster

This module creates following resources.

- `aws_elasticache_replication_group`
- `aws_elasticache_parameter_group` (optional)
- `aws_security_group` (optional)
- `aws_security_group_rule` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.36 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.34.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | tedilabs/network/aws//modules/security-group | ~> 0.26.0 |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_parameter_group) | resource |
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the ElastiCache Redis cluster. This parameter is stored as a lowercase string. | `string` | n/a | yes |
| <a name="input_node_instance_type"></a> [node\_instance\_type](#input\_node\_instance\_type) | (Required) The instance type to be deployed for the ElastiCache Redis cluster. | `string` | n/a | yes |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | (Optional) Whether any modifications are applied immediately, or during the next maintenance window. Default to `false`. | `bool` | `false` | no |
| <a name="input_auto_failover_enabled"></a> [auto\_failover\_enabled](#input\_auto\_failover\_enabled) | (Optional) Whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If enabled, `node_size` must be greater than 1. Must be enabled for Redis (cluster mode enabled) cluster. Defaults to `false`. ElastiCache Auto Failover provides enhanced high availability through automatic failover to a read replica in case of a primary node failover. | `bool` | `false` | no |
| <a name="input_auto_upgrade_minor_version_enabled"></a> [auto\_upgrade\_minor\_version\_enabled](#input\_auto\_upgrade\_minor\_version\_enabled) | (Optional) Whether automatically schedule cluster upgrade to the latest minor version, once it becomes available. Cluster upgrade will only be scheduled during the maintenance window. Defaults to `true`. Only supported if the redis version is 6 or higher. | `bool` | `true` | no |
| <a name="input_backup_enabled"></a> [backup\_enabled](#input\_backup\_enabled) | (Optional) Whether to automatically create a daily backup of a set of replicas. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_backup_final_snapshot_name"></a> [backup\_final\_snapshot\_name](#input\_backup\_final\_snapshot\_name) | (Optional) The name of your final node group (shard) snapshot. ElastiCache creates the snapshot from the primary node in the cluster. If omitted, no final snapshot will be made. | `string` | `null` | no |
| <a name="input_backup_retention"></a> [backup\_retention](#input\_backup\_retention) | (Optional) The number of days for which automated backups are retained before they are automatically deleted. Valid value is between `1` and `35`. Defaults to 1. | `number` | `1` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | (Optional) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of the ElastiCache Redis cluster. The minimum snapshot window is a 60 minute period. Example: 05:00-09:00. Defaults to `16:00-17:00`. | `string` | `"16:00-17:00"` | no |
| <a name="input_custom_parameter_group"></a> [custom\_parameter\_group](#input\_custom\_parameter\_group) | (Optional) The name of the parameter group to associate with the ElastiCache Redis cluster. If this argument is omitted, the default cache parameter group for the specified engine is used. To enable `cluster mode` (sharding), use a parameter group that has the parameter `cluster-enabled` set to `true`. | `string` | `null` | no |
| <a name="input_default_security_group"></a> [default\_security\_group](#input\_default\_security\_group) | (Optional) The configuration of the default security group for the ElastiCache Redis cluster. `default_security_group` block as defined below.<br>    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.<br>    (Optional) `name` - The name of the default security group. If not provided, the cluster name is used for the name of security group.<br>    (Optional) `description` - The description of the default security group.<br>    (Optional) `ingress_rules` - A list of ingress rules in a security group. You don't need to specify `protocol`, `from_port`, `to_port`. Just specify source information. Defauls to `[{ cidr_blocks = "0.0.0.0/0" }]`. | <pre>object({<br>    enabled     = optional(bool, true)<br>    name        = optional(string, null)<br>    description = optional(string, "Managed by Terraform.")<br>    ingress_rules = optional(any, [{<br>      cidr_blocks = ["0.0.0.0/0"]<br>    }])<br>  })</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the ElastiCache Redis cluster. | `string` | `"Managed by Terraform."` | no |
| <a name="input_encryption_at_rest"></a> [encryption\_at\_rest](#input\_encryption\_at\_rest) | The configuration for at-rest encryption of the ElastiCache Redis cluster.<br>    (Optional) `enabled` - Whether to enable at-rest encryption. Defaults to `false`.<br>    (Optional) `kms_key` - The ARN of the key to use for at-rest encryption. If not supplied, uses service managed encryption key. Can be specified only if `encryption_at_rest.enabled` is `true`. | <pre>object({<br>    enabled = optional(bool, false)<br>    kms_key = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_encryption_in_transit"></a> [encryption\_in\_transit](#input\_encryption\_in\_transit) | The configuration for in-transit encryption of the ElastiCache Redis cluster.<br>    (Optional) `enabled` - Whether to enable in-transit encryption. Defaults to `false`. | <pre>object({<br>    enabled = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_logging_engine_log"></a> [logging\_engine\_log](#input\_logging\_engine\_log) | The configuration for streaming Redis Engine Log of the ElastiCache Redis cluster.<br>    (Optional) `enabled` - Whether to enable streaming Redis Engine Log. Defaults to `false`.<br>    (Optional) `format` - The format of Redis Engine Log. Valid values are `JSON` or `TEXT`. Defaults to `JSON`.<br>    (Optional) `destination_type` - The destination type for streaming Redis Engine Log. For CloudWatch Logs use `CLOUDWATCH_LOGS` or for Kinesis Data Firehose use `KINESIS_FIREHOSE`. Defaults to `CLOUDWATCH_LOGS`.<br>    (Optional) `destination` - The name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource. | <pre>object({<br>    enabled          = optional(bool, false)<br>    format           = optional(string, "JSON")<br>    destination_type = optional(string, "CLOUDWATCH_LOGS")<br>    destination      = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_logging_slow_log"></a> [logging\_slow\_log](#input\_logging\_slow\_log) | The configuration for streaming Redis Slow Log of the ElastiCache Redis cluster.<br>    (Optional) `enabled` - Whether to enable streaming Redis Slow Log. Defaults to `false`.<br>    (Optional) `format` - The format of Redis Slow Log. Valid values are `JSON` or `TEXT`. Defaults to `JSON`.<br>    (Optional) `destination_type` - The destination type for streaming Redis Slow Log. For CloudWatch Logs use `CLOUDWATCH_LOGS` or for Kinesis Data Firehose use `KINESIS_FIREHOSE`. Defaults to `CLOUDWATCH_LOGS`.<br>    (Optional) `destination` - The name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource. | <pre>object({<br>    enabled          = optional(bool, false)<br>    format           = optional(string, "JSON")<br>    destination_type = optional(string, "CLOUDWATCH_LOGS")<br>    destination      = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) The weekly time range for when maintenance on the ElastiCache Redis cluster is performed. The format is `ddd:hh24:mi-ddd:hh24:mi` (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: `sun:05:00-sun:09:00`. Defaults to `fri:18:00-fri:20:00`. | `string` | `"fri:18:00-fri:20:00"` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_multi_az_enabled"></a> [multi\_az\_enabled](#input\_multi\_az\_enabled) | (Optional) Whether to enable Multi-AZ Support for the ElastiCache Redis cluster. If true, `auto_failover_enabled` must also be enabled. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_node_size"></a> [node\_size](#input\_node\_size) | (Optional) The number of cache nodes (primary and replicas) for this ElastiCache Redis cluster will have. If Multi-AZ is enabled, this value must be at least 2. Updates will occur before other modifications. Defaults to `1`. | `number` | `1` | no |
| <a name="input_notification_sns_topic"></a> [notification\_sns\_topic](#input\_notification\_sns\_topic) | (Optional) The ARN of an SNS topic to send ElastiCache notifications to. | `string` | `null` | no |
| <a name="input_parameter_group"></a> [parameter\_group](#input\_parameter\_group) | The configuration for parameter group of the ElastiCache Redis cluster.<br>    (Optional) `enabled` - Whether to enable managed parameter group by this module.<br>    (Optional) `name` - The name of the managed parameter group. If not provided, the name is configured with the cluster name.<br>    (Optional) `description` - The description of the managed parameter group.<br>    (Optional) `parameters` - The key/value set for Redis parameters of ElastiCache Redis cluster. Each key is the name of the redis parameter. Each value is the value of the redis parameter. | <pre>object({<br>    enabled     = optional(bool, true)<br>    name        = optional(string, "")<br>    description = optional(string, "")<br>    parameters  = optional(map(string), {})<br>  })</pre> | `{}` | no |
| <a name="input_password"></a> [password](#input\_password) | (Optional) Password used to access a password protected ElastiCache Redis cluster. Can be specified only if `encryption_in_transit.enabled` is `true`. | `string` | `""` | no |
| <a name="input_port"></a> [port](#input\_port) | (Optional) The port number on which each of the cache nodes will accept connections. The default port is `6379`. | `number` | `6379` | no |
| <a name="input_preferred_availability_zones"></a> [preferred\_availability\_zones](#input\_preferred\_availability\_zones) | (Optional) A list of AZs(Availability Zones) in which the ElastiCache Redis cluster nodes will be created. The order of the availability zones in the list is considered. The first item in the list will be the primary node. Ignored when updating. | `list(string)` | `[]` | no |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | (Optional) The version number of Redis to be used for each nodes in the ElastiCache Redis cluster. If the version is 6 or higher, the major and minor version can be set, e.g., 6.2, or the minor version can be unspecified which will use the latest version at creation time, e.g., 6.x. Otherwise, specify the full version desired, e.g., 5.0.6. The actual engine version used is returned in the attribute `redis_version_actual`. | `string` | `"7.0"` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | (Optional) A list of security group IDs to assign to the instance. | `list(string)` | `[]` | no |
| <a name="input_sharding"></a> [sharding](#input\_sharding) | The configuration for sharding of the ElastiCache Redis cluster.<br>    (Optional) `enabled` - Whether to enable sharding (cluster mode). It enables replication across multiple shards for enhanced scalability and availability. Defaults to `false`.<br>    (Optional) `shard_size` - The number of shards in this cluster. Valid value is from `1` to `500`. Defaults to `3`.<br>    (Optional) `replicas` - The number of replicas for each shard. Valid value is from `0` to `5`. Defaults to `2`. | <pre>object({<br>    enabled    = optional(bool, false)<br>    shard_size = optional(number, 3)<br>    replicas   = optional(number, 2)<br>  })</pre> | `{}` | no |
| <a name="input_source_backup_name"></a> [source\_backup\_name](#input\_source\_backup\_name) | (Optional) The name of a snapshot from which to restore data into the new node group. Changing the `source_backup_name` forces a new resource. | `string` | `null` | no |
| <a name="input_source_rdb_s3_arns"></a> [source\_rdb\_s3\_arns](#input\_source\_rdb\_s3\_arns) | (Optional) A list of ARNs that identify Redis RDB snapshot files stored in Amazon S3. The object names cannot contain any commas. | `list(string)` | `[]` | no |
| <a name="input_subnet_group"></a> [subnet\_group](#input\_subnet\_group) | (Optional) The name of the cache subnet group to be used for the ElastiCache Redis cluster. If not provided, configured to use `default` subnet group in the default VPC. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | (Optional) How long to wait for the instance to be created/updated/deleted. | <pre>object({<br>    create = optional(string, "60m")<br>    update = optional(string, "40m")<br>    delete = optional(string, "40m")<br>  })</pre> | `{}` | no |
| <a name="input_user_groups"></a> [user\_groups](#input\_user\_groups) | (Optional) A set of User Group IDs to associate with the ElastiCache Redis cluster. Only a maximum of one user group ID is valid. The AWS specification allows for multiple IDs, but AWS only allows a maximum size of one. | `set(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Optional) The ID of the associated VPC. You must provide the `vpc_id` when `default_security_group.enabled` is `true`. It will used to provision the default security group. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the ElastiCache Redis cluster. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | A set of attributes that applied to the ElastiCache Redis cluster. |
| <a name="output_auth"></a> [auth](#output\_auth) | The configuration for auth of the ElastiCache Redis cluster.<br>    `user_groups` - A set of User Group IDs to associate with the ElastiCache Redis cluster. |
| <a name="output_backup"></a> [backup](#output\_backup) | The configuration for backup of the ElastiCache Redis cluster.<br>    `enabled` - Whether to automatically create a daily backup of a set of replicas.<br>    `window` - The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of the ElastiCache Redis cluster.<br>    `retention` - The number of days for which automated backups are retained before they are automatically deleted. |
| <a name="output_description"></a> [description](#output\_description) | The description of the ElastiCache Redis cluster. |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The configuration for encryption of the ElastiCache Redis cluster.<br>    `at_rest` - The configuration for at-rest encryption.<br>    `in_transit` - The configuration for in-transit encryption. |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | The connection endpoints to the ElastiCache Redis cluster.<br>    `primary` - Address of the endpoint for the primary node in the cluster, if the cluster mode is disabled.<br>    `reader` - Address of the endpoint for the reader node in the cluster, if the cluster mode is disabled.<br>    `configuration` - Address of the replication group configuration endpoint when cluster mode is enabled. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the ElastiCache Redis cluster. |
| <a name="output_logging"></a> [logging](#output\_logging) | The configuration for logging of the ElastiCache Redis cluster.<br>    `slow_log` - The configuration for streaming Redis Slow Log.<br>    `engine_log` - The configuration for streaming Redis Engine Log. |
| <a name="output_maintenance"></a> [maintenance](#output\_maintenance) | The configuration for maintenance of the ElastiCache Redis cluster.<br>    `window` - The weekly time range for when maintenance on the ElastiCache Redis cluster is performed.<br>    `auto_upgrade_minor_version_enabled` - Whether automatically schedule cluster upgrade to the latest minor version, once it becomes available.<br>    `notification_sns_arn` - The ARN of an SNS topic to send ElastiCache notifications to. |
| <a name="output_name"></a> [name](#output\_name) | The name of the ElastiCache Redis cluster. |
| <a name="output_network"></a> [network](#output\_network) | The configuration for network of the ElastiCache Redis cluster.<br>    `port` - The port number on each cache nodes to accept connections.<br>    `subnet_group` - The name of the cache subnet group used for.<br>    `preferred_availability_zones` - The list of AZs(Availability Zones) in which the ElastiCache Redis cluster nodes will be created. |
| <a name="output_node_instance_type"></a> [node\_instance\_type](#output\_node\_instance\_type) | The instance type used for the ElastiCache Redis cluster. |
| <a name="output_node_size"></a> [node\_size](#output\_node\_size) | The number of cache nodes (primary and replicas) for this ElastiCache Redis cluster will have. |
| <a name="output_nodes"></a> [nodes](#output\_nodes) | The list of all nodes are part of the ElastiCache Redis cluster. |
| <a name="output_parameter_group"></a> [parameter\_group](#output\_parameter\_group) | The name of the parameter group associated with the ElastiCache Redis cluster. |
| <a name="output_redis_version"></a> [redis\_version](#output\_redis\_version) | The version number of Redis used for the ElastiCache Redis cluster. The actual engine version used is returned in `redis_version_actual`. |
| <a name="output_redis_version_actual"></a> [redis\_version\_actual](#output\_redis\_version\_actual) | The actual version number of Redis used for the ElastiCache Redis cluster. Because ElastiCache pulls the latest minor or patch for a version, this attribute returns the running version of the cache engine. |
| <a name="output_sharding"></a> [sharding](#output\_sharding) | The configuration for sharding of the ElastiCache Redis cluster. |
| <a name="output_source"></a> [source](#output\_source) | The configuration for source backup of the ElastiCache Redis cluster to restore from.<br>    `backup_name` - The name of a snapshot from which to restore data into the new node group.<br>    `rdb_s3_arns` - The list of ARNs that identify Redis RDB snapshot files stored in Amazon S3. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
