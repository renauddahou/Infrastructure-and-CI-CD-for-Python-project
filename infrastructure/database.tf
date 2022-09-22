resource "aws_db_instance" "box-instance" {
  identifier             = local.prefix
  allocated_storage      = 20
  instance_class         = "db.t2.micro"
  engine                 = "mysql"
  username               = var.db_username
  password               = var.db_password
  db_name = var.db_name
  publicly_accessible    = true
  availability_zone      = "us-east-1a"
  tags                   = local.default_tags
  skip_final_snapshot    = true
  db_subnet_group_name   = element(aws_db_subnet_group.box-subnet-group.*.name, 0)
  vpc_security_group_ids = [aws_security_group.intra.id]

  # provisioner "local-exec" {
  #   command = "mysql -u ${self.username} -p ${self.password} < ../boxer/box.sql"
  # }
}

output "db-dns" {
  value = aws_db_instance.box-instance.address
}