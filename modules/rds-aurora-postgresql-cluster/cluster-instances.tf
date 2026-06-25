###################################################
# Aurora PostgreSQL Cluster Instances
###################################################

# INFO: Not supported attributes
# - `db_subnet_group_name`             (inherited from the cluster; set, not user-overridable per instance)
# - `apply_immediately`                (cluster-managed lifecycle; out of scope)
# - `ca_cert_identifier`               (per-instance CA override; out of scope)
# - `engine` / `engine_version`        (inherited from the cluster; not independently settable)
resource "aws_rds_cluster_instance" "this" {
  for_each = {
    for instance in var.instances :
    instance.identifier => instance
  }

  region = var.region

  cluster_identifier = aws_rds_cluster.this.id
  identifier         = each.value.identifier

  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version

  instance_class = each.value.instance_class


  ###################################################
  # Network
  ###################################################

  db_subnet_group_name = aws_rds_cluster.this.db_subnet_group_name
  publicly_accessible  = each.value.publicly_accessible
  availability_zone    = each.value.availability_zone


  ###################################################
  # DB Parameter Group
  ###################################################

  db_parameter_group_name = (var.db_parameter_group.create
    ? aws_db_parameter_group.this[0].name
    : var.db_parameter_group.name
  )


  ###################################################
  # Monitoring
  ###################################################

  monitoring_interval = coalesce(each.value.monitoring_interval, var.monitoring.interval)
  monitoring_role_arn = (each.value.monitoring_role_arn != null
    ? each.value.monitoring_role_arn
    : var.monitoring.role_arn
  )


  ###################################################
  # Performance Insights
  ###################################################

  performance_insights_enabled          = coalesce(each.value.performance_insights_enabled, var.performance_insights.enabled)
  performance_insights_retention_period = coalesce(each.value.performance_insights_retention_period, var.performance_insights.retention_period)
  performance_insights_kms_key_id = (each.value.performance_insights_kms_key != null
    ? each.value.performance_insights_kms_key
    : var.performance_insights.kms_key
  )


  ###################################################
  # Maintenance
  ###################################################

  preferred_maintenance_window = coalesce(each.value.preferred_maintenance_window, var.maintenance.window)
  auto_minor_version_upgrade   = coalesce(each.value.auto_minor_version_upgrade, var.auto_minor_version_upgrade)
  copy_tags_to_snapshot        = var.backup.copy_tags_to_snapshot


  ###################################################
  # Promotion
  ###################################################

  promotion_tier = each.value.promotion_tier


  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  tags = merge(
    {
      "Name" = each.value.identifier
    },
    local.module_tags,
    var.tags,
  )
}
