output "id" {
  description = "The ID of the ElastiCache user group."
  value       = aws_elasticache_user_group.this.id
}

output "arn" {
  description = "The ARN of the ElastiCache user group."
  value       = aws_elasticache_user_group.this.arn
}

output "name" {
  description = "The name of the ElastiCache user group."
  value       = aws_elasticache_user_group.this.user_group_id
}

output "default_user" {
  description = "The ID of default user."
  value       = var.default_user
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
