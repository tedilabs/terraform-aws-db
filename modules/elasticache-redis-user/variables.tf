variable "id" {
  description = "(Required) The ID of the ElastiCache user."
  type        = string
  nullable    = false
}

variable "name" {
  description = "(Required) The username of the ElastiCache user. It can have up to 40 characters, and must begin with a letter. It should not end with a hyphen or contain two consecutive hyphens. Valid characters: A-Z, a-z, 0-9, and - (hyphen)."
  type        = string
  nullable    = false
}

# INFO: https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/Clusters.RBAC.html#Access-string
variable "access_string" {
  description = "(Optional) Access permissions string used for this user. Defaults to `off -@all`."
  type        = string
  default     = "off -@all"
  nullable    = false
}

variable "password_required" {
  description = "(Optional) Whether a password is required for this user. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "passwords" {
  description = "(Optional) A set of passwords used for this user. You can create up to two passwords for each user."
  type        = set(string)
  default     = []
  nullable    = false
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
