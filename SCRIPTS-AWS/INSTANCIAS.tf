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
# Auto Scaling Groups para Clusteres
# ============================

# Plantilla de lanzamiento para el Cluster de Mensajería en Zona 1
resource "aws_launch_template" "mensajeria_zona1" {
  name_prefix   = "mensajeria-zona1-"
  image_id      = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mensajeria.id]

  # User Data para clusteres (comentado)
  # user_data = file("script.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "mensajeria-zona1"
    }
  }
}

# Auto Scaling Group para el Cluster de Mensajería (2 instancias en Zona 1)
resource "aws_autoscaling_group" "cluster_mensajeria" {
  name             = "cluster-mensajeria-zona1"
  desired_capacity = 2
  min_size         = 2
  max_size         = 2
  vpc_zone_identifier = [aws_subnet.private1.id]

  launch_template {
    id      = aws_launch_template.mensajeria_zona1.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "mensajeria-cluster"
    propagate_at_launch = true
  }
}

# instancia RDS - para CMS
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
  availability_zone    = "us-east-1a"
  db_subnet_group_name = aws_db_subnet_group.cms_subnet_group.name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]

  tags = {
    Name = "cms-db"
  }

  depends_on = [aws_db_subnet_group.cms_subnet_group]
}

# Subnet Group para RDS
resource "aws_db_subnet_group" "cms_subnet_group" {
  name       = "cms-db-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "cms-db-subnet-group"
  }
}


# Plantilla de lanzamiento para el Cluster de CMS en Zona 2
resource "aws_launch_template" "cms_zona2" {
  name_prefix   = "cms-zona2-"
  image_id      = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_cms.id]

  # User Data para clusteres (comentado)
  # user_data = file("script.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "cms-zona2"
    }
  }
}

# Auto Scaling Group para el Cluster de CMS (2 instancias en Zona 2)
resource "aws_autoscaling_group" "cluster_cms" {
  name             = "cluster-cms-zona2"
  desired_capacity = 2
  min_size         = 2
  max_size         = 2
  vpc_zone_identifier = [aws_subnet.private2.id]

  launch_template {
    id      = aws_launch_template.cms_zona2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cms-cluster"
    propagate_at_launch = true
  }
}

# Launch Template para Jitsi en Zona 1
resource "aws_launch_template" "jitsi_zona1" {
  name_prefix   = "jitsi-zona1-"
  image_id      = "ami-04b4f1a9cf54c11d0"  
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_jitsi.id] 
  
  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "jitsi-zona1"
    }
  }
}

# Auto Scaling Group para el Cluster de Jitsi (2 instancias en Zona 1)
resource "aws_autoscaling_group" "cluster_jitsi" {
  name             = "cluster-jitsi-zona1"
  desired_capacity = 2
  min_size         = 2
  max_size         = 2
  vpc_zone_identifier = [aws_subnet.private1.id]

  launch_template {
    id      = aws_launch_template.jitsi_zona1.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "jitsi-cluster"
    propagate_at_launch = true
  }
}

