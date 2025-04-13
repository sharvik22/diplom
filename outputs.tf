output "master_public_ip" {
  description = "Публичный IP-адрес master-ноды"
  value       = yandex_compute_instance.k8s_master.network_interface.0.nat_ip_address
}

output "master_private_ip" {
  description = "Внутренний IP-адрес master-ноды"
  value       = yandex_compute_instance.k8s_master.network_interface.0.ip_address
}

output "worker_public_ips" {
  description = "Публичные IP-адреса worker-нод"
  value = {
    for idx, instance in yandex_compute_instance.k8s_worker :
    "worker_${idx + 1}_public_ip" => instance.network_interface.0.nat_ip_address
  }
}

output "worker_private_ips" {
  description = "Внутренние IP-адреса worker-нод"
  value = {
    for idx, instance in yandex_compute_instance.k8s_worker :
    "worker_${idx + 1}_private_ip" => instance.network_interface.0.ip_address
  }
}

output "load_balancer_id" {
  description = "Идентификатор балансировщика нагрузки"
  value       = yandex_lb_network_load_balancer.k8s_lb.id
}

output "load_balancer_external_ip" {
  description = "Внешний IP-адрес балансировщика нагрузки"
  value       = yandex_lb_network_load_balancer.k8s_lb.listener[*].external_address_spec[*].address
}

output "target_group_id" {
  description = "Идентификатор целевой группы"
  value       = yandex_lb_target_group.k8s_nodes.id
}
