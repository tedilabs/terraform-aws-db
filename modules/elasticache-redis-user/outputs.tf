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
