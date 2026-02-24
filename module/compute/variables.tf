variable "private_subnet_ids" {
  type = list(string)
}

variable "web_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}
variable "client" {
  type = string
}

variable "environment" {
  type = string
}