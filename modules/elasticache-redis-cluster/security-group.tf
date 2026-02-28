data "aws_elasticache_subnet_group" "this" {
  name = var.subnet_group
}


###################################################
# Security Group
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 1.0.0"

  count = var.default_security_group.enabled ? 1 : 0

  region = var.region

  name        = coalesce(var.default_security_group.name, local.metadata.name)
  description = var.default_security_group.description
  vpc_id      = data.aws_elasticache_subnet_group.this.vpc_id

  ingress_rules = [
    for i, rule in var.default_security_group.ingress_rules :
    merge(rule, {
      id        = try(rule.id, "redis-${i}")
      protocol  = "tcp"
      from_port = var.port
      to_port   = var.port
    })
  ]

  revoke_rules_on_delete = true
  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
