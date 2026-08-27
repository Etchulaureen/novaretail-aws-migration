# Validation Report

- `scripts/post_migration_validation.py`: OK
- `scripts/generate_test_data.py`: OK
- `app/app.py`: OK
- `scripts/pre_migration_check.sh`: OK
- `scripts/service_check.sh`: OK
- `terraform/user_data.sh`: OK

## Terraform

Terraform CLI was not available in the build runtime, so terraform validate could not be executed locally. The included GitHub Actions workflow runs terraform fmt/init/validate on every push or pull request.
