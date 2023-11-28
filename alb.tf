resource "tls_private_key" "bingo" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "bingo" {
  private_key_pem = tls_private_key.bingo.private_key_pem

  validity_period_hours = 8760

  early_renewal_hours = 720

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [var.dns_name]
}

locals {
  b64_haproxy_config = base64encode(templatefile("${path.module}/configs/alb/haproxy.cfg.tftpl", {
    servers = { for app_instance in yandex_compute_instance.app_instance[*] : app_instance.name => app_instance.network_interface[0].ip_address }
  }))

  b64_alb_unified_agent_config = base64encode(templatefile("${path.module}/configs/alb/unified_agent.yml.tftpl", {
    YC_FOLDER_ID = var.folder_id
  }))

  b64_cert_pem = base64encode("${tls_private_key.bingo.private_key_pem}${tls_self_signed_cert.bingo.cert_pem}")

  alb_cloud_config = templatefile("${path.module}/configs/alb/cloud_config.yaml.tftpl", {
    b64_haproxy_config       = local.b64_haproxy_config
    b64_unified_agent_config = local.b64_alb_unified_agent_config
    b64_cert_pem             = local.b64_cert_pem
  })

  alb_docker_compose_config = templatefile("${path.module}/configs/alb/docker-compose.yaml.tftpl", {
    YC_FOLDER_ID = var.folder_id
  })
}

resource "yandex_iam_service_account" "alb_instance" {
  name = "${var.sa_prefix}bingo-alb-instance"
}

resource "yandex_resourcemanager_folder_iam_member" "alb_instance_roles" {
  for_each = toset([
    "monitoring.editor",
  ])
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.alb_instance.id}"
}

resource "yandex_compute_instance" "alb_instance" {
  name                      = "alb-instance"
  platform_id               = "standard-v2"
  service_account_id        = yandex_iam_service_account.alb_instance.id
  allow_stopping_for_update = true


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

  depends_on = [
    yandex_resourcemanager_folder_iam_member.alb_instance_roles,
  ]

  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }
}
