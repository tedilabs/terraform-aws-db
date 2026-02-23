output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_elasticache_user_group.this.region
}

output "id" {
  description = "The ID of the ElastiCache user group."
  value       = aws_elasticache_user_group.this.id
}

output "arn" {
  description = "The ARN of the ElastiCache user group."
  value       = aws_elasticache_user_group.this.arn
}

output "engine" {
  description = "The cache engine used by the ElastiCache user group."
  value       = upper(aws_elasticache_user_group.this.engine)
}

output "name" {
  description = "The name of the ElastiCache user group."
  value       = aws_elasticache_user_group.this.user_group_id
}

output "users" {
  description = "The list of user IDs that belong to the user group."
  value       = values(aws_elasticache_user_group_association.this)[*].user_id
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

# output "debug" {
#   value = {
#     for k, v in aws_elasticache_user_group.this :
#     k => v
#     if !contains(["arn", "region", "id", "user_group_id", "user_ids", "engine", "tags", "tags_all"], k)
#   }
# }
