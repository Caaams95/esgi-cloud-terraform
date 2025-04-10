variable "my_ip" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "vpc_id" {
  description = "ID du VPC dans lequel déployer les ressources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID pour l'instance EC2"
  type        = string
}
