locals {
  common_vm_settings = {
    platform_id = "standard-v2"
    disk_size   = 20
    timezone    = "Europe/Moscow"
  }

  master_node = {
    name          = "k8s-master"
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  worker_nodes = {
    name_prefix   = "k8s-worker"
    count         = 2
    cores         = 2
    memory        = 4
    core_fraction = 5
    preemptible   = true
  }

  security_group = {
    name        = "k8s-security-group"
    description = "Security group for Kubernetes cluster"
  }

  load_balancer = {
    name        = "k8s-load-balancer"
    region_id   = "ru-central1"
    target_port = 80
    healthcheck = {
      path = "/healthz"
      port = 80
    }
  }
}
