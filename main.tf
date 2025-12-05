variable "vpc_name" {
  type    = string
  default = "vpc-terraform-v3"
}

resource "aws_vpc" "minha_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# Flow logs
resource "aws_flow_log" "example" {
  log_destination      = "arn:aws:s3:::leandro-terraform-clc14"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.minha_vpc.id
}

# Default Security Group (corrigido)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.minha_vpc.id

  tags = {
    Name = "my-iac-sg"
  }
}

## ------------------- SUBNET PRIVADA 1A -------------------
resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "priv-subnet-1a"
  }
}

resource "aws_route_table" "priv_rt_1a" {
  vpc_id = aws_vpc.minha_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1a.id
  }

  tags = {
    Name = "priv-rt-1a"
  }
}

resource "aws_route_table_association" "priv_1a_associate" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.priv_rt_1a.id
}

## ------------------- SUBNET PÚBLICA 1A -------------------
resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub-subnet-1a"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.minha_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "pub_1a_associate" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minha_vpc.id

  tags = {
    Name = "igw-tf-vpc-automation"
  }
}

resource "aws_eip" "nat_gw_ip_1a" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_1a" {
  allocation_id = aws_eip.nat_gw_ip_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "nat-gw-1a"
  }

  depends_on = [aws_internet_gateway.igw]
}

## ------------------- SUBNET PRIVADA 1B -------------------
resource "aws_subnet" "private_subnet_1b" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "priv-subnet-1b"
  }
}

resource "aws_route_table" "priv_rt_1b" {
  vpc_id = aws_vpc.minha_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1b.id
  }

  tags = {
    Name = "priv-rt-1b"
  }
}

resource "aws_route_table_association" "priv_1b_associate" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.priv_rt_1b.id
}

## ------------------- SUBNET PÚBLICA 1B -------------------
resource "aws_subnet" "public_subnet_1b" {
  vpc_id            = aws_vpc.minha_vpc.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "pub-subnet-1b"
  }
}

resource "aws_route_table_association" "pub_1b_associate" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_gw_ip_1b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_1b" {
  allocation_id = aws_eip.nat_gw_ip_1b.id
  subnet_id     = aws_subnet.public_subnet_1b.id

  tags = {
    Name = "nat-gw-1b"
  }

  depends_on = [aws_internet_gateway.igw]
}
