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
  associate_public_ip_address = true
  private_ip             = "10.0.1.10"

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

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
  associate_public_ip_address = true
  private_ip             = "10.0.2.10"

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "proxy-zona2"
  }
}


# Servidores SGBD en Zona 1
# Principal
resource "aws_instance" "sgbd-principal_zona1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]
  private_ip             = "10.0.3.10"

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "sgbd-principal_zona1"
  }
}
# Secundario
resource "aws_instance" "sgbd-secundario_zona1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]
  private_ip             = "10.0.3.11"

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "sgbd-secundario_zona1"
  }
}

# ============================
#  Clusteres y RDS
# ============================

# Instancia Mensajería 1 en Zona 1
resource "aws_instance" "mensajeria_1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id  # Subred privada en Zona 1
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mensajeria.id]
  private_ip             = "10.0.3.20"  # IP privada fija

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "mensajeria-1"
  }
}

# Instancia Mensajería 2 en Zona 1
resource "aws_instance" "mensajeria_2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id  # Subred privada en Zona 1
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mensajeria.id]
  private_ip             = "10.0.3.30"  # IP privada fija


  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "mensajeria-2"
  }
}


# instancia RDS - para CMS
# Subnet Group para RDS (solo subred privada 4 - 10.0.4.0/24)
resource "aws_db_subnet_group" "cms_subnet_group" {
  name       = "cms-db-subnet-group"
  subnet_ids = [aws_subnet.private2.id]  # Subnet private2 = 10.0.4.0/24

  tags = {
    Name = "cms-db-subnet-group"
  }
}

# Instancia RDS - para CMS
resource "aws_db_instance" "cms_database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  instance_class       = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  username             = "admin"
  password             = "Admin123"
  db_name              = "cmsdb"
  publicly_accessible  = false
  multi_az             = false
  availability_zone    = "us-east-1b"  # Zona de la subred private2 (10.0.4.0/24)
  db_subnet_group_name = aws_db_subnet_group.cms_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]

  # IP persistente (AWS asignará dentro de la subred)
  skip_final_snapshot  = true  # Solo para entornos de prueba

  tags = {
    Name = "cms-db"
  }

  depends_on = [aws_db_subnet_group.cms_subnet_group]
}

# Cluster de CMS (2 instancias en Zona 2)
resource "aws_instance" "cms_cluster_1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private2.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_cms.id]
  private_ip             = "10.0.4.10"  # IP privada fija

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "cms-cluster-1"
  }
}

resource "aws_instance" "cms_cluster_2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private2.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_cms.id]
  private_ip             = "10.0.4.11"  # IP privada fija

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "cms-cluster-2"
  }
}
# Cluster de Jiti (2 instancias en Zona 1) - para videollamadas
resource "aws_instance" "jitsi_cluster1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id  
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_jitsi.id]
  private_ip             = "10.0.3.12"  # IP fija para la primer instancia

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "jitsi-cluster-1"
  }
}
resource "aws_instance" "jitsi_cluster2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id 
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_jitsi.id]
  private_ip             = "10.0.3.13"  #  IP fija para la segunda instancia

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "jitsi-cluster-2"
  }
}