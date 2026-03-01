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

  name        = "example-redis-full"
  description = "Managed by Terraform."

  engine = {
    type    = "redis"
    version = "7.1"
  }
  node_instance_type = "cache.t4g.micro"
  # node_size          = 1
  cluster_mode = {
    state      = "ENABLED"
    shard_size = 3
    replicas   = 2
  }


  ## Network
  ip_address_type              = "IPv4"
  discovery_ip_address_type    = "IPv4"
  port                         = 6379
  vpc_id                       = module.vpc.id
  subnet_group                 = module.subnet_group.elasticache_subnet_group.name
  preferred_availability_zones = []

  default_security_group = {
    eanbled     = true
    name        = "example-redis-full-default-sg"
    description = "Managed by Terraform."

    ingress_rules = [
      {
        id         = "all"
        ipv4_cidrs = ["0.0.0.0/0"]
      }
    ]
  }
  security_groups = []


  ## Parameters
  default_parameter_group = {
    enabled     = true
    name        = "example-redis-full-parameter-group"
    description = "Managed by Terraform."
    parameters = {
      "lazyfree-lazy-eviction"   = "yes"
      "lazyfree-lazy-expire"     = "yes"
      "lazyfree-lazy-server-del" = "yes"
      "rename-commands"          = "KEYS BLOCKED"
    }
  }
  parameter_group = null


  ## Auth
  password                 = sensitive("helloworld!#!!1234")
  password_update_strategy = "ROTATE"
  user_groups              = []


  ## Encryption
  encryption_at_rest = {
    enabled = true
    kms_key = null
  }
  encryption_in_transit = {
    enabled = true
    mode    = "required"
  }


  ## Maintenance
  maintenance = {
    window                             = "fri:18:00-fri:20:00"
    auto_upgrade_minor_version_enabled = true
    notification_sns_topic             = null
  }

  ## Backup
  backup = {
    enabled             = true
    window              = "16:00-17:00"
    retention           = 1
    final_snapshot_name = "example-redis-full-final"
  }


  ## Restore
  restore = {
    backup_name = null
    rdb_s3_arns = null
  }



  ## Logging
  logging_slow_log = {
    enabled = false
    format  = "JSON"

    destination_type = "CLOUDWATCH_LOGS"
    destination      = null
  }
  logging_engine_log = {
    enabled = false
    format  = "JSON"

    destination_type = "CLOUDWATCH_LOGS"
    destination      = null
  }


  ## Attributes
  multi_az_enabled      = true
  auto_failover_enabled = true
  apply_immediately     = true

  timeouts = {
    create = "60m"
    update = "45m"
    delete = "40m"
  }

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
