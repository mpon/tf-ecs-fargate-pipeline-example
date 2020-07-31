resource "aws_cloudwatch_log_group" "export" {
  name              = "/ecs/scheduled_task/${local.env}/export"
  retention_in_days = 7
}

resource "aws_cloudwatch_event_rule" "export" {
  name                = "${local.env}-export"
  description         = "export ${local.env}"
  schedule_expression = "rate(30 minutes)"
  is_enabled          = true
}

resource "aws_ecs_task_definition" "export" {
  family = "${local.env}-export"
  container_definitions = templatefile("${path.module}/templates/export/container_definitions.json", {
    image               = data.terraform_remote_state.common.outputs.ecr_rails_blog_example_repository_url
    awslogs_group       = aws_cloudwatch_log_group.export.name
    awslogs_region      = data.aws_region.current.name
    aws_region          = data.aws_region.current.name
    database_url_arn    = aws_ssm_parameter.database_url.arn
    secret_key_base_arn = aws_ssm_parameter.secret_key_base.arn
  })
  execution_role_arn       = module.ecs_task_execution_iam.service_role_arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
}

resource "aws_cloudwatch_event_target" "export" {
  rule     = aws_cloudwatch_event_rule.export.name
  arn      = aws_ecs_cluster.cluster.arn
  role_arn = module.ecs_events_iam.service_role_arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.export.arn

    network_configuration {
      subnets         = module.vpc.private_subnets
      security_groups = [aws_security_group.private.id, aws_security_group.db.id]
    }
  }

  input = <<EOF
{
  "containerOverrides": [
    {
      "name": "rails",
      "command": ["rails", "scheduled:export", "RAILS_ENV=production"]
    }
  ]
}
EOF
}