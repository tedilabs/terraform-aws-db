output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_elasticache_user.this.region
}

output "id" {
  description = "The ID of the ElastiCache user."
  value       = aws_elasticache_user.this.user_id
}

output "arn" {
  description = "The ARN of the ElastiCache user."
  value       = aws_elasticache_user.this.arn
}

output "engine" {
  description = "The cache engine used by the ElastiCache user."
  value       = upper(aws_elasticache_user.this.engine)
}

output "name" {
  description = "The name of the ElastiCache user."
  value       = aws_elasticache_user.this.user_name
}

output "access_string" {
  description = "Access permissions string used for this user."
  value       = aws_elasticache_user.this.access_string
}

output "authentication" {
  description = "The authentication configuration for this user."
  value = {
    mode           = aws_elasticache_user.this.authentication_mode[0].type
    password_count = aws_elasticache_user.this.authentication_mode[0].password_count
  }
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
#     for k, v in aws_elasticache_user.this :
#     k => v
#     if !contains(["arn", "region", "user_id", "engine", "user_name", "access_string", "authentication_mode", "tags", "tags_all", "passwords", "no_password_required", "id", "timeouts"], k)
#   }
# }
