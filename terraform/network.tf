# ----------
# VPC
# ----------
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"         // default
  enable_dns_support   = "true"            // default
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"           // default

  tags {
    Name = "tf-test"
  }
}

# ----------
# Subnets
# ----------
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${lookup(var.subnet_cidrs, "public")}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_MAIN_AZ}"

  tags {
    Name = "tf-test"
  }
}

# ----------
# Internet Gateway
# ----------
resource "aws_internet_gateway" "main-gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "tf-test"
  }
}

# ----------
# Route Tables
# ----------
resource "aws_route_table" "main-public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-gw.id}"
  }

  tags {
    Name = "tf-test"
  }
}

# associations
resource "aws_route_table_association" "main-public-1a" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.main-public.id}"
}

# ----------
# Security Group
# ----------

# for ecs with elb
resource "aws_security_group" "elb-sg" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "elb-sg"
  description = "security group for ecs"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "fs-elb-sg"
  }
}

resource "aws_security_group" "ecs-ec2-instance-sg" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "ecs-ec2-instance-sg"
  description = "security group for ecs"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    //    security_groups = ["${aws_security_group.elb-sg.id}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ecs"
  }
}
