terraform {
  source = "${include.root.locals.source_base_url}/modules/aws/iam/oidc-provider?ref=aws-iam-oidc-provider.v1.0.0"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "project" {
  path   = find_in_parent_folders("project.hcl")
  expose = true
}

locals {
  # see here: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws
  base_url = include.project.inputs.github_oidc_url
  audience = include.project.inputs.github_audience
}

inputs = {
  url        = local.base_url
  client_ids = [local.audience]
}

# terragrunt import aws_iam_openid_connect_provider.this arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com
