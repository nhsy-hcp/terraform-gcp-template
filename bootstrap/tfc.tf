# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "tfe_github_app_installation" "default" {
  name = var.github_organization
}

data "tfe_project" "default" {
  name         = var.tfc_project
  organization = var.tfc_organization
}

# Runs in this workspace will be automatically authenticated
# to GCP with the permissions set in the GCP policy.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace
resource "tfe_workspace" "default" {
  name                = var.tfc_workspace
  auto_apply          = true
  description         = "Terraform Cloud workspace for GCP Workload Identity integration"
  organization        = var.tfc_organization
  project_id          = data.tfe_project.default.id
  speculative_enabled = true
  tag_names           = ["gcp", "workload-identity"]
  terraform_version   = "~> 1.10.0"
  trigger_patterns    = ["*.tf", "*.tfvars"]

  vcs_repo {
    branch                     = "main"
    identifier                 = format("%s/%s", var.github_organization, var.github_repository)
    github_app_installation_id = data.tfe_github_app_installation.default.id
  }
  working_directory = var.tfc_working_directory
}

# The following variables must be set to allow runs
# to authenticate to GCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.default.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}

# The provider name contains the project number, pool ID,
# and provider ID. This information can be supplied using
# this TFC_GCP_WORKLOAD_PROVIDER_NAME variable, or using
# the separate TFC_GCP_PROJECT_NUMBER, TFC_GCP_WORKLOAD_POOL_ID,
# and TFC_GCP_WORKLOAD_PROVIDER_ID variables below if desired.
#
resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.default.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = google_iam_workload_identity_pool_provider.tfc_provider.name
  category = "env"

  description = "The workload provider name to authenticate against."
}

# Uncomment the following variables and comment out
# tfc_gcp_workload_provider_name if you wish to supply this
# information in separate variables instead!

# resource "tfe_variable" "tfc_gcp_project_number" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_PROJECT_NUMBER"
#   value    = data.google_project.project.number
#   category = "env"

#   description = "The numeric identifier of the GCP project"
# }

# resource "tfe_variable" "tfc_gcp_workload_pool_id" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_WORKLOAD_POOL_ID"
#   value    = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
#   category = "env"

#   description = "The ID of the workload identity pool."
# }

# resource "tfe_variable" "tfc_gcp_workload_provider_id" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_WORKLOAD_PROVIDER_ID"
#   value    = google_iam_workload_identity_pool_provider.tfc_provider.workload_identity_pool_provider_id
#   category = "env"

#   description = "The ID of the workload identity pool provider."
# }

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.default.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.tfc_service_account.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_gcp_audience" {
#   workspace_id = tfe_workspace.my_workspace.id

#   key      = "TFC_GCP_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_gcp_audience
#   category = "env"

#   description = "The value to use as the audience claim in run identity tokens"
# }

resource "tfe_variable" "project_id" {
  workspace_id = tfe_workspace.default.id

  key      = "project_id"
  value    = var.gcp_project_id
  category = "terraform"

  description = "GCP Project ID"
}