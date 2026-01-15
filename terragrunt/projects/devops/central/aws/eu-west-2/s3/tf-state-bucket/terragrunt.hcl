terraform {
  source = "${include.root.locals.source_base_url}/modules/aws/s3?ref=aws-s3.v1.0.0"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

locals {
  # generic attributes
  account_id = include.account.inputs.aws_account_id

  # source specific attributes
  policy_dir  = "${get_terragrunt_dir()}/policy"
  bucket_name = "aws-org-tf-state-${local.account_id}"
}

inputs = {
  bucket_name = local.bucket_name
  bucket_policy = templatefile("${local.policy_dir}/resource.json.tftpl", {
    bucket_name = local.bucket_name
  })
}

# terragrunt import aws_s3_bucket.this aws-org-tf-state-111111111111
