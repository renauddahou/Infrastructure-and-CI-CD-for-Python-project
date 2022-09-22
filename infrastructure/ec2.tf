data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] #Canonical
}

resource "aws_instance" "ec2-instance" {
  count = var.debug_ec2 ? 1 : 0
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.public.*.id, 0)
  ami                         = data.aws_ami.ubuntu.id
  # key_name                    = aws_key_pair.connect-key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.ec2-ssh.id, aws_security_group.intra.id]
  # connection {
  #   type        = "ssh"
  #   host        = aws_instance.public_ip
  #   user        = "ubuntu"
  #   private_key = file("~/.ssh/3pgAWS")
  # }
  tags = merge(local.default_tags, tomap({ "Name" : "${local.prefix}-ec2-instance" }))
}

resource "aws_key_pair" "connect-key" {
  count = var.debug_ec2 ? 1 : 0
  key_name   = "boxer-key"
  public_key = var.path_to_public_key_file
}

# output "ec2-public-dns" {
#   value = aws_instance.ec2-instance.public_dns
# }