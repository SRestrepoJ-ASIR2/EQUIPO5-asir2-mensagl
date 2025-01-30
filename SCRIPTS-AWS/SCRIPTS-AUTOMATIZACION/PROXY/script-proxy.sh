#!/bin/bash

# Actualizar el sistema e instalar HAProxy
sudo apt-get update
sudo apt-get install -y haproxy

# Configurar HAProxy para el servicio de mensajería (Zona 1)
sudo tee /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000ms
    timeout client  50000ms
    timeout server  50000ms
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    server mensajeria1 ${aws_instance.mensajeria_zona1.private_ip}:80 check
    server mensajeria2 ${aws_instance.mensajeria_zona2.private_ip}:80 check

frontend https_front
    bind *:443
    default_backend https_back

backend https_back
    balance roundrobin
    server mensajeria1 ${aws_instance.mensajeria_zona1.private_ip}:443 check
    server mensajeria2 ${aws_instance.mensajeria_zona2.private_ip}:443 check
EOF

# Reiniciar HAProxy para aplicar la configuración
sudo systemctl restart haproxy