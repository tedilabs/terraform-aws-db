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

  name        = "example-redis-single"
  description = "Managed by Terraform."

  engine = {
    type    = "redis"
    version = "7.1"
  }
  node_instance_type = "cache.t4g.micro"
  node_size          = 1

  vpc_id       = module.vpc.id
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
# Redis User Groups on ElastiCache
###################################################

module "user_group" {
  source = "../../modules/elasticache-redis-user-group"
  # source  = "tedilabs/db/aws//modules/elasticache-redis-user-group"
  # version = "~> 0.2.0"

  engine = "redis"

  name  = "example"
  users = [module.user["example-admin"].id]

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}


###################################################
# Redis Users on ElastiCache
###################################################

locals {
  users = [
    {
      name = "default"

      access_string = "on ~* -@all +@read"
      authentication = {
        mode = "no-password-required"
      }
    },
    {
      name = "admin"

      access_string = "on ~* +@all"
      authentication = {
        mode      = "password"
        passwords = ["MyPassWord!Q@W#E", "MyPassW0rd!@QW#$ER"]
      }
    },
  ]
}

module "user" {
  source = "../../modules/elasticache-redis-user"
  # source  = "tedilabs/db/aws//modules/elasticache-redis-user"
  # version = "~> 0.2.0"

  for_each = {
    for user in try(local.users, []) :
    user.name => user
  }

  engine = "redis"
  name   = each.value.name

  access_string  = try(each.value.access_string, null)
  authentication = try(each.value.authentication, null)

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
