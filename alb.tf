locals {
  b64_haproxy_config = base64encode(templatefile("${path.module}/configs/alb/haproxy.cfg.tftpl", {
    servers = { for app_instance in yandex_compute_instance.app_instance[*] : app_instance.name => app_instance.network_interface[0].ip_address }
  }))

  alb_cloud_config = templatefile("${path.module}/configs/alb/cloud_config.yaml.tftpl", {
    b64_haproxy_config = local.b64_haproxy_config
  })

  alb_docker_compose_config = file("${path.module}/configs/alb/docker-compose.yaml")
}

resource "yandex_compute_instance" "alb_instance" {
  name        = "alb-instance"
  platform_id = "standard-v2"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      type     = "network-hdd"
      size     = "30"
      image_id = data.yandex_compute_image.container_optimized_image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.bingo.id
    nat       = true
  }

  metadata = {
    docker-compose = local.alb_docker_compose_config
    user-data      = local.alb_cloud_config
    ssh-keys       = "ubuntu:${file(var.ssh_key)}"
  }

  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }
}
