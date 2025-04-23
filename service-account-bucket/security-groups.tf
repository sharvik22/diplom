resource "yandex_vpc_security_group" "k8s_main_sg" {
  name        = "k8s-main-sg"
  description = "Main K8S Security Group"
  network_id  = yandex_vpc_network.vpc_network.id

  # Internal cluster communication
  ingress {
    protocol       = "ANY"
    description    = "Full internal cluster communication"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  # Kubernetes components
  ingress {
    protocol       = "TCP"
    description    = "Kubernetes API server"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24", "0.0.0.0/0"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "etcd client API"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    port           = 2379
  }

  ingress {
    protocol       = "TCP"
    description    = "etcd peer API"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    port           = 2380
  }

  ingress {
    protocol       = "TCP"
    description    = "Kubelet API"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    port           = 10250
  }

  # External access
  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  #1
  ingress {
    protocol       = "TCP"
    description    = "NodePort range"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  # Monitoring
  ingress {
    protocol       = "TCP"
    description    = "Grafana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30090
  }

  ingress {
    protocol       = "TCP"
    description    = "Prometheus"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30091
  }

  ingress {
    protocol       = "TCP"
    description    = "Alertmanager"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30092
  }

  # Egress rules
  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

output "k8s_security_group_id" {
  value       = yandex_vpc_security_group.k8s_main_sg.id
  description = "ID основной Security Group для Kubernetes"
  sensitive   = true
}
