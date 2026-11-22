mock_provider "aws" {
  mock_data "aws_elasticache_subnet_group" {
    defaults = {
      vpc_id = "vpc-0123456789abcdef0"
    }
  }
}

mock_provider "telemetry" {}

variables {
  name               = "parameter-group-test"
  region             = "ap-northeast-2"
  subnet_group       = "existing-cache-subnets"
  node_instance_type = "cache.t4g.micro"
  engine = {
    type    = "valkey"
    version = "8.0"
  }
  resource_group = { enabled = false }
  telemetry      = { enabled = false }
}

run "cluster_mode_disabled_disables_cluster_parameter" {
  command = plan

  variables {
    cluster_mode = { state = "DISABLED" }
  }

  assert {
    condition     = local.parameters["cluster-enabled"] == "no"
    error_message = "Cluster mode `DISABLED` must set `cluster-enabled` to `no`."
  }
}

run "cluster_mode_compatible_enables_cluster_parameter" {
  command = plan

  variables {
    cluster_mode = { state = "COMPATIBLE" }
  }

  assert {
    condition     = local.parameters["cluster-enabled"] == "yes"
    error_message = "Cluster mode `COMPATIBLE` must set `cluster-enabled` to `yes`."
  }
}

run "cluster_mode_enabled_enables_cluster_parameter" {
  command = plan

  variables {
    cluster_mode = { state = "ENABLED" }
  }

  assert {
    condition     = local.parameters["cluster-enabled"] == "yes"
    error_message = "Cluster mode `ENABLED` must set `cluster-enabled` to `yes`."
  }
}
