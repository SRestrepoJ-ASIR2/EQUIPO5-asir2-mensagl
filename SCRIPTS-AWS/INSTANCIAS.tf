# ============================
# Instancias EC2
# ============================

# Proxy Inverso en Zona 1
resource "aws_instance" "proxy_zona1" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.sg_proxy.name]

  # User Data para ejecutar un script al iniciar la instancia
  user_data = <<-EOF
              #!/bin/bash
              # Este es un script de ejemplo para el proxy inverso.
              # Puedes añadir aquí los comandos que necesites.
              # echo "Configurando el proxy inverso..."
              # apt-get update
              # apt-get install -y nginx
              EOF

  tags = {
    Name = "proxy-zona1"
  }
}

# Proxy Inverso en Zona 2
resource "aws_instance" "proxy_zona2" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.sg_proxy.name]

  # User Data para ejecutar un script al iniciar la instancia
  user_data = <<-EOF
              #!/bin/bash
              # Este es un script de ejemplo para el proxy inverso.
              # echo "Configurando el proxy inverso en Zona 2..."
              # apt-get update
              # apt-get install -y nginx
              EOF

  tags = {
    Name = "proxy-zona2"
  }
}

# Servidor de Mensajería en Zona 1
resource "aws_instance" "mensajeria_zona1" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.sg_mysql.name]

  # User Data para ejecutar un script al iniciar la instancia
  user_data = <<-EOF
              #!/bin/bash
              # Este es un script de ejemplo para el servidor de mensajería.
              # echo "Configurando el servidor de mensajería..."
              # apt-get update
              # apt-get install -y software-properties-common
              EOF

  tags = {
    Name = "mensajeria-zona1"
  }
}

# Servidor SGBD en Zona 1
resource "aws_instance" "sgbd_zona1" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.sg_mysql.name]

  # User Data para ejecutar un script al iniciar la instancia
  user_data = <<-EOF
              #!/bin/bash
              # Este es un script de ejemplo para el servidor SGBD.
              # echo "Configurando el servidor SGBD..."
              # apt-get update
              # apt-get install -y mysql-server
              EOF

  tags = {
    Name = "sgbd-zona1"
  }
}

# Clúster de CMS en Zona 2
resource "aws_instance" "cms_zona2" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private2.id
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.sg_cms.name]

  # User Data para ejecutar un script al iniciar la instancia
  user_data = <<-EOF
              #!/bin/bash
              # Este es un script de ejemplo para el clúster de CMS.
              # echo "Configurando el clúster de CMS..."
              # apt-get update
              # apt-get install -y apache2
              EOF

  tags = {
    Name = "cms-zona2"
  }
}

# Servidor SGBD en Zona 2
resource "aws_instance" "sgbd_zona2" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private2.id
  key_name      = aws_key_pair.ssh_key.key_name
  security_groups = [aws_security_group.sg_mysql.name]

  # User Data para ejecutar un script al iniciar la instancia
  user_data = <<-EOF
              #!/bin/bash
              # Este es un script de ejemplo para el servidor SGBD.
              # echo "Configurando el servidor SGBD en Zona 2..."
              # apt-get update
              # apt-get install -y mysql-server
              EOF

  tags = {
    Name = "sgbd-zona2"
  }
}