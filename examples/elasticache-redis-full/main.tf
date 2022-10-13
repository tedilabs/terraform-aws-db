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

  name        = "example-redis-full"
  description = "Managed by Terraform."

  redis_version      = "6.2"
  node_instance_type = "cache.t4g.micro"
  # node_size          = 1
  sharding = {
    enabled    = true
    shard_size = 3
    replicas   = 2
  }


  ## Network
  port                         = 6379
  vpc_id                       = null
  subnet_group                 = null
  preferred_availability_zones = []

  default_security_group = {
    eanbled     = true
    name        = "example-redis-full-default-sg"
    description = "Managed by Terraform."

    ingress_rules = [
      {
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  security_groups = []


  ## Parameters
  parameter_group = {
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
  custom_parameter_group = null


  ## Auth
  password    = sensitive("helloworld!#!!1234")
  user_groups = []


  ## Encryption
  encryption_at_rest = {
    enabled = true
    kms_key = null
  }
  encryption_in_transit = {
    enabled = true
  }


  ## Backup
  backup_enabled             = true
  backup_window              = "16:00-17:00"
  backup_retention           = 1
  backup_final_snapshot_name = "example-redis-full-final"


  ## Source
  source_backup_name = null
  source_rdb_s3_arns = null


  ## Maintenance
  maintenance_window                 = "fri:18:00-fri:20:00"
  auto_upgrade_minor_version_enabled = true
  notification_sns_topic             = null


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
    update = "40m"
    delete = "40m"
  }

  tags = {
    "project" = "terraform-aws-db-examples"
  }
}
