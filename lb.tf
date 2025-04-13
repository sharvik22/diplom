resource "yandex_lb_target_group" "k8s_nodes" {
  name      = "k8s-nodes-target-group"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.k8s_worker
    content {
      subnet_id = var.subnets[target.value.zone == "ru-central1-b" ? "subnet-b" : "subnet-d"].id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "k8s_lb" {
  name = "k8s-load-balancer"
  type = "external"

  listener {
    name        = "nginx"
    port        = 80
    target_port = 30088
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name        = "grafana-web"
    port        = 3000
    target_port = 40000
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_nodes.id

    healthcheck {
      name                = "http-healthcheck"
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 3
      healthy_threshold   = 3
      http_options {
        port = 80
        path = "/healthz"
      }
    }
  }
}
