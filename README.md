# OpenTofu AWS ECR Module

OpenTofu module for creating AWS ECR repositories with security best practices.

## Usage

```hcl
module "ecr" {
  source = "git::https://github.com/im5tu/opentofu-aws-ecr.git?ref=2a89a082a1a3f421f2dd78814838bc14ff5b1316"

  repo_name             = "my-application"
  push_principal_access = ["arn:aws:iam::123456789012:role/github-actions"]

  tags = {
    Environment = "production"
  }
}
```

### With KMS Encryption

```hcl
module "ecr" {
  source = "git::https://github.com/im5tu/opentofu-aws-ecr.git?ref=2a89a082a1a3f421f2dd78814838bc14ff5b1316"

  repo_name             = "my-application"
  push_principal_access = ["arn:aws:iam::123456789012:role/github-actions"]
  kms_key_arn           = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| opentofu | >= 1.9 |
| aws | ~> 6 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repo_name | The name of the ECR repository | `string` | n/a | yes |
| push_principal_access | AWS Principals with push permissions | `list(string)` | n/a | yes |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |
| tag_mutability | Image tag mutability setting | `string` | `"IMMUTABLE"` | no |
| retained_image_count | Maximum images to retain | `number` | `5` | no |
| enable_organization_access | Allow access from AWS Organization members | `bool` | `false` | no |
| kms_key_arn | KMS key ARN for encryption. If not provided, AES256 is used | `string` | `null` | no |
| scan_on_push | Enable image scanning on push | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| repo_name | The name of the ECR repository |
| registry_id | The registry ID |
| repo_url | The repository URL |
| arn | The ARN of the ECR repository |

## Development

### Validation

This module uses GitHub Actions for validation:

- **Format check**: `tofu fmt -check -recursive`
- **Validation**: `tofu validate`
- **Security scanning**: Checkov, Trivy

### Local Development

```bash
# Format code
tofu fmt -recursive

# Validate
tofu init -backend=false
tofu validate
```

## License

MIT License - see [LICENSE](LICENSE) for details.
