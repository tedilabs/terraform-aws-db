###################################################
# Custom Cluster Endpoints
###################################################

# INFO: Not supported attributes
# - `custom_endpoint_type = "WRITER"`  (invalid for custom endpoints; only `READER`/`ANY` are valid)
resource "aws_rds_cluster_endpoint" "this" {
  for_each = {
    for endpoint in var.custom_endpoints :
    endpoint.name => endpoint
  }

  region = var.region

  cluster_identifier = aws_rds_cluster.this.id

  cluster_endpoint_identifier = each.key
  custom_endpoint_type        = each.value.type

  static_members = (each.value.selector.mode == "STATIC"
    ? each.value.selector.instances
    : null
  )
  excluded_members = (each.value.selector.mode == "EXCEPT"
    ? each.value.selector.instances
    : null
  )

  tags = merge(
    {
      "Name" = each.key
    },
    local.module_tags,
    var.tags,
    each.value.tags,
  )
}
