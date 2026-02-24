variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type = string
  default = "My-Defaut-VPC"
  
}

variable "existing_vpc_id" {
  type    = string
  default = null

  validation {
    condition     = var.create_vpc || var.existing_vpc_id != null
    error_message = "existing_vpc_id must be provided when create_vpc is false."
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    condition     = !var.create_vpc || var.vpc_cidr != null
    error_message = "vpc_cidr must be provided when create_vpc is true."
  }
}

variable "environment" {
  type        = string
}

variable "client" {
  type        = string
}
