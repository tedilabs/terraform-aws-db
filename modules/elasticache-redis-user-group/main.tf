locals {
  metadata = {
    package = "terraform-aws-db"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
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
# User Group of ElastiCache for Redis
###################################################

resource "aws_elasticache_user_group" "this" {
  engine        = "REDIS"
  user_group_id = var.name
  user_ids      = [var.default_user]

  lifecycle {
    ignore_changes = [user_ids]
  }
}

resource "aws_elasticache_user_group_association" "this" {
  for_each = var.users

  user_group_id = aws_elasticache_user_group.this.user_group_id
  user_id       = each.value
}
