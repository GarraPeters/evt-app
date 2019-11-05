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
  for_each    = aws_alb.main
  name        = "${var.aws_alb_target_group_name}-${var.service_config[each.key].name}"
  port        = var.service_config[each.key].port
  protocol    = "HTTP"
  vpc_id      = var.aws_vpc_main_id
  target_type = "ip"
}



# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "container_listener" {
  for_each          = aws_alb.main
  load_balancer_arn = aws_alb.main[each.key].id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app[each.key].id
  }

  depends_on = [aws_alb_target_group.app]
}

# resource "aws_alb_listener" "container_listener_secure" {
#   for_each          = aws_alb.main
#   load_balancer_arn = aws_alb.main[each.key].id
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.aws_acm_certificate_validation_default_certificate_arn[each.key].certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.app[each.key].id
#   }

#   depends_on = [aws_alb_target_group.app]
# }
