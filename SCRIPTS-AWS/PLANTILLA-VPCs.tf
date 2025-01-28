# ============================
# Variable para nombrar los recursos
# ============================
variable "nombre_alumno" {
  description = "Nombre para nombrar los recursos"
  type        = string
  default     = "nombreAlumno"  # Puedes cambiar este valor por defecto o pasarlo al aplicar el plan
}

# ============================
# CLAVE SSH
# ============================

# Generacion de la clave SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"      # Algoritmo para la clave
  rsa_bits  = 2048       # Tamaño de la clave en bits
}

# Creacion de la clave SSH en AWS
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh-mensagl-2025-${var.nombre_alumno}" # Nombre de la clave en AWS
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Guardar la clave privada localmente (No es necesario pero se hace)
resource "local_file" "private_key_file" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/ssh-mensagl-2025-${var.nombre_alumno}.pem" # Nombre del archivo generado
}

# Salidas para referencia
output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true # Mantener la clave privada oculta en los logs
}

output "key_name" {
  value = aws_key_pair.ssh_key.key_name
}

provider "aws" {
  region = "us-east-1"
}

# ============================
# VPC
# ============================

# Crear VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-vpc"
  }
}

# Crear Subnets públicas
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-subnet-public1-us-east-1a"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-subnet-public2-us-east-1b"
  }
}

# Crear Subnets privadas
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-subnet-private1-us-east-1a"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-subnet-private2-us-east-1b"
  }
}

# Crear Gateway de Internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-igw"
  }
}

# Crear tabla de rutas publicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-rtb-public"
  }
}

# Asociar subnets públicas a la tabla de rutas pública
resource "aws_route_table_association" "assoc_public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "assoc_public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# Crear Elastic IP para NAT Gateway
resource "aws_eip" "nat" {
  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-eip"
  }
}

# Crear NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-nat"
  }
}

# Crear tablas de rutas privadas
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-rtb-private1-us-east-1a"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "vpc-mensagl-2025-${var.nombre_alumno}-rtb-private2-us-east-1b"
  }
}

# Asociar subnets privadas a las tablas de rutas privadas
resource "aws_route_table_association" "assoc_private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "assoc_private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}