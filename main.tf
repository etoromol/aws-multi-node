# main.tf
# aws-multi-node
#
# Main component of the root module.
# Contains the list of resources to 
# create the infrastructure in aws. 
#
# Copyright (c) 2021 Eduardo Toro

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region["uw1"]
}

# Resource's tag name arguments created by interpolating 
# the 'resource name'-'environment value'-'name value'
# from global variable "project".

locals {
  vpc_name         = "vpc-${var.project["environment"]}-${var.project["name"]}"
  eip_01_name      = "eip_01-${var.project["environment"]}-${var.project["name"]}"
  eip_02_name      = "eip_02-${var.project["environment"]}-${var.project["name"]}"
  igw_name         = "igw-${var.project["environment"]}-${var.project["name"]}"
  ngw_name         = "ngw-${var.project["environment"]}-${var.project["name"]}"
  snt_public_name  = "snt_public-${var.project["environment"]}-${var.project["name"]}"
  snt_private_name = "snt_private-${var.project["environment"]}-${var.project["name"]}"
  seg_public_name  = "seg-${var.project["environment"]}-${var.project["name"]}"
  seg_private_name = "seg-${var.project["environment"]}-${var.project["name"]}"
  rta_public_name  = "rta_public-${var.project["environment"]}-${var.project["name"]}"
  rta_private_name = "rta_private-${var.project["environment"]}-${var.project["name"]}"
  nic_01_name      = "nic_01-${var.project["environment"]}-${var.project["name"]}"
  nic_02_name      = "nic_02-${var.project["environment"]}-${var.project["name"]}"
  nic_03_name      = "nic_03-${var.project["environment"]}-${var.project["name"]}"
}

resource "aws_vpc" "vpc_multi_node" {
  cidr_block       = var.netblock["network"]
  instance_tenancy = "default"

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_eip" "eip_01" {
  depends_on = [aws_internet_gateway.igw_multi_node]
  vpc        = true

  tags = {
    "Name" = local.eip_01_name
  }
}

resource "aws_eip" "eip_02" {
  depends_on        = [aws_internet_gateway.igw_multi_node]
  network_interface = aws_network_interface.nic_01.id
  vpc               = true

  tags = {
    "Name" = local.eip_02_name
  }
}

resource "aws_internet_gateway" "igw_multi_node" {
  vpc_id = aws_vpc.vpc_multi_node.id

  tags = {
    Name = local.igw_name
  }
}

resource "aws_nat_gateway" "ngw_multi_node" {
  depends_on    = [aws_internet_gateway.igw_multi_node]
  allocation_id = aws_eip.eip_01.id
  subnet_id     = aws_subnet.snt_public.id

  tags = {
    Name = local.ngw_name
  }
}

resource "aws_subnet" "snt_public" {
  vpc_id            = aws_vpc.vpc_multi_node.id
  cidr_block        = var.netblock["public"]
  availability_zone = var.region["uw1b"]

  tags = {
    Name = local.snt_public_name
  }
}

resource "aws_subnet" "snt_private" {
  vpc_id            = aws_vpc.vpc_multi_node.id
  cidr_block        = var.netblock["private"]
  availability_zone = var.region["uw1b"]

  tags = {
    Name = local.snt_private_name
  }
}

resource "aws_security_group" "seg_public" {
  vpc_id      = aws_vpc.vpc_multi_node.id
  description = "Allow only SSH traffic from any source"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = local.seg_public_name
  }
}

resource "aws_security_group" "seg_private" {
  vpc_id      = aws_vpc.vpc_multi_node.id
  description = "Allow only SSH, ICMP, TLS inbound traffic from any source"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = local.seg_private_name
  }
}

resource "aws_route_table" "rta_public" {
  vpc_id = aws_vpc.vpc_multi_node.id

  route {
    cidr_block = var.netblock["default"]
    gateway_id = aws_internet_gateway.igw_multi_node.id
  }

  tags = {
    Name = local.rta_public_name
  }
}

resource "aws_route_table" "rta_private" {
  vpc_id = aws_vpc.vpc_multi_node.id

  route {
    cidr_block     = var.netblock["default"]
    nat_gateway_id = aws_nat_gateway.ngw_multi_node.id
  }

  tags = {
    Name = local.rta_private_name
  }
}

resource "aws_route_table_association" "ass_public" {
  subnet_id      = aws_subnet.snt_public.id
  route_table_id = aws_route_table.rta_public.id
}

resource "aws_route_table_association" "ass_private" {
  subnet_id      = aws_subnet.snt_private.id
  route_table_id = aws_route_table.rta_private.id
}

resource "aws_network_interface" "nic_01" {
  subnet_id       = aws_subnet.snt_public.id
  security_groups = [aws_security_group.seg_public.id]
  private_ips     = ["10.0.1.117"]

  tags = {
    Name = local.nic_01_name
  }
}

resource "aws_network_interface" "nic_02" {
  subnet_id       = aws_subnet.snt_private.id
  security_groups = [aws_security_group.seg_private.id]
  private_ips     = ["10.0.2.11"]

  tags = {
    Name = local.nic_02_name
  }
}

resource "aws_network_interface" "nic_03" {
  subnet_id       = aws_subnet.snt_private.id
  security_groups = [aws_security_group.seg_private.id]
  private_ips     = ["10.0.2.22"]

  tags = {
    Name = local.nic_03_name
  }
}

# Elastic Cloud Compute Instances:
#  ec2_00: Amazon Linux 2
#  ec2_01: cat8000v - 17.4.1b
#  ec2_02: csr1000v - 17.3.3

resource "aws_instance" "ec2_01" {
  ami               = var.vm0["ami"]
  instance_type     = var.vm0["instance_type"]
  availability_zone = var.vm0["availability_zone"]
  key_name          = var.access_key

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic_01.id
  }

  tags = {
    Name = var.vm0["name"]
  }
}

resource "aws_instance" "ec2_02" {
  ami               = var.vm1["ami"]
  instance_type     = var.vm1["instance_type"]
  availability_zone = var.vm1["availability_zone"]
  key_name          = var.access_key

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic_02.id
  }

  tags = {
    Name = var.vm1["name"]
  }
}

resource "aws_instance" "ec2_03" {
  ami               = var.vm3["ami"]
  instance_type     = var.vm3["instance_type"]
  availability_zone = var.vm3["availability_zone"]
  key_name          = var.access_key

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic_03.id
  }

  tags = {
    Name = var.vm3["name"]
  }
}
