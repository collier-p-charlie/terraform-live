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

include "region" {
  path   = find_in_parent_folders("region.hcl")
  expose = true
}

dependency "oidc_provider" {
  config_path = "${local.project_root}/${local.env}/aws/global/iam/github-oidc-provider"
  mock_outputs = {
    provider_arn = "arn:aws:iam::*:oidc-provider/provider-id"
  }
}

dependency "s3tfstate" {
  config_path = "${local.project_root}/central/aws/${local.region}/s3/tf-state-bucket"
  mock_outputs = {
    bucket_arn = "arn:aws:s3:::mock-s3-tf-state-bucket"
  }
}

locals {
  # generic attributes
  project_root = include.root.locals.project_root_devops
  env          = include.environment.inputs.environment_name
  region       = include.region.inputs.region

  # source specific attributes
  policy_dir = "${get_terragrunt_dir()}/policy"
  role_name  = "aws-org-tf-state-management"

  base_url    = include.project.inputs.github_oidc_url
  domain_name = replace(local.base_url, "https://", "")
  audience    = include.project.inputs.github_audience
  github_org  = include.project.inputs.github_org
}

inputs = {
  role_name   = local.role_name
  description = "IAM role for Terraform state management."

  trust_policy = templatefile("${local.policy_dir}/trust.json.tftpl", {
    principal_arn = dependency.oidc_provider.outputs.provider_arn
    domain_name   = local.domain_name
    audience      = local.audience
    github_org    = local.github_org
  })
  permissions = templatefile("${local.policy_dir}/inline.json.tftpl", {
    state_bucket_arn = dependency.s3tfstate.outputs.bucket_arn
  })
}

# terragrunt import aws_iam_role.this aws-org-tf-state-management
