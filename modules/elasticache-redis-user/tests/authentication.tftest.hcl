mock_provider "aws" {}
mock_provider "telemetry" {}

variables {
  name           = "authentication-test"
  resource_group = { enabled = false }
  telemetry      = { enabled = false }
}

run "default_valkey_uses_iam" {
  command = plan
  assert {
    condition     = aws_elasticache_user.this.engine == "valkey" && aws_elasticache_user.this.authentication_mode[0].type == "iam"
    error_message = "The default Valkey user must use IAM authentication."
  }
}

run "null_authentication_uses_iam" {
  command = plan
  variables {
    authentication = null
  }
  assert {
    condition     = aws_elasticache_user.this.authentication_mode[0].type == "iam"
    error_message = "A null authentication input must resolve to IAM."
  }
}

run "null_mode_uses_iam" {
  command = plan
  variables {
    authentication = { mode = null }
  }
  assert {
    condition     = aws_elasticache_user.this.authentication_mode[0].type == "iam"
    error_message = "A null authentication mode must resolve to IAM."
  }
}

run "valkey_rejects_no_password" {
  command = plan
  variables {
    authentication = { mode = "no-password-required" }
  }
  expect_failures = [var.authentication]
}

run "redis_allows_explicit_no_password" {
  command = plan
  variables {
    engine         = "redis"
    authentication = { mode = "no-password-required" }
  }
  assert {
    condition     = aws_elasticache_user.this.authentication_mode[0].type == "no-password-required"
    error_message = "Redis must still allow explicitly selected passwordless authentication."
  }
}

run "valkey_allows_password" {
  command = plan
  variables {
    authentication = {
      mode      = "password"
      passwords = ["test-password-123456"]
    }
  }
  assert {
    condition     = aws_elasticache_user.this.authentication_mode[0].type == "password"
    error_message = "Valkey must still allow password authentication."
  }
}
