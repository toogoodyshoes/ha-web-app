terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }
}

provider "aws" {
  region              = "ap-south-1"
  shared_config_files = ["$HOME/.aws/config"]
  profile             = "test"
}

resource "aws_vpc" "ha-web-app" {
  cidr_block = "10.16.0.0/24"

  tags = {
    Name = "ha-web-app"
  }
}


resource "aws_subnet" "public-a" {
  vpc_id               = aws_vpc.ha-web-app.id
  cidr_block           = "10.16.0.0/27"
  availability_zone_id = "aps1-az1"

  tags = {
    Name = "Public Subnet A"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id               = aws_vpc.ha-web-app.id
  cidr_block           = "10.16.0.32/27"
  availability_zone_id = "aps1-az2"

  tags = {
    Name = "Public Subnet B"
  }
}

resource "aws_subnet" "app-a" {
  vpc_id               = aws_vpc.ha-web-app.id
  cidr_block           = "10.16.0.64/27"
  availability_zone_id = "aps1-az1"

  tags = {
    Name = "Application Subnet A"
  }
}

resource "aws_subnet" "app-b" {
  vpc_id               = aws_vpc.ha-web-app.id
  cidr_block           = "10.16.0.96/27"
  availability_zone_id = "aps1-az2"

  tags = {
    Name = "Application Subnet B"
  }
}

resource "aws_subnet" "data-a" {
  vpc_id               = aws_vpc.ha-web-app.id
  cidr_block           = "10.16.0.128/27"
  availability_zone_id = "aps1-az1"

  tags = {
    Name = "Data Subnet A"
  }
}

resource "aws_subnet" "data-b" {
  vpc_id               = aws_vpc.ha-web-app.id
  cidr_block           = "10.16.0.160/27"
  availability_zone_id = "aps1-az2"

  tags = {
    Name = "Data Subnet B"
  }
}

resource "aws_internet_gateway" "ha-web-app-ig" {
  vpc_id = aws_vpc.ha-web-app.id

  tags = {
    Name = "HA Web App Internet Gateway"
  }
}

resource "aws_route_table" "ha-web-app-rt" {
  vpc_id = aws_vpc.ha-web-app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ha-web-app-ig.id
  }

  tags = {
    Name = "HA Web App"
  }
}

resource "aws_route_table_association" "ha-web-public-a" {
  route_table_id = aws_route_table.ha-web-app-rt.id
  subnet_id      = aws_subnet.public-a.id
}

resource "aws_route_table_association" "ha-web-public-b" {
  route_table_id = aws_route_table.ha-web-app-rt.id
  subnet_id      = aws_subnet.public-b.id
}

resource "aws_eip" "pub-a-eip" {}

resource "aws_nat_gateway" "pub-a-ng" {
  subnet_id         = aws_subnet.public-a.id
  connectivity_type = "public"
  allocation_id     = aws_eip.pub-a-eip.id

  depends_on = [aws_internet_gateway.ha-web-app-ig]

  tags = {
    Name = "Public Subnet A Nat Gateway"
  }
}

resource "aws_route_table" "app-a-rt" {
  vpc_id = aws_vpc.ha-web-app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pub-a-ng.id
  }

  tags = {
    Name = "Application Subnet A RT"
  }
}

resource "aws_route_table_association" "app-a" {
  route_table_id = aws_route_table.app-a-rt.id
  subnet_id      = aws_subnet.app-a.id
}

resource "aws_eip" "pub-b-eip" {}

resource "aws_nat_gateway" "pub-b-ng" {
  subnet_id         = aws_subnet.public-b.id
  connectivity_type = "public"
  allocation_id     = aws_eip.pub-b-eip.id

  depends_on = [aws_internet_gateway.ha-web-app-ig]

  tags = {
    Name = "Public Subnet B Nat Gateway"
  }
}

resource "aws_route_table" "app-b-rt" {
  vpc_id = aws_vpc.ha-web-app.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pub-b-ng.id
  }

  tags = {
    Name = "Application Subnet B RT"
  }
}

resource "aws_route_table_association" "app-b" {
  route_table_id = aws_route_table.app-b-rt.id
  subnet_id      = aws_subnet.app-b.id
}