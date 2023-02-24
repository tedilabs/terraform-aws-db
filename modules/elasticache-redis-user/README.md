# elasticache-redis-user

This module creates following resources.

- `aws_elasticache_user`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.34.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

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
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_password_required"></a> [password\_required](#input\_password\_required) | (Optional) Whether a password is required for this user. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_passwords"></a> [passwords](#input\_passwords) | (Optional) A set of passwords used for this user. You can create up to two passwords for each user. | `set(string)` | `[]` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_string"></a> [access\_string](#output\_access\_string) | Access permissions string used for this user. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the ElastiCache user. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the ElastiCache user. |
| <a name="output_name"></a> [name](#output\_name) | The name of the ElastiCache user. |
| <a name="output_password_required"></a> [password\_required](#output\_password\_required) | Whether a password is required for this user. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
