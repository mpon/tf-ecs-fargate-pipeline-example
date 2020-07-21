resource "random_pet" "codepipeline" {
  length = 3
}

resource "aws_s3_bucket" "codepipeline" {
  bucket = "${local.env}-codepipeline-${random_pet.codepipeline.id}"
  acl    = "private"
}
