resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.trust_codepipeline.json
}

data "aws_iam_policy_document" "trust_codepipeline" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.name}-policy"
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  /*
    ref: https://docs.aws.amazon.com/ja_jp/codepipeline/latest/userguide/how-to-custom-role.html
   */
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = ["*"]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }

  # Allow CodeDeploy to deploy ECS task
  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
      "ecs:RegisterTaskDefinition",
    ]
    resources = ["*"]
  }

  # Allow codepipeline artifacts bucket
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      var.codepipeline_artifacts_bucket_arn,
      "${var.codepipeline_artifacts_bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:DescribeImages",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "role" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
