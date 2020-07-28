resource "random_pet" "codepipeline" {
  length = 3
}

resource "aws_s3_bucket" "codepipeline" {
  bucket        = "${local.env}-codepipeline-${random_pet.codepipeline.id}"
  acl           = "private"
  force_destroy = true # to make it easier to destroy at this repository example
}

module "codepipeline_iam" {
  source                            = "../modules/codepipeline_iam"
  name                              = "${local.env}-codepipeline-service-role"
  codepipeline_artifacts_bucket_arn = aws_s3_bucket.codepipeline.arn
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${local.env}-deploy-pipeline"
  role_arn = module.codepipeline_iam.service_role_arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifacts"]

      # ref: https://docs.aws.amazon.com/ja_jp/codepipeline/latest/userguide/action-reference-GitHub.html
      configuration = {
        Owner                = dirname(data.github_repository.repo.full_name)
        Repo                 = data.github_repository.repo.name
        Branch               = "master"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["SourceArtifacts"]
      output_artifacts = ["BuildArtifacts"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy-api"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["BuildArtifacts"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.app.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.api.deployment_group_name
        Image1ArtifactName             = "BuildArtifacts"
        Image1ContainerName            = "IMAGE1_NAME"
        TaskDefinitionTemplateArtifact = "BuildArtifacts"
        TaskDefinitionTemplatePath     = "${local.env}/api/taskdef.json"
        AppSpecTemplateArtifact        = "BuildArtifacts"
        AppSpecTemplatePath            = "${local.env}/api/appspec.yaml"
      }
    }

    action {
      name            = "Deploy-web"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["BuildArtifacts"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.app.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.web.deployment_group_name
        Image1ArtifactName             = "BuildArtifacts"
        Image1ContainerName            = "IMAGE1_NAME"
        TaskDefinitionTemplateArtifact = "BuildArtifacts"
        TaskDefinitionTemplatePath     = "${local.env}/web/taskdef.json"
        AppSpecTemplateArtifact        = "BuildArtifacts"
        AppSpecTemplatePath            = "${local.env}/web/appspec.yaml"
      }
    }
  }
}

data "github_repository" "repo" {
  full_name = "${var.github_owner}/${var.github_repo}"
}

resource "random_id" "webhook_secret" {
  byte_length = 32
}

resource "aws_codepipeline_webhook" "webhook" {
  name            = "${local.env}-webhook-github-repo"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.codepipeline.name

  authentication_configuration {
    secret_token = random_id.webhook_secret.b64_url
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

resource "github_repository_webhook" "webhook" {
  repository = data.github_repository.repo.name

  configuration {
    url          = aws_codepipeline_webhook.webhook.url
    content_type = "json"
    insecure_ssl = "false"
    secret       = random_id.webhook_secret.b64_url
  }

  events = ["push"]
}
