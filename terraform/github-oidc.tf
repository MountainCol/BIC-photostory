# Reference existing GitHub OIDC Identity Provider
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "terraform-oidc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:MountainCol/BIC-photostory:ref:refs/heads/module-02"
          }
        }
      }
    ]
  })

  tags = {
    Name = "github-actions-oidc-role"
  }
}

# Policy for S3 access
resource "aws_iam_policy" "github_actions_s3" {
  name        = "GitHubActionsS3Policy"
  description = "Policy for GitHub Actions to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::bic-photostory",
          "arn:aws:s3:::bic-photostory/*"
        ]
      }
    ]
  })
}

# Policy for CloudFront access
resource "aws_iam_policy" "github_actions_cloudfront" {
  name        = "GitHubActionsCloudFrontPolicy"
  description = "Policy for GitHub Actions to invalidate CloudFront"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations"
        ]
        Resource = "*"
      }
    ]
  })
}
# Policy for IAM read access (needed for Terraform data sources)
resource "aws_iam_policy" "github_actions_iam_read" {
  name        = "GitHubActionsIAMReadPolicy"
  description = "Policy for GitHub Actions to read IAM resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:ListOpenIDConnectProviders",
          "iam:GetOpenIDConnectProvider",
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach IAM read policy to role
resource "aws_iam_role_policy_attachment" "github_actions_iam_read" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_iam_read.arn
}
# Attach S3 policy to role
resource "aws_iam_role_policy_attachment" "github_actions_s3" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_s3.arn
}

# Attach CloudFront policy to role
resource "aws_iam_role_policy_attachment" "github_actions_cloudfront" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_cloudfront.arn
}

# Output the role ARN for GitHub secrets
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "ARN of the GitHub Actions OIDC role"
}
