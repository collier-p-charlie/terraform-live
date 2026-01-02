terraform {
  source = "${include.root.locals.source_base_url}/modules/aws/s3?ref=aws-s3.v1.0.0
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

locals {
  # generic attributes
  project_id  = include.project.inputs.project_id
  env         = include.environment.inputs.environment_name
  resource_id = "${local.project_id}-${local.env}"

  # source specific attributes
  bucket_id               = basename(get_terragrunt_dir())
  bucket_name             = "${local.resource_id}-${local.bucket_id}"
}

inputs = {
  bucket_name = local.bucket_name
}
