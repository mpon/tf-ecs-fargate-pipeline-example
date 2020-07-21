module "codebuild_iam" {
  source                            = "../modules/codebuild_iam"
  name                              = "${local.env}-codebuild-service-role"
  subnet_arns                       = module.vpc.private_subnets
  assets_bucket_arn                 = data.terraform_remote_state.common.outputs.assets_bucket.arn
  codepipeline_artifacts_bucket_arn = aws_s3_bucket.codepipeline.arn
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
    buildspec       = "ecs-config/${local.env}/buildspec.yaml"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  vpc_config {
    vpc_id             = module.vpc.vpc_id
    subnets            = module.vpc.private_subnets
    security_group_ids = [aws_security_group.private.id]
  }
}
