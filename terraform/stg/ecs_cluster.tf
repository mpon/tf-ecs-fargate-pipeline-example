resource "aws_ecs_cluster" "cluster" {
  name = "${local.env}-cluster"
}

module "ecs_task_execution_iam" {
  source = "../modules/ecs_task_execution_iam"
  name   = "${local.env}-ecs-task-execution-role"
}

module "ecs_events_iam" {
  source = "../modules/ecs_events_iam"
  name   = "${local.env}-ecs-events-role"
}
