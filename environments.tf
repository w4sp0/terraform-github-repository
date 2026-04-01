# ---------------------------------------------------------------------------------------------------------------------
# Deployment Environments
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment
# ---------------------------------------------------------------------------------------------------------------------

locals {
  environments_map = { for e in var.environments : e.name => e }

  environment_deployment_policies_map = {
    for p in var.environment_deployment_policies :
    "${p.environment}/${try(p.branch_pattern, p.tag_pattern)}" => p
  }

  environment_plaintext_secrets = { for k, v in var.environment_plaintext_secrets : k => {
    environment = split(":", k)[0]
    secret_name = join(":", slice(split(":", k), 1, length(split(":", k))))
    plaintext   = v
  } }

  environment_encrypted_secrets = { for k, v in var.environment_encrypted_secrets : k => {
    environment = split(":", k)[0]
    secret_name = join(":", slice(split(":", k), 1, length(split(":", k))))
    encrypted   = v
  } }

  environment_secrets = merge(local.environment_plaintext_secrets, local.environment_encrypted_secrets)

  environment_variables_map = { for k, v in var.environment_variables : k => {
    environment   = split(":", k)[0]
    variable_name = join(":", slice(split(":", k), 1, length(split(":", k))))
    value         = v
  } }
}

resource "github_repository_environment" "environment" {
  for_each = local.environments_map

  repository  = github_repository.repository.name
  environment = each.key
  wait_timer  = try(each.value.wait_timer, null)

  can_admins_bypass   = try(each.value.can_admins_bypass, true)
  prevent_self_review = try(each.value.prevent_self_review, false)

  dynamic "reviewers" {
    for_each = try([each.value.reviewers], [])

    content {
      teams = try(reviewers.value.teams, null)
      users = try(reviewers.value.users, null)
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = try([each.value.deployment_branch_policy], [])

    content {
      protected_branches     = deployment_branch_policy.value.protected_branches
      custom_branch_policies = deployment_branch_policy.value.custom_branch_policies
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Environment Deployment Policies
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment_deployment_policy
# ---------------------------------------------------------------------------------------------------------------------

resource "github_repository_environment_deployment_policy" "deployment_policy" {
  for_each = local.environment_deployment_policies_map

  repository     = github_repository.repository.name
  environment    = each.value.environment
  branch_pattern = try(each.value.branch_pattern, null)
  tag_pattern    = try(each.value.tag_pattern, null)

  depends_on = [github_repository_environment.environment]
}

# ---------------------------------------------------------------------------------------------------------------------
# Environment Secrets
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret
# ---------------------------------------------------------------------------------------------------------------------

resource "github_actions_environment_secret" "environment_secret" {
  for_each = local.environment_secrets

  repository      = github_repository.repository.name
  environment     = each.value.environment
  secret_name     = each.value.secret_name
  plaintext_value = try(each.value.plaintext, null)
  encrypted_value = try(each.value.encrypted, null)

  depends_on = [github_repository_environment.environment]
}

# ---------------------------------------------------------------------------------------------------------------------
# Environment Variables
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable
# ---------------------------------------------------------------------------------------------------------------------

resource "github_actions_environment_variable" "environment_variable" {
  for_each = local.environment_variables_map

  repository    = github_repository.repository.name
  environment   = each.value.environment
  variable_name = each.value.variable_name
  value         = each.value.value

  depends_on = [github_repository_environment.environment]
}
