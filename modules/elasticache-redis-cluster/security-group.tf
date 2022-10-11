###################################################
# Security Group
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 0.26.0"

  count = var.default_security_group.enabled ? 1 : 0

  name        = coalesce(var.default_security_group.name, local.metadata.name)
  description = var.default_security_group.description
  vpc_id      = var.vpc_id

  ingress_rules = [
    for i, rule in var.default_security_group.ingress_rules :
    merge(rule, {
      id        = try(rule.id, "redis-${i}")
      protocol  = "tcp"
      from_port = var.port
      to_port   = var.port
    })
  ]

  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
