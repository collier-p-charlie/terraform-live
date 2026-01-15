terraform {
  source = "${include.root.locals.source_base_url}/modules/aws/iam/role?ref=aws-iam-role.v1.0.0"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "project" {
  path   = find_in_parent_folders("project.hcl")
  expose = true
}

include "environment" {
  path   = find_in_parent_folders("environment.hcl")
  expose = true
}

dependency "oidc_provider" {
  config_path = "${local.project_root}/${local.env}/aws/global/iam/github-oidc-provider"
  mock_outputs = {
    provider_arn = "arn:aws:iam::*:oidc-provider/provider-id"
  }
}

dependency "tfcentralrole" {
  config_path = "${local.project_root}/central/aws/global/iam/tf-central-role"
  mock_outputs = {
    role_arn = "arn:aws:iam::*:role/tf-central-role"
  }
}

locals {
  # generic attributes
  project_root = include.root.locals.project_root_devops
  env          = include.environment.inputs.environment_name

  # source specific attributes
  policy_dir  = "${get_terragrunt_dir()}/policy"
  role_name   = "aws-org-tf-command-management"
  permissions = file("${local.policy_dir}/inline.json")

  base_url    = include.project.inputs.github_oidc_url
  domain_name = replace(local.base_url, "https://", "")
  audience    = include.project.inputs.github_audience
  github_org  = include.project.inputs.github_org
}

inputs = {
  role_name   = local.role_name
  description = "IAM role for Terraform command management."

  trust_policy = templatefile("${local.policy_dir}/trust.json.tftpl", {
    principal_arn       = dependency.oidc_provider.outputs.provider_arn
    domain_name         = local.domain_name
    audience            = local.audience
    github_org          = local.github_org
    central_tf_role_arn = dependency.tfcentralrole.outputs.role_arn
  })
  permissions = local.permissions
}

# terragrunt import aws_iam_role.this aws-org-tf-command-management
