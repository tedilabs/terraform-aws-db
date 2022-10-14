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

  name        = "example-redis-single"
  description = "Managed by Terraform."

  redis_version      = "6.2"
  node_instance_type = "cache.t4g.micro"
  node_size          = 1

  user_groups = [module.user_group.id]

  encryption_in_transit = {
    enabled = true
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

  name         = "example"
  default_user = module.user["example-default"].id
  users        = [module.user["example-admin"].id]

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
      id   = "example-default"
      name = "default"

      access_string     = "on ~* -@all +@read"
      password_required = false
    },
    {
      id   = "example-admin"
      name = "admin"

      access_string     = "on ~* +@all"
      password_required = true
      passwords         = ["MyPassWord!Q@W#E", "MyPassW0rd!@QW#$ER"]
    },
  ]
}

module "user" {
  source = "../../modules/elasticache-redis-user"
  # source  = "tedilabs/db/aws//modules/elasticache-redis-user"
  # version = "~> 0.2.0"

  for_each = {
    for user in try(local.users, []) :
    user.id => user
  }

  id   = each.key
  name = each.value.name

  access_string     = try(each.value.access_string, null)
  password_required = try(each.value.password_required, true)
  passwords         = try(each.value.passwords, [])

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
