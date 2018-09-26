# ----------
# VPC
# ----------
resource "aws_vpc" "main" {
  cidr_block           = "10.15.0.0/16"
  instance_tenancy     = "default"      // default
  enable_dns_support   = "true"         // default
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"        // default

  tags {
    Name = "tf-test"
  }
}

# ----------
# Subnets
# ----------
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.15.1.0/24"
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
