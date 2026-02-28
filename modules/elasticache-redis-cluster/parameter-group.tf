locals {
  engine_versions = jsondecode(file("${path.module}/cache-engine-versions.json"))
  family = {
    for item in local.engine_versions :
    "${item.engine}/${item.engine_version}" => item.parameter_group_family
  }["${var.engine.type}/${var.engine.version}"]

  parameters = merge(
    {
      "cluster-enabled" = var.cluster_mode.state == "ENABLED" ? "yes" : "no"
    },
    var.default_parameter_group.parameters
  )

  parameter_group_default_name = "${var.name}-${replace(local.family, ".", "-")}"
}


###################################################
# Parameter Group of ElastiCache Cluster for Redis
###################################################

resource "aws_elasticache_parameter_group" "this" {
  count = var.default_parameter_group.enabled ? 1 : 0

  region = var.region

  name        = coalesce(var.default_parameter_group.name, local.parameter_group_default_name)
  description = var.default_parameter_group.description
  family      = local.family

  dynamic "parameter" {
    for_each = local.parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
    var.default_parameter_group.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}
