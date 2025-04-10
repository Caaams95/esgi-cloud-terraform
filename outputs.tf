output "instance_ip_addr" {
  value = module.ec2_instance.instance_ip_addr
}
output "vpc_id" {
  value = module.network.vpc_id
}
