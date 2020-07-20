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
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "public_https" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}
