variable "create_vpc" {
  type    = bool
  default = true
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = []
}

variable "private_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = []
}