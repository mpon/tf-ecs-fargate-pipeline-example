resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.trust_codebuild.json
}

data "aws_iam_policy_document" "trust_codebuild" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
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
  /*
    ref:
    https://docs.aws.amazon.com/ja_jp/codebuild/latest/userguide/setting-up.html#setting-up-service-role
    https://docs.aws.amazon.com/ja_jp/codebuild/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html#customer-managed-policies-example-create-vpc-network-interface
   */
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]
    resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = var.subnet_arns
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  # Access for parameter store
  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }

  # Allow upload to assets bucket
  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject*",
    ]
    resources = [
      var.assets_bucket_arn,
      "${var.assets_bucket_arn}/*",
    ]
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

  # Allow codebuild bucket
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      var.codebuild_bucket_arn,
      "${var.codebuild_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "role" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}
