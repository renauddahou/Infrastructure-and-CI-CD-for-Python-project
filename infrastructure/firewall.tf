
resource "aws_security_group" "ec2-ssh" {
  vpc_id = aws_vpc.Main.id
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Vivien Macbook"
  }

  tags = local.default_tags
}

resource "aws_security_group" "public" {
  vpc_id      = aws_vpc.Main.id
  name        = "${local.prefix}-public"
  description = "Allow public traffic on HTTP"
  tags        = local.default_tags
}

resource "aws_security_group" "intra" {
  vpc_id      = aws_vpc.Main.id
  name        = "${local.prefix}-intra"
  description = "Security group for database"
  tags        = local.default_tags
}

resource "aws_security_group_rule" "intra-ingress" {
  type              = "ingress"
  from_port         = "0" 
  to_port           = "0"
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.intra.id
  description       = "internal traffic"
}

resource "aws_security_group_rule" "intra-egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.intra.id
}

resource "aws_security_group_rule" "public-ingress" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public-egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
