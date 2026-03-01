provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source  = "tedilabs/network/aws//modules/vpc"
  version = "~> 1.2.0"

  name = "test"

  ipv4_cidrs = [
    { cidr = "10.0.0.0/16" },
  ]
}

module "subnet_group" {
  source  = "tedilabs/network/aws//modules/subnet-group"
  version = "~> 1.2.0"

  name   = "test-data-managed-elasticache"
  vpc_id = module.vpc.id

  subnets = {
    "test-data-managed-elasticache-001/az1" = {
      availability_zone_id = "use1-az1"
      ipv4_cidr            = "10.0.10.0/24"
    }
    "test-data-managed-elasticache-002/az2" = {
      availability_zone_id = "use1-az2"
      ipv4_cidr            = "10.0.11.0/24"
    }
    "test-data-managed-elasticache-003/az3" = {
      availability_zone_id = "use1-az3"
      ipv4_cidr            = "10.0.12.0/24"
    }
  }
  elasticache_subnet_group = {
    enabled = true
    name    = "test-elasticache"
  }
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

  engine = {
    type    = "redis"
    version = "7.1"
  }
  node_instance_type = "cache.t4g.micro"
  node_size          = 2

  vpc_id       = module.vpc.id
  subnet_group = module.subnet_group.elasticache_subnet_group.name

  multi_az_enabled      = true
  auto_failover_enabled = true

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
