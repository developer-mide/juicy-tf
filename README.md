# Juicy-TF GitHub Action

This GitHub action workflow, named `juicy-tf`, is a reusable workflow designed to help teams enforce best practices in their Terraform code. It
performs several checks to ensure the code is secure, formatted correctly, and follows best practices.

## Inputs

The action accepts the following inputs:

- `validate_pr_title`: A boolean value that determines whether to skip validating the PR title. Default is `true`.
- `validate_var_types`: A boolean value that determines whether to skip ensuring variable types are declared. Default is `true`.
- `pr_title_pattern`: A regular expression pattern to match the PR title. Default is `JIRA-[0-9]{1,5}`.
- `main_tf_working_dir`: The directory to start the search from. Default is `infra/`.
- `check_lock_file_changes`: A boolean value that determines whether to check if terraform is configured for `--platform=linux_amd64`. Default is
  `true`.
- `envs`: A list of environments to check. Default is an empty list.

## Steps

The action performs the following steps:

1. **Checkout code**: This step checks out the repository code into the GitHub Actions runner.

2. **Validate PR Title**: If `validate_pr_title` is set to `true`, this step checks if the pull request title matches the provided pattern. If it
   doesn't, the step fails. Note: This pattern must be a bash regex

3. **Check Secrets**: This step searches for potential secrets in the Terraform files and environment files. If any are found, a warning is raised.

4. **Check Terraform Formatting**: This step checks if the Terraform files are formatted correctly using `terraform fmt -check -recursive`. If they're
   not, the step fails.

5. **Validate Terraform**: This step initializes and validates the Terraform configuration in the specified working directory.

6. **Find Lock File**: This step checks if a lock file exists in the specified working directory. If it doesn't, the step fails.

7. **Variable Type Declaration**: If `validate_var_types` is set to `true`, this step checks if all Terraform variables have a type declaration. If
   any don't, a warning is raised.

8. **Check Remote Backend**: This step checks if the remote backend is configured for each environment in the `envs` list. If it's not, a warning is
   raised.

9. **Check terraform lock file updates**: If `check_lock_file_changes` is set to `true`, this step checks if there are any changes to the Terraform
   lock file. If there are, the step fails. This is to ensure that Terraform is configured for `--platform=linux_amd64`.

## Usage

To use this action in your workflow, add the following step to your workflow file:

```yaml
name: Validate Terraform
on:
  pull_request:
    types: ['edited', 'synchronize', 'opened', 'reopened']
jobs:
  validate:
    name: Validate Terraform
    runs-on: ubuntu-latest
    steps:
      - name: Validate Terraform
        uses: 'developer-mide/juicy-tf@master'
        with:
          main_tf_working_dir: '.'
          envs: ("/envs/dev", "/envs/prod")
```
