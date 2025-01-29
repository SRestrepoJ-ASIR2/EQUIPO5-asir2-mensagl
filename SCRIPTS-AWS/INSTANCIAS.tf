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

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "proxy-zona2"
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

# Servidor SGBD en Zona 1
resource "aws_instance" "sgbd_zona1" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private1.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "sgbd-zona1"
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

# Servidor SGBD en Zona 2
resource "aws_instance" "sgbd_zona2" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private2.id
  key_name               = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]

  # User Data para cargar el script.sh (comentado de momento)
  # user_data = file("script.sh")

  tags = {
    Name = "sgbd-zona2"
  }
}