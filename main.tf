resource "aws_ecr_repository" "ecr" {
  name                 = var.repo_name
  tags                 = var.tags
  image_tag_mutability = var.tag_mutability
  force_delete         = true

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

resource "aws_ecr_repository_policy" "ecr" {
  repository = aws_ecr_repository.ecr.name
  policy     = data.aws_iam_policy_document.ecr_access.json
  depends_on = [aws_ecr_repository.ecr]
}

data "aws_organizations_organization" "this" {
  count = var.enable_organization_access ? 1 : 0
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_access" {
  # Allows us to publish to the repository from things like Github
  dynamic "statement" {
    for_each = length(var.push_principal_access) > 0 ? [1] : []

    content {
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "ecr:GetAuthorizationToken"
      ]

      principals {
        identifiers = var.push_principal_access
        type        = "AWS"
      }
    }
  }

  # Allows services in our org to pull (when organization access is enabled)
  dynamic "statement" {
    for_each = var.enable_organization_access ? [1] : []
    content {
      actions = [
        "ecr:BatchGetImage",
        "ecr:Describe*",
        "ecr:Get*",
        "ecr:List*"
      ]

      principals {
        identifiers = ["*"]
        type        = "AWS"
      }

      condition {
        variable = "aws:SourceOrgID"
        test     = "StringLike"
        values   = [data.aws_organizations_organization.this[0].id]
      }
    }
  }

  # Allows users/roles to access but only if the principal is in our org (when organization access is enabled)
  dynamic "statement" {
    for_each = var.enable_organization_access ? [1] : []
    content {
      actions = [
        "ecr:BatchGetImage",
        "ecr:Describe*",
        "ecr:Get*",
        "ecr:List*"
      ]

      principals {
        identifiers = ["*"]
        type        = "AWS"
      }

      condition {
        variable = "aws:PrincipalOrgId"
        test     = "StringLike"
        values   = [data.aws_organizations_organization.this[0].id]
      }
    }
  }

  # Allows access from current account only (when organization access is disabled)
  dynamic "statement" {
    for_each = var.enable_organization_access ? [] : [1]
    content {
      actions = [
        "ecr:BatchGetImage",
        "ecr:Describe*",
        "ecr:Get*",
        "ecr:List*"
      ]

      principals {
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        type        = "AWS"
      }
    }
  }
}

resource "aws_ecr_lifecycle_policy" "ecr" {
  count      = var.retained_image_count > 0 ? 1 : 0
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.retained_image_count} images",
            "selection": {
                "tagStatus": "tagged",
                "tagPatternList": [
                  "*"
                ],
                "countType": "imageCountMoreThan",
                "countNumber": ${var.retained_image_count}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}