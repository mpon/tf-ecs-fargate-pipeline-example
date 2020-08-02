/*
  If you change this resource it won't take effect.
  This resource is for registration task definition first time.
  Subsequent deployments are executed by CodePipeline. 
*/
resource "aws_ecs_task_definition" "web" {
  family                   = "${local.env}-web"
  container_definitions    = file("${path.module}/templates/template_rails_container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_iam.service_role_arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
}

/*
  This resource is actually used for subsequent deployments by CodePipeline.
*/
resource "aws_s3_bucket_object" "web_task_definition" {
  bucket = aws_s3_bucket.codebuild.id
  key    = "${local.env}/web/taskdef.json"
  content = templatefile("${path.module}/templates/web/taskdef.json", {
    execution_role_arn        = module.ecs_task_execution_iam.service_role_arn
    awslogs_group             = aws_cloudwatch_log_group.web.name
    awslogs_region            = data.aws_region.current.name
    aws_region                = data.aws_region.current.name
    memory                    = 512
    task_role_arn             = module.ecs_task_execution_iam.service_role_arn
    family                    = aws_ecs_task_definition.web.family
    cpu                       = 256
    database_url_param_arn    = aws_ssm_parameter.database_url.arn
    secret_key_base_param_arn = aws_ssm_parameter.secret_key_base.arn
    asset_bucket_param_arn    = aws_ssm_parameter.asset_bucket.arn
    asset_host_param_arn      = aws_ssm_parameter.asset_host.arn
  })
}

resource "aws_s3_bucket_object" "web_appspec" {
  bucket = aws_s3_bucket.codebuild.id
  key    = "${local.env}/web/appspec.yaml"
  source = "${path.module}/templates/web/appspec.yaml"
  etag   = filemd5("${path.module}/templates/web/appspec.yaml")
}

resource "aws_ecs_service" "web" {
  name            = "${local.env}-web"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 0 # desired_count will be updated by autoscaling

  load_balancer {
    target_group_arn = aws_lb_target_group.web_blue.arn
    container_name   = "rails"
    container_port   = 3000
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.private.id, aws_security_group.db.id]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 2
    base              = 1
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  lifecycle {
    # This parameter will be chaned by CodeDeploy
    ignore_changes = [
      desired_count,
      task_definition,
      load_balancer,
      network_configuration,
      placement_strategy,
    ]
  }
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/service/${local.env}/web"
  retention_in_days = 7
}

module "web_autoscaling" {
  source = "../modules/ecs_appautoscaling"

  cluster_name     = aws_ecs_cluster.cluster.name
  service_name     = aws_ecs_service.web.name
  min_capacity     = 3
  max_capacity     = 6
  cpu_target_value = 60
  role_arn         = data.terraform_remote_state.common.outputs.ecs_application_autoscaling_role_arn
}
