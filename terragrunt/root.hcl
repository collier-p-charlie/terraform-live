locals {
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment = local.environment_vars.inputs.environment_name
  project_id  = local.project_vars.inputs.project_id
  account_id  = local.account_vars.inputs.aws_account_id
  region      = local.region_vars.inputs.region

  # AWS organisation wide state bucket
  aws_org_state_bucket = "aws-org-tf-state-bucket"

  # Modules repo
  source_base_url = "git@github.com:collier-p-charlie/terraform-modules.git/"

  # Project directory roots
  project_root_demo = "${get_repo_root()}/terragrunt/projects/demo"
}

inputs = {
  environment = local.environment
  project_id  = local.project_id
  region      = local.region

  # Passed to AWS provider for sts:AssumeRole for access to command deployment in each account
  command_role_arn = "arn:aws:iam::${local.account_id}:role/aws-org-tf-command-management"
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket       = local.aws_org_state_bucket
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}
