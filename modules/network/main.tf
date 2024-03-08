# VPC
resource "aws_vpc" "wordpress" {
  cidr_block = "10.16.0.0/24"

  tags = {
    Name = "Wordpress"
  }
}

# Zone A Subnets
resource "aws_subnet" "zone_a_subnets" {
  count = 3

  vpc_id               = aws_vpc.wordpress.id
  cidr_block           = var.zone_a_cidr_blocks[count.index]
  availability_zone_id = var.az_a_id

  tags = {
    Name = var.zone_a_subnet_names[count.index]
  }
}

# Zone B Subnets
resource "aws_subnet" "zone_b_subnets" {
  count = 3

  vpc_id               = aws_vpc.wordpress.id
  cidr_block           = var.zone_b_cidr_blocks[count.index]
  availability_zone_id = var.az_b_id

  tags = {
    Name = var.zone_b_subnet_names[count.index]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "wordpress_ig" {
  vpc_id = aws_vpc.wordpress.id

  tags = {
    Name = "Wordpress Internet Gateway"
  }
}

# PUblic Subnet Route Table
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_ig.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_a" {
  route_table_id = aws_route_table.public_subnet_rt.id
  subnet_id      = element(aws_subnet.zone_a_subnets, var.public_subnet_a_index).id
}

resource "aws_route_table_association" "public_subnet_b" {
  route_table_id = aws_route_table.public_subnet_rt.id
  subnet_id      = element(aws_subnet.zone_b_subnets, var.public_subnet_b_index).id
}

# Elastic IPs for Nat Gateways
resource "aws_eip" "nat_gateway_a" {}

resource "aws_eip" "nat_gateway_b" {}


# NAT Gateways
resource "aws_nat_gateway" "public_subnet_a_ng" {
  subnet_id         = element(aws_subnet.zone_a_subnets, var.public_subnet_a_index).id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_gateway_a.id

  depends_on = [aws_internet_gateway.wordpress_ig]

  tags = {
    Name = "Public Subnet A NAT Gateway"
  }
}

resource "aws_nat_gateway" "public_subnet_b_ng" {
  subnet_id         = element(aws_subnet.zone_b_subnets, var.public_subnet_b_index).id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_gateway_b.id

  depends_on = [aws_internet_gateway.wordpress_ig]

  tags = {
    Name = "Public Subnet B NAT Gateway"
  }
}

# Application Subnet A Route Table
resource "aws_route_table" "application_subnet_a_rt" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_subnet_a_ng.id
  }

  tags = {
    Name = "Application Subnet A RT"
  }
}

resource "aws_route_table_association" "application_subnet_a" {
  route_table_id = aws_route_table.application_subnet_a_rt.id
  subnet_id      = element(aws_subnet.zone_a_subnets, var.application_subnet_a_index).id
}


# Application Subnet B Route Table
resource "aws_route_table" "application_subnet_b_rt" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_subnet_b_ng.id
  }

  tags = {
    Name = "Application Subnet B RT"
  }
}

resource "aws_route_table_association" "application_subnet_b" {
  route_table_id = aws_route_table.application_subnet_b_rt.id
  subnet_id      = element(aws_subnet.zone_b_subnets, var.application_subnet_b_index).id
}
