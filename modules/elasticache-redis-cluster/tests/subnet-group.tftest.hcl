mock_provider "aws" {
  mock_data "aws_elasticache_subnet_group" {
    defaults = {
      vpc_id = "vpc-0123456789abcdef0"
    }
  }
}

mock_provider "telemetry" {}

variables {
  name               = "subnet-group-test"
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

run "default_security_group_uses_subnet_group_vpc" {
  command = plan

  assert {
    condition     = module.security_group[0].vpc_id == "vpc-0123456789abcdef0"
    error_message = "The default security group must use the VPC of the selected subnet group."
  }

  assert {
    condition     = output.network.vpc_id == "vpc-0123456789abcdef0"
    error_message = "The network output must expose the subnet group's VPC."
  }

  assert {
    condition = (
      data.aws_elasticache_subnet_group.this.name == "existing-cache-subnets" &&
      data.aws_elasticache_subnet_group.this.region == "ap-northeast-2"
    )
    error_message = "The subnet group lookup must use the requested name and region."
  }
}

run "external_security_groups_preserve_vpc_output" {
  command = plan

  variables {
    default_security_group = { enabled = false }
    security_groups        = ["sg-0123456789abcdef0"]
  }

  assert {
    condition     = output.network.vpc_id == "vpc-0123456789abcdef0"
    error_message = "The VPC must remain available without creating a default security group."
  }

  assert {
    condition = (
      output.network.default_security_group == null &&
      contains(output.network.security_groups, "sg-0123456789abcdef0")
    )
    error_message = "Externally supplied security groups must still be used."
  }
}
