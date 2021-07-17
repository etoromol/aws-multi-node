# variables.tf
# aws-multi-node
#
# Var component of the root module.
# Contains the list of global variables.
#
# Copyright (c) 2021 Eduardo Toro

variable "project" {
  description = "Name and Environment type of the infrastructure"
  type        = map(string)
  default = {
    "name"        = "nodes_sandbox"
    "environment" = "d" # d stand for development.
  }
}

variable "access_key" {
  description = "Name of the SSH key selected to access the instances"
  type        = string
  default     = "key_1-uw1-d-etoromol"
}

variable "region" {
  description = "AWS region zone pool used by providers and subnets resources"
  type        = map(string)
  default = {
    "ue1"  = "us-east-1"
    "ue2"  = "us-east-2"
    "ue2a" = "us-east-2a"
    "uw1"  = "us-west-1"
    "uw2"  = "us-west-2"
    "uw1b" = "us-west-1b"
    "uw1c" = "us-west-1c"
  }
}

variable "netblock" {
  description = "Network pool used by vpc and subnets resources"
  type        = map(string)
  default = {
    "default" = "0.0.0.0/0"
    "network" = "10.0.0.0/16"
    "public"  = "10.0.1.0/24"
    "private" = "10.0.2.0/24"
  }
}

# Variables below contain a pool of 
# Elastic Cloud Compute instances
# organized for easy deployments

variable "vm0" {
  description = "Amazon Linux 2"
  type        = map(any)
  default = {
    "name"              = "AWSLinux"
    "ami"               = "ami-0ed05376b59b90e46"
    "instance_type"     = "t2.micro"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm1" {
  description = "cat8000v - BYO with IOS XE 17.4.1b"
  type        = map(any)
  default = {
    "name"              = "cat8000vm1"
    "ami"               = "ami-0566d868d1b4458fd"
    "instance_type"     = "t3.medium"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm2" {
  description = "cat8000v - BYO with IOS XE 17.05.1a"
  type        = map(any)
  default = {
    "name"              = "cat8000vm2"
    "ami"               = "ami-0b09ad6ef5daf67b1"
    "instance_type"     = "t3.medium"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm3" {
  description = "csr1000v with IOS XE 17.3.3"
  type        = map(any)
  default = {
    "name"              = "csr1000vm1"
    "ami"               = "ami-078986d887163741b"
    "instance_type"     = "t2.medium"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm4" {
  description = "csr1000v - Security Pkg. Max Performance with IOS XE 16.12.5"
  type        = map(any)
  default = {
    "name"              = "csr1000vm2"
    "ami"               = "ami-0a51195a8716a60e4"
    "instance_type"     = "t2.medium"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm5" {
  description = "csr1000v - Security Pkg. Max Performance with IOS XE 16.9.2"
  type        = map(any)
  default = {
    "name"              = "csr1000vm3"
    "ami"               = "ami-02b1bc6d2e4aa01a6"
    "instance_type"     = "t2.medium"
    "availability_zone" = "us-east-2a"
    "key_name"          = ""
  }
}

variable "vm6" {
  description = "Red Hat Enterprise Linux 8 (HVM), SSD Volume Type"
  type        = map(any)
  default = {
    "name"              = "rhelm1"
    "ami"               = "ami-054965c6cd7c6e462"
    "instance_type"     = "t2.micro"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm7" {
  description = "Ubuntu Server 20.04 LTS (HVM), SSD Volume Type"
  type        = map(any)
  default = {
    "name"              = "ubuntum1"
    "ami"               = "ami-0d382e80be7ffdae5"
    "instance_type"     = "t2.micro"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm8" {
  description = "Microsoft Windows Server 2012 R2 Base"
  type        = map(any)
  default = {
    "name"              = "windowsm3"
    "ami"               = "ami-0c980234db5b91d44"
    "instance_type"     = "t2.micro"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm9" {
  description = "Microsoft Windows Server 2016 Base"
  type        = map(any)
  default = {
    "name"              = "windowsm2"
    "ami"               = "ami-0807f3d00dc7f1d6e"
    "instance_type"     = "t2.micro"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}

variable "vm10" {
  description = "Microsoft Windows Server 2019 Base"
  type        = map(any)
  default = {
    "name"              = "windowsm1"
    "ami"               = "ami-0c645579c7f157046"
    "instance_type"     = "t2.micro"
    "availability_zone" = "us-west-1b"
    "key_name"          = ""
  }
}
