### ALB

resource "aws_alb" "main" {
  for_each        = var.service_config
  name            = "${var.aws_alb_name}-${var.service_config[each.key].name}"
  internal        = false
  subnets         = var.aws_subnets.*.id
  security_groups = [var.aws_security_group_lb_id]
  tags            = var.service_config[each.key].tags
}

resource "aws_alb_target_group" "app" {
  for_each    = var.service_config
  name        = "${var.aws_alb_target_group_name}-${var.service_config[each.key].name}"
  port        = var.service_config[each.key].port
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_main_id
  target_type = "ip"
}
