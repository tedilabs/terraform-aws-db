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
