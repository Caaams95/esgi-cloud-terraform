variable "vpc_name" {
  description = "Nom du VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR du subnet public"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR du subnet privé"
  type        = string
}

variable "availability_zone" {
  description = "Zone de disponibilité"
  type        = string
}
