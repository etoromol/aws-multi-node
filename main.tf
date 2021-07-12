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

# Resource tag name arguments created by interpolating 
# the 'resource name'-'environment value'-'name value'
# from global variable "project".
locals {
  vpc_name        = "vpc-${var.project["environment"]}-${var.project["name"]}"
  igw_name        = "igw-${var.project["environment"]}-${var.project["name"]}"
  seg_name        = "seg-${var.project["environment"]}-${var.project["name"]}"
  snt_public_name = "snt-${var.project["environment"]}-${var.project["name"]}"
  rtb_public_name = "rtb-${var.project["environment"]}-${var.project["name"]}"
  nic_public_name = "nic-${var.project["environment"]}-${var.project["name"]}"
  eip_name        = "eip-${var.project["environment"]}-${var.project["name"]}"
}

resource "aws_vpc" "vpc_multi_node" {
  cidr_block           = var.netblock["network"]
  instance_tenancy     = "default"

  tags = {
    Name = ""
  }
}

# Subnets
resource "aws_subnet" "snt_public" {
  vpc_id            = aws_vpc.vpc_multi_node.id
  cidr_block        = var.netblock["public"]
  availability_zone = var.region["uw1b"]

  tags = {
    Name = ""
  }
}

resource "aws_subnet" "snt_private" {
  vpc_id            = aws_vpc.vpc_multi_node.id
  cidr_block        = var.netblock["private"]
  availability_zone = var.region["uw1b"]

  tags = {
    Name = ""
  }
}

# Gateways:
resource "aws_internet_gateway" "igw_multi_node" {
  vpc_id = aws_vpc.vpc_multi_node.id

  tags = {
    Name = ""
  }
}

resource "aws_route_table" "rta_public" {
  vpc_id = aws_vpc.vpc_multi_node.id

  route {
    cidr_block = var.netblock["default"]
    gateway_id = aws_internet_gateway.igw_multi_node.id
  }

  tags = {
    Name = ""
  }
}

resource "aws_route_table" "rta_private" {
  vpc_id = aws_vpc.vpc_multi_node.id

  route {
    cidr_block  = var.netblock["default"]
    network_interface_id = aws_network_interface.nic_02.id
  }

  tags = {
    Name = local.rtb_public_name
  }
}

# Associations
resource "aws_route_table_association" "ass_public" {
  subnet_id      = aws_subnet.snt_public.id
  route_table_id = aws_route_table.rta_public.id
}

resource "aws_route_table_association" "ass_private" {
  subnet_id      = aws_subnet.snt_private.id
  route_table_id = aws_route_table.rta_private.id
}

# Security group
resource "aws_security_group" "seg_multi_node" {
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
    Name = ""
  }
}

# Network Interfaces
resource "aws_network_interface" "nic_01" {
  subnet_id       = aws_subnet.snt_public.id
  security_groups = [aws_security_group.seg_multi_node.id]
  source_dest_check = false
  private_ips     = ["10.0.1.100"]

  tags = {
    Name = ""
  }
}

resource "aws_network_interface" "nic_02" {
  subnet_id       = aws_subnet.snt_private.id
  security_groups = [aws_security_group.seg_multi_node.id]
  source_dest_check = false
  private_ips     = ["10.0.2.100"]

  tags = {
    Name = ""
  }
}

# Elastic IPs
resource "aws_eip" "eip_inband" {
  depends_on = [aws_internet_gateway.igw_multi_node]
  vpc        = true
  network_interface = aws_network_interface.nic_01.id

  tags = {
    "Name" = ""
  }
}

# HUB MACHINE
resource "aws_instance" "ec2_01" {
  ami               = var.vm1["ami"]
  instance_type     = var.vm1["instance_type"]
  availability_zone = var.vm1["availability_zone"]
  key_name          = var.access_key
  
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic_01.id
  }

   network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.nic_02.id
  }

  tags = {
    Name = var.vm1["name"]
  }
}

# PRIVATE MACHINE
resource "aws_instance" "ec2_02" {
  ami               = var.vm0["ami"]
  instance_type     = var.vm0["instance_type"]
  availability_zone = var.vm0["availability_zone"]
  key_name          = var.access_key
  subnet_id         = aws_subnet.snt_private.id
  security_groups = [aws_security_group.seg_multi_node.id]

  tags = {
    Name = var.vm0["name"]
  }
}
