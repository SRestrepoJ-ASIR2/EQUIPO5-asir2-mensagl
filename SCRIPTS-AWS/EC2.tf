# =====================================
# Configuración de instancias EC2
# =====================================

# -------------------------------------
# Zona 1
# -------------------------------------

# Clúster de Servidor de Mensajería (Subred privada - Zona 1)
resource "aws_instance" "messaging_cluster_zone1" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona1-Privada-Cluster-Mensajeria"
  }

  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

# Servidor SGBD (Subred privada - Zona 1)
resource "aws_instance" "sgbd_server_zone1" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona1-Privada-Servidor-SGBD"
  }

  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

# Proxy inverso (Subred pública - Zona 1)
resource "aws_instance" "reverse_proxy_zone1" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona1-Publica-Proxy-Inverso"
  }

  vpc_security_group_ids = [aws_security_group.public_sg.id]
}

# Puerta de enlace (Subred pública - Zona 1)
resource "aws_instance" "gateway_zone1" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona1-Publica-Gateway"
  }

  vpc_security_group_ids = [aws_security_group.public_sg.id]
}

# -------------------------------------
# Zona 2
# -------------------------------------

# Clúster de CMS (Subred privada - Zona 2)
resource "aws_instance" "cms_cluster_zone2" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private2.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona2-Privada-Cluster-CMS"
  }

  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

# Servidor SGBD (Subred privada - Zona 2)
resource "aws_instance" "sgbd_server_zone2" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private2.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona2-Privada-Servidor-SGBD"
  }

  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

# Proxy inverso (Subred pública - Zona 2)
resource "aws_instance" "reverse_proxy_zone2" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona2-Publica-Proxy-Inverso"
  }

  vpc_security_group_ids = [aws_security_group.public_sg.id]
}

# Puerta de enlace (Subred pública - Zona 2)
resource "aws_instance" "gateway_zone2" {
  ami           = "ami-0ac4dfaf1c5c0cce9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "Zona2-Publica-Gateway"
  }

  vpc_security_group_ids = [aws_security_group.public_sg.id]
}

# =====================================
# Security Groups
# =====================================

# Security Group para instancias públicas
resource "aws_security_group" "public_sg" {
  name        = "vpc-mensagl-2025-public-sg"
  description = "Permitir tráfico público para instancias públicas"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8448
    to_port     = 8448
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Publico-Mensagl-2025"
  }
}

# Security Group para instancias privadas
resource "aws_security_group" "private_sg" {
  name        = "vpc-mensagl-2025-private-sg"
  description = "Permitir tráfico interno y saliente para instancias privadas"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Privado-Mensagl-2025"
  }
}
