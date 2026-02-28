###################################################
# Global Data Store of ElastiCache Cluster
###################################################

resource "aws_elasticache_global_replication_group" "this" {
  count = var.global_datastore.enabled ? 1 : 0

  region = var.region

  primary_replication_group_id = aws_elasticache_replication_group.this.id

  global_replication_group_id_suffix   = coalesce(var.global_datastore.name, "${var.name}-global-datastore")
  global_replication_group_description = var.global_datastore.description
}
