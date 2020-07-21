module "codedeploy_iam" {
  source = "../modules/codedeploy_iam"
  name   = "${local.env}-codedeploy-service-role"
}

resource "aws_codedeploy_app" "app" {
  name             = "${local.env}-app"
  compute_platform = "ECS"
}

# Deployment for API service

resource "aws_codedeploy_deployment_group" "api" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "${local.env}-api"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = module.codedeploy_iam.service_role_arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.cluster.name
    service_name = aws_ecs_service.api.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.public_http.arn]
      }

      target_group {
        name = aws_lb_target_group.api_blue.name
      }

      target_group {
        name = aws_lb_target_group.api_green.name
      }
    }
  }
}

# Deployment for Web service

resource "aws_codedeploy_deployment_group" "web" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "${local.env}-web"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = module.codedeploy_iam.service_role_arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.cluster.name
    service_name = aws_ecs_service.web.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.public_http.arn]
      }

      target_group {
        name = aws_lb_target_group.web_blue.name
      }

      target_group {
        name = aws_lb_target_group.web_green.name
      }
    }
  }
}
