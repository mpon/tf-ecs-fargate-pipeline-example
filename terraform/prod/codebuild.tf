module "codebuild_iam" {
  source                            = "../modules/codebuild_iam"
  name                              = "${local.env}-codebuild-service-role"
  subnet_arns                       = module.vpc.private_subnet_arns
  assets_bucket_arn                 = data.terraform_remote_state.common.outputs.assets_bucket.arn
  codepipeline_artifacts_bucket_arn = aws_s3_bucket.codepipeline.arn
  codebuild_bucket_arn              = aws_s3_bucket.codebuild.arn
}

resource "random_pet" "codebuild" {
  length = 3
}

resource "aws_s3_bucket" "codebuild" {
  bucket = "${local.env}-codebuild-${random_pet.codebuild.id}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "buildspec" {
  bucket = aws_s3_bucket.codebuild.id
  key    = "${local.env}/buildspec.yaml"
  content = templatefile("${path.module}/templates/buildspec.yaml", {
    repository_domain = dirname(data.terraform_remote_state.common.outputs.ecr_rails_blog_example_repository_url)
    repository_url    = data.terraform_remote_state.common.outputs.ecr_rails_blog_example_repository_url
    bucket            = aws_s3_bucket.codebuild.id
    env               = local.env
    database_url      = aws_ssm_parameter.database_url.name
    secret_key_base   = aws_ssm_parameter.secret_key_base.name
  })
}

resource "aws_codebuild_project" "build" {
  name         = "${local.env}-build"
  service_role = module.codebuild_iam.service_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/mpon/rails-blog-example.git"
    git_clone_depth = 1
    buildspec       = "${aws_s3_bucket.codebuild.arn}/${aws_s3_bucket_object.buildspec.key}"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  vpc_config {
    vpc_id             = module.vpc.vpc_id
    subnets            = module.vpc.private_subnets
    security_group_ids = [aws_security_group.private.id, aws_security_group.db.id]
  }
}
