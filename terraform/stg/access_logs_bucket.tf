resource "random_pet" "access_logs" {
  length = 3
}

resource "aws_s3_bucket" "access_logs" {
  bucket        = "${local.env}-access-logs-${random_pet.access_logs.id}"
  acl           = "private"
  force_destroy = true # to make it easier to destroy at this repository example
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  policy = data.aws_iam_policy_document.access_logs.json
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "access_logs" {
  # Allow from Elastic Load Balancing account
  # ref: https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-access-logs.html
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.access_logs.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }
}
