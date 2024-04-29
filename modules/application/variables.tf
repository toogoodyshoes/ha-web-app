variable "public_subnet_a_index" {
    type = number
    default = 0
}

variable "public_subnet_b_index" {
    type = number
    default = 0
}

variable "application_subnet_a_index" {
    type = number
    default = 1
}

variable "application_subnet_b_index" {
    type = number
    default = 1
}

variable "vpc-id" {
    type = string
}

variable "zone-a-subnets" {}

variable "zone-b-subnets" {}

variable "db-client-sg-id" {
    type = string
}

variable "wp-fs-client-sg-id" {
  type = string
}