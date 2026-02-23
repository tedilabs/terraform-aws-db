locals {
  metadata = {
    package = "terraform-aws-db"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.id
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# User of ElastiCache for Redis
###################################################
# INFO: Deprecated attributes
# - `no_password_required`
# - `passwords`
resource "aws_elasticache_user" "this" {
  region = var.region

  engine    = var.engine
  user_id   = var.id
  user_name = var.name

  access_string = var.access_string

  authentication_mode {
    type = var.authentication.mode
    passwords = (var.authentication.mode == "password"
      ? var.authentication.passwords
      : null
    )
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
