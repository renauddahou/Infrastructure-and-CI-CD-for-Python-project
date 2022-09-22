resource "aws_lb" "public-lb" {
  subnets            =  aws_subnet.public.*.id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id, aws_security_group.intra.id]
  name               = "${local.prefix}-alb"
  tags               = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-load-balancer" }))
}
resource "aws_lb_target_group" "ip-tg" {
  vpc_id      = aws_vpc.Main.id
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  deregistration_delay = 5
  tags        = local.default_tags
}

resource "aws_lb_listener" "lb-listen" {
  load_balancer_arn = aws_lb.public-lb.arn
  port              = 80
  default_action {
    target_group_arn = aws_lb_target_group.ip-tg.arn
    type             = "forward"
  }
  tags = local.default_tags
}

output "lb-dns" {
  value = "http://${aws_lb.public-lb.dns_name}"
}
