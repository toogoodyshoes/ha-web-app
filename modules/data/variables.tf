variable "data_subnet_a_index" {
    type = number
    default = 2
}

variable "data_subnet_b_index" {
    type = number
    default = 2
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