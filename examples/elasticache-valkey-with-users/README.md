# Valkey with role-based access control

This example creates a Valkey 8.2 cache with TLS, a Valkey user group, and two password-authenticated users:

- `example-rbac-admin` can access all keys, channels, and commands.
- `example-rbac-readonly` can read all keys.

Both users are attached to the user group. Valkey user groups do not require a `default` user, so this example does not try to create or replace AWS's reserved `default` user.

Supply the required sensitive `user_passwords` object with `admin` and `readonly` values through your deployment's secret input mechanism. The example contains no embedded passwords. These are regular password inputs stored in Terraform state; they are not write-only inputs.

Run `terraform init` and `terraform plan`, then review the plan before applying. Connect with TLS to `module.cluster.endpoints.primary` on port 6379 using the appropriate username and password. Test that the admin user can write and the readonly user can read but receives `NOPERM` when attempting to write.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ../../modules/elasticache-redis-cluster | n/a |
| <a name="module_subnet_group"></a> [subnet\_group](#module\_subnet\_group) | tedilabs/network/aws//modules/subnet-group | ~> 1.2.0 |
| <a name="module_user"></a> [user](#module\_user) | ../../modules/elasticache-redis-user | n/a |
| <a name="module_user_group"></a> [user\_group](#module\_user\_group) | ../../modules/elasticache-redis-user-group | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | tedilabs/network/aws//modules/vpc | ~> 1.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_user_passwords"></a> [user\_passwords](#input\_user\_passwords) | Passwords for the admin and readonly Valkey users. Supply these through your deployment's secret input mechanism. | <pre>object({<br/>    admin    = string<br/>    readonly = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | n/a |
| <a name="output_user_group"></a> [user\_group](#output\_user\_group) | n/a |
| <a name="output_users"></a> [users](#output\_users) | n/a |
<!-- END_TF_DOCS -->
