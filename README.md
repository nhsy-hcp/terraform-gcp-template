# terraform-gcp-template

This is a template repository for creating Terraform deployments for Google Cloud Platform (GCP) using Workload Identity.

## Prerequisites
- Github organization
- HCP Terraform Cloud organization with GitHub App VCS integration
- Google Cloud SDK
- Go Task
- Terraform

## Usage
1. Clone this repository.
1. Create `terraform.tfvars` in bootstrap project copying `terraform.tfvars.example`.
1. Create `.env` file in root folder copying `.env.example`.
1. Execute the following commands to set up your environment:
```bash
task gcp-login
task gcp-project
task pre-reqs
task bootstrap-init
task bootstrap-plan
task bootstrap-apply
```
5. After the bootstrap is complete, you can create your own Terraform resources in the root directory.

## Troubleshooting

Check GitHub App installation with the following command:
```bash
 export TOKEN=__TFC_TOKEN__
 curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request GET \
  https://app.terraform.io/api/v2/github-app/installations | jq
```