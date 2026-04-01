package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestUnitEnvironments(t *testing.T) {
	t.Parallel()

	repositoryName := fmt.Sprintf("test-unit-env-%s", random.UniqueId())

	prodEnvName := fmt.Sprintf("production-%s", random.UniqueId())
	stagingEnvName := fmt.Sprintf("staging-%s", random.UniqueId())

	envSecretName := "ENV_SECRET"
	envSecretValue := "env-secret-42"

	envVariableName := "REGION"
	envVariableValue := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "unit-complete",
		Upgrade:      true,
		Vars: map[string]interface{}{
			"name":                          repositoryName,
			"repository_with_defaults_name": fmt.Sprintf("test-unit-env-defaults-%s", random.UniqueId()),
			"team_name":                     fmt.Sprintf("test-unit-env-team-%s", random.UniqueId()),

			"environment_production_name": prodEnvName,
			"environment_staging_name":    stagingEnvName,
			"environment_secret_name":     envSecretName,
			"environment_secret_text":     envSecretValue,
			"environment_variable_name":   envVariableName,
			"environment_variable_value":  envVariableValue,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndPlan(t, terraformOptions)
	terraform.ApplyAndIdempotent(t, terraformOptions)

	// Validate environments were created
	environments := terraform.OutputMap(t, terraformOptions, "environments")
	assert.Contains(t, environments, prodEnvName, "production environment should exist")
	assert.Contains(t, environments, stagingEnvName, "staging environment should exist")

	// Validate environment secrets
	envSecrets := terraform.OutputList(t, terraformOptions, "environment_secrets")
	expectedSecret := fmt.Sprintf("%s:%s", prodEnvName, envSecretName)
	assert.Contains(t, envSecrets, expectedSecret, "environment secret should exist")

	// Validate environment variables
	envVariables := terraform.OutputMap(t, terraformOptions, "environment_variables")
	expectedVarKey := fmt.Sprintf("%s:%s", stagingEnvName, envVariableName)
	assert.Contains(t, envVariables, expectedVarKey, "environment variable should exist")

	// Validate deployment policies were created
	deploymentPolicies := terraform.OutputMap(t, terraformOptions, "environment_deployment_policies")
	expectedBranchPolicy := fmt.Sprintf("%s/main", prodEnvName)
	expectedTagPolicy := fmt.Sprintf("%s/v*", prodEnvName)
	assert.Contains(t, deploymentPolicies, expectedBranchPolicy, "branch deployment policy should exist")
	assert.Contains(t, deploymentPolicies, expectedTagPolicy, "tag deployment policy should exist")
}
