resource "aws_lb" "public" {
  name                       = "${local.env}-public"
  security_groups            = [aws_security_group.public.id]
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = true

  tags = {
    Name        = "${local.env}-public"
    Environment = local.env
  }

  access_logs {
    bucket  = aws_s3_bucket.access_logs.bucket
    prefix  = "ALB/${local.env}-public"
    enabled = true
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "api_blue" {
  name        = "${local.env}-api-blue"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/" # TODO: change healthcheck path
  }
}

resource "aws_lb_target_group" "api_green" {
  name        = "${local.env}-api-green"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/" # TODO: change healthcheck path
  }
}

resource "aws_lb_target_group" "web_blue" {
  name        = "${local.env}-web-blue"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/" # TODO: change healthcheck path
  }
}

resource "aws_lb_target_group" "web_green" {
  name        = "${local.env}-web-green"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/" # TODO: change healthcheck path
  }
}


resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.public_http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_blue.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  lifecycle {
    # Target group will be updated by CodeDeploy
    ignore_changes = [action]
  }
}

resource "aws_lb_listener_rule" "web" {
  listener_arn = aws_lb_listener.public_http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_blue.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    # Target group will be updated by CodeDeploy
    ignore_changes = [action]
  }
}
