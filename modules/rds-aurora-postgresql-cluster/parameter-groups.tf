###################################################
# Cluster Parameter Group
###################################################

# INFO: Not supported attributes
# - `name_prefix`                      (module owns deterministic naming)
resource "aws_rds_cluster_parameter_group" "this" {
  count = var.cluster_parameter_group.create ? 1 : 0

  region = var.region

  name        = coalesce(var.cluster_parameter_group.name, "${var.name}-cluster")
  family      = var.cluster_parameter_group.family
  description = var.cluster_parameter_group.description

  dynamic "parameter" {
    for_each = var.cluster_parameter_group.parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    {
      "Name" = coalesce(var.cluster_parameter_group.name, "${var.name}-cluster")
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}


###################################################
# DB Parameter Group (Instance Level)
###################################################

# INFO: Not supported attributes
# - `name_prefix`                      (module owns deterministic naming)
resource "aws_db_parameter_group" "this" {
  count = var.db_parameter_group.create ? 1 : 0

  region = var.region

  name        = coalesce(var.db_parameter_group.name, "${var.name}-instance")
  family      = var.db_parameter_group.family
  description = var.db_parameter_group.description

  dynamic "parameter" {
    for_each = var.db_parameter_group.parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    {
      "Name" = coalesce(var.db_parameter_group.name, "${var.name}-instance")
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}
