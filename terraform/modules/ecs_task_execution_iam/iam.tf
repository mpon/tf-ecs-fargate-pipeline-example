resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.trust_ecs_tasks.json
}


data "aws_iam_policy_document" "trust_ecs_tasks" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}-policy"
  policy = data.aws_iam_policy_document.policy.json
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "policy" {
  # arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  # Access for parameter store
  statement {
    actions = ["ssm:GetParameters"]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "role" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
