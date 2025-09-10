output "id" {
  description = "The ID of the ElastiCache user."
  value       = aws_elasticache_user.this.user_id
}

output "arn" {
  description = "The ARN of the ElastiCache user."
  value       = aws_elasticache_user.this.arn
}

output "name" {
  description = "The name of the ElastiCache user."
  value       = aws_elasticache_user.this.user_name
}

output "access_string" {
  description = "Access permissions string used for this user."
  value       = aws_elasticache_user.this.access_string
}

output "password_required" {
  description = "Whether a password is required for this user."
  value       = !aws_elasticache_user.this.no_password_required
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
