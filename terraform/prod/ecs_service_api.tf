/*
  If you change this resource it won't take effect.
  This resource is for registration task definition first time.
  Subsequent deployments are executed by CodePipeline. 
*/
resource "aws_ecs_task_definition" "api" {
  family                   = "${local.env}-api"
  container_definitions    = file("../templates/container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_iam.service_role_arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "api" {
  name            = "${local.env}-api"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.api_blue.arn
    container_name   = "rails"
    container_port   = 3000
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.private.id]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
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

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/service/${local.env}/api"
  retention_in_days = 7
}

module "api_autoscaling" {
  source = "../modules/ecs_appautoscaling"

  cluster_name     = aws_ecs_cluster.cluster.name
  service_name     = aws_ecs_service.api.name
  min_capacity     = 1
  max_capacity     = 3
  cpu_target_value = 60
  role_arn         = data.terraform_remote_state.common.outputs.ecs_application_autoscaling_role_arn
}
