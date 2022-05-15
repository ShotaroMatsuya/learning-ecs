resource "aws_ecr_repository" "main" {
  name = var.ecr_repo_name

  image_scanning_configuration {
    scan_on_push = true
    # this scan takes place afeter you've actually pushed your image
  }
}

# setting up permissions for ecr repository
# codebuild permitted for four actions on our ECR repository and will restrict codeBuild to only carry out the specific ones.
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CodeBuildAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
EOF
}
