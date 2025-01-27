# PLANTILLA PRINCIPAL CREACION DE VPC - EQUIPO5
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-mensagl-2025-equipo5-vpc" # Cambiar nombre al de estudiante, por siguiendo el siguiente formato: vpc-mensagl-2025-nombreAlumno
  }
}

resource "aws_subnet" "public1" { 
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "vpc-mensagl-2025-equipo5-subnet-public1-us-east-1a"  # Cambiar nombre al de estudiante
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "vpc-mensagl-2025-equipo5-subnet-public2-us-east-1b"  # Cambiar nombre al de estudiante
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "vpc-mensagl-2025-equipo5-subnet-private1-us-east-1a"  # Cambiar nombre al de estudiante
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "vpc-mensagl-2025-equipo5-subnet-private2-us-east-1b"  # Cambiar nombre al de estudiante
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-mensagl-2025-equipo5-igw"  # Cambiar nombre al de estudiante
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-mensagl-2025-equipo5-rtb-public"  # Cambiar nombre al de estudiante
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "vpc-mensagl-2025-equipo5-eip-us-east-1a"  # Cambiar nombre al de estudiante
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "vpc-mensagl-2025-equipo5-nat-public1-us-east-1a"  # Cambiar nombre al de estudiante
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-mensagl-2025-equipo5-rtb-private1-us-east-1a"  # Cambiar nombre al de estudiante
  }
}

resource "aws_route" "private_route1" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private1_association" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-mensagl-2025-equipo5-rtb-private2-us-east-1b"  # Cambiar nombre al de estudiante
  }
}

resource "aws_route" "private_route2" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private2_association" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}
