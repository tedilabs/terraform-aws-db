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
# ElastiCache Valkey Cluster
###################################################

module "cluster" {
  source = "../../modules/elasticache-redis-cluster"
  # source  = "tedilabs/db/aws//modules/elasticache-redis-cluster"
  # version = "~> 0.4.0"

  name        = "example-valkey-rbac"
  description = "Managed by Terraform."

  engine = {
    type    = "valkey"
    version = "8.2"
  }
  node_instance_type = "cache.t4g.micro"
  node_size          = 1

  subnet_group = module.subnet_group.elasticache_subnet_group.name

  user_groups = [module.user_group.id]

  encryption_in_transit = {
    enabled = true
    mode    = "required"
  }

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}


###################################################
# Valkey User Groups on ElastiCache
###################################################

module "user_group" {
  source = "../../modules/elasticache-redis-user-group"
  # source  = "tedilabs/db/aws//modules/elasticache-redis-user-group"
  # version = "~> 0.4.0"

  engine = "valkey"

  name  = "example-valkey-rbac"
  users = [for user in module.user : user.id]

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}


###################################################
# Valkey Users on ElastiCache
###################################################

locals {
  users = {
    admin = {
      access_string = "on ~* &* +@all"
    }
    readonly = {
      access_string = "on ~* -@all +@read"
    }
  }
}


module "user" {
  source = "../../modules/elasticache-redis-user"
  # source  = "tedilabs/db/aws//modules/elasticache-redis-user"
  # version = "~> 0.4.0"

  for_each = local.users

  engine = "valkey"
  name   = "example-rbac-${each.key}"

  access_string = each.value.access_string
  authentication = {
    mode      = "password"
    passwords = [var.user_passwords[each.key]]
  }

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
