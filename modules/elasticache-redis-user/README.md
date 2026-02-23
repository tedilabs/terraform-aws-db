# elasticache-redis-user

This module creates following resources.

- `aws_elasticache_user`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_id"></a> [id](#input\_id) | (Required) The ID of the ElastiCache user. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The username of the ElastiCache user. It can have up to 40 characters, and must begin with a letter. It should not end with a hyphen or contain two consecutive hyphens. Valid characters: A-Z, a-z, 0-9, and - (hyphen). | `string` | n/a | yes |
| <a name="input_access_string"></a> [access\_string](#input\_access\_string) | (Optional) Access permissions string used for this user. Defaults to `off -@all`. | `string` | `"off -@all"` | no |
| <a name="input_authentication"></a> [authentication](#input\_authentication) | (Optional) A configuration of authentication for this user. `authentication` as defined below.<br/>    (Optional) `mode` - The authentication mode. Valid values are `iam`, `no-password-required`, and `password`. Defaults to `no-password`.<br/>    (Optional) `passwords` - A set of passwords used for this user. You can create up to two passwords for each user. Required if `mode` is set to `password`. | <pre>object({<br/>    mode      = optional(string, "no-password-required")<br/>    passwords = optional(set(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | (Optional) The cache engine for the ElastiCache user. Valid values are `redis` and `valkey`. Defaults to `valkey`. | `string` | `"valkey"` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_string"></a> [access\_string](#output\_access\_string) | Access permissions string used for this user. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the ElastiCache user. |
| <a name="output_authentication"></a> [authentication](#output\_authentication) | The authentication configuration for this user. |
| <a name="output_engine"></a> [engine](#output\_engine) | The cache engine used by the ElastiCache user. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the ElastiCache user. |
| <a name="output_name"></a> [name](#output\_name) | The name of the ElastiCache user. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
