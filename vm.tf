resource "yandex_compute_instance" "k8s_master" {
  name        = "k8s-master"
  platform_id = "standard-v2"
  zone        = var.subnets["subnet-a"].zone

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = var.subnets["subnet-a"].id
    nat                = true
    security_group_ids = [var.k8s_security_group_id]
  }

  metadata = {
    ssh-keys  = "${var.vm_user}:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      timezone: Europe/Moscow
      users:
        - name: ${var.vm_user}
          groups: sudo
          shell: /bin/bash
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          ssh-authorized-keys:
            - ${var.ssh_public_key}
      EOF
  }

  service_account_id = var.service_account_id
}

resource "yandex_compute_instance" "k8s_worker" {
  count       = 2
  name        = "k8s-worker-${count.index + 1}"
  platform_id = "standard-v2"
  zone        = var.subnets[count.index == 0 ? "subnet-b" : "subnet-d"].zone

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 5
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = var.subnets[count.index == 0 ? "subnet-b" : "subnet-d"].id
    nat                = true
    security_group_ids = [var.k8s_security_group_id]
  }

  metadata = {
    ssh-keys  = "${var.vm_user}:${var.ssh_public_key}"
    user-data = <<-EOF
      #cloud-config
      timezone: Europe/Moscow
      users:
        - name: ${var.vm_user}
          groups: sudo
          shell: /bin/bash
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          ssh-authorized-keys:
            - ${var.ssh_public_key}
      EOF
  }

  service_account_id = var.service_account_id
}
