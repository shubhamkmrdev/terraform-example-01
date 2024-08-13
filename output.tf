output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet."
  value       = module.subnet.subnet_id
}

output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = module.ec2_instance.instance_id
}

