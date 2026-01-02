# TCL Terraform Live

This repository contains all **TCL** _infrastructure_ using **Terragrunt**.

- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Module Tagging](#module-tagging)


## Prerequisites

This repository depends on the following requirements:
- [Python](https://www.python.org) of version `>=3.13` for code execution;
- [uv](https://docs.astral.sh/uv/) for **Python** package management;
- [Terraform](https://developer.hashicorp.com/terraform) installation, currently of version `1.14.3` (can be installed with `brew install` on **MacOS**);
- [Terragrunt](https://terragrunt.gruntwork.io) installation, currently of version `0.96.1` (can also be installed with `brew install`).

To install the `pre-commit` checks we need to install **Python** then run the following:

```bash
uv venv  # create the virtual environment
uv sync  # sync dependencies (i.e. install pre-commit)
pre-commit install  # setup pre-commit
```

Then before every commit, the **Terragrunt** **HCL** _code_ will be automatically formatted.
This is defined within the [pre-commit-config](.pre-commit-config.yaml) configuration file.

For this deployment to work, we need to integrate with [OpenTaco]() (previously [digger.dev]()).
Moreover, we need the following setup within our **AWS** accounts (if using that provider):
- A **command** role per **AWS** account that can be assumed with deployment permissions;
- A **state** management role in the _shared_ account where the _state_ bucket resides;
  - This should have `sts:AssumeRule` to all the **command** roles per account we wish to deploy.
  - It also needs permissions to manage the _state_ in this accounts bucket.
- A **state** _bucket_ within the _shared_ account.


## Repository Structure

The folder structure for **IAC** is as follows:

```
terragrunt/
└── project/
  └── <project-id>/
    ├── project.hcl  # inputs for the project, gets from dirname
    └── <env-name>/
      ├── environment.hcl  # environment name, gets from dirname
      └── <provider>/
      └── aws/  # example provider
        ├── account.hcl  # account-specific, e.g. aws_account_id
        └── <region>/
          ├── region.hcl  # AWS region
          └── <service>/  # AWS service name
            └── <id>/  # Service-specific identifier
              └── terragrunt.hcl  # the HCL Terragrunt configuration
```

The root of the structure is the **project** level tagging.
Within this, each deployment environment such as **prod** or **uat**.
Then the **provider** level, so for example **aws** or **snowflake**.
Within the **AWS** provider, we specify the **region** and then the **service**, for ease of deployment.
Within each service / module we can create folder identifiers if we need multiple **S3** buckets, say.


## Module Tagging

Every _module_ has a _tag_ so that it can be versioned.
The modules and their tags can be found within the repository [here](https://github.com/TrinityCollegeLondon/tcl-terraform-modules).
To use these versioned modules, in our `terragrunt.hcl` files we simply do the following:

```hcl
terraform {
  source = "git@github.com:collier-p-charlie/terraform-modules.git//modules/aws/s3?ref=aws-s3.v1.0.0"
}
```

This would use the **AWS S3** module as of version `v1.0.0`.
