resource "random_pet" "assets" {
  length = 3
}

resource "aws_s3_bucket" "assets" {
  bucket = "server-assets-${random_pet.assets.id}"
}

resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.assets_bucket.json
}

data "aws_iam_policy_document" "assets_bucket" {
  # public read
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::server-assets-${random_pet.assets.id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
