resource "aws_iam_service_linked_role" "ecs_application_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
  description      = "Allows Application Auto Scaling to call ECS and CloudWatch on your behalf."
}
