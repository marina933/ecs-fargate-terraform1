# ECS Task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy_attach" {
  name = "ecs-task-execution-role-policy-attach"
  roles = [
    aws_iam_role.ecs_task_execution_role.name
  ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Github action IAM User

resource "aws_iam_policy" "ecr_ecs_github_actions_access_policy" {
  name        = "ecr-ecs-github-actions-access-policy"
  description = "Allows Github Actions to push to ECR and deploy to ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage"
      ],
      Resource = [module.vite_app_repository.repository_arn]
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:UpdateService",
        ],
        Resource = [aws_ecs_service.vite_app_service.id]
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_user" "github_actions_user" {
  name = "github-actions-user"
  tags = var.common_tags
}

resource "aws_iam_access_key" "github_actions_user_access_key" {
  user = aws_iam_user.github_actions_user.name
}

resource "aws_iam_policy_attachment" "github_actions_user_policy_attach" {
  name = "github-actions-user-policy-attach"
  users = [
    aws_iam_user.github_actions_user.name
  ]
  policy_arn = aws_iam_policy.ecr_ecs_github_actions_access_policy.arn
}