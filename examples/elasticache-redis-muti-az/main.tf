provider "aws" {
  region = "us-east-1"
}


###################################################
# ElastiCache Redis Cluster
###################################################

module "cluster" {
  source = "../../modules/elasticache-redis-cluster"
  # source  = "tedilabs/db/aws//modules/elasticache-redis-cluster"
  # version = "~> 0.2.0"

  name        = "example-redis-multi-az"
  description = "Managed by Terraform."

  redis_version      = "6.2"
  node_instance_type = "cache.t4g.micro"
  node_size          = 2

  multi_az_enabled      = true
  auto_failover_enabled = true

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
