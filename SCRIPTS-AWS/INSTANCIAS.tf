# ============================
# Instancias EC2
# ============================

# Proxy Inverso en Zona 1
resource "aws_instance" "proxy_zona1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public1.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_proxy.id]

  tags = {
    Name = "proxy-zona1"
  }
}

# Proxy Inverso en Zona 2
resource "aws_instance" "proxy_zona2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public2.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_proxy.id]

  tags = {
    Name = "proxy-zona2"
  }
}

# Servidor de Mensajería en Zona 1
resource "aws_instance" "mensajeria_zona1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]

  tags = {
    Name = "mensajeria-zona1"
  }
}

# Servidor SGBD en Zona 1
resource "aws_instance" "sgbd_zona1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]

  tags = {
    Name = "sgbd-zona1"
  }
}

# Clúster de CMS en Zona 2
resource "aws_instance" "cms_zona2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private2.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_cms.id]

  tags = {
    Name = "cms-zona2"
  }
}

# Servidor SGBD en Zona 2
resource "aws_instance" "sgbd_zona2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private2.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]

  tags = {
    Name = "sgbd-zona2"
  }
}