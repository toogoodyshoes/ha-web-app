variable "az_a_id" {
  type    = string
  default = "aps1-az1"
}

variable "az_b_id" {
  type    = string
  default = "aps1-az2"
}

variable "zone_a_cidr_blocks" {
  type    = list(string)
  default = ["10.16.0.0/27", "10.16.0.32/27", "10.16.0.64/27"]
}

variable "zone_b_cidr_blocks" {
  type    = list(string)
  default = ["10.16.0.96/27", "10.16.0.128/27", "10.16.0.160/27"]
}

variable "zone_a_subnet_names" {
  type    = list(string)
  default = ["Public Subnet A", "Application Subnet A", "Data Subnet A"]
}

variable "zone_b_subnet_names" {
  type    = list(string)
  default = ["Public Subnet B", "Application Subnet B", "Data Subnet B"]
}

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