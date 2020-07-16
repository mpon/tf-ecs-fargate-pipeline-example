resource "aws_ecs_cluster" "cluster" {
  name = "${local.env}-cluster"
}
