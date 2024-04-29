output "wp_vpc" {
  value = aws_vpc.wordpress
}

output "zone_a_subnets" {
  value = aws_subnet.zone_a_subnets
}

output "zone_b_subnets" {
  value = aws_subnet.zone_b_subnets
}


