# outputs.tf
# aws-multi-node
#
# Output component of the root module.
# Contains the list of output variables
# related with ec2-instances created. 
#
# Copyright (c) 2021 Eduardo Toro

output "ec2_01_public_ip" {
  value = aws_instance.ec2_01.public_ip
}

output "ec2_02_private_ip" {
  value = aws_instance.ec2_02.private_ip
}

output "ec2_03_private_ip" {
  value = aws_instance.ec2_03.private_ip
}
