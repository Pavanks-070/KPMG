provider "aws" {
  region = var.region
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.instance_tenancy

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = var.public_subnet_cidr_block_1
  availability_zone = var.public_subnet_1_az

  tags = {
    Name = var.public_subnet_name_1
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = var.public_subnet_cidr_block_2
  availability_zone = var.public_subnet_2_az

  tags = {
    Name = var.public_subnet_name_2
  }
}

resource "aws_subnet" "private_subnet_1" {
  cidr_block        = var.private_subnet_cidr_block_1
  vpc_id            = aws_vpc.terraform_vpc.id
  availability_zone = var.private_subnet_1_az

  tags = {
    Name = var.tagkey_name_private_subnet_1
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.terraform_vpc.id
}

resource "aws_route_table" "public_subnet_1_to_internet" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = var.public_route_table_1
  }
}

resource "aws_route_table_association" "internet_for_public_subnet_1" {
  route_table_id = aws_route_table.public_subnet_1_to_internet.id
  subnet_id      = aws_subnet.public_subnet_1.id
}

resource "aws_eip" "eip_1" {
  count = "1"
}

resource "aws_nat_gateway" "natgateway_1" {
  count         = "1"
  allocation_id = aws_eip.eip_1[count.index].id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_route_table" "natgateway_route_table_1" {
  count  = "1"
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1[count.index].id
  }

  tags = {
    Name = var.tagkey_name_natgateway_route_table_1
  }
}

resource "aws_route_table_association" "private_subnet_1_to_natgateway" {
  count          = "1"
  route_table_id = aws_route_table.natgateway_route_table_1[count.index].id
  subnet_id      = aws_subnet.private_subnet_1.id
}

resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.public_key.public_key_openssh
}

resource "aws_db_instance" "rds_mysql_instance" {
  allocated_storage      = var.rds_allocated_storage
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  name                   = var.rds_name
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = var.rds_parameter_group_name
  skip_final_snapshot    = var.rds_skip_final_snapshot
  publicly_accessible    = var.rds_publicly_accessible
  vpc_security_group_ids = [aws_security_group.alb_sg.id]

  resource "aws_security_group" "alb_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port   = var.rds_from_port
    to_port     = var.rds_to_port
    protocol    = "tcp"
    description = "MySQL"
    self        = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    self        = true
  }

  egress {
    from_port   = var.sg_egress_from_port
    to_port     = var.sg_egress_to_port
    protocol    = var.sg_egress_protocol
    cidr_blocks = var.sg_egress_cidr_blocks
  }

  tags = {
    Name = var.sg_tagname
  }
}

resource "aws_alb" "alb" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Environment = var.alb_tagname
  }
}

