resource "random_password" "db_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  b64_bingo_init_config = base64encode(templatefile("${path.module}/configs/bingo/config.yaml.tftpl", {
    DB_ADDRESS  = "postgres"
    DB_USER     = var.db_user
    DB_PASSWORD = random_password.db_password.result
    DB_NAME     = var.db_name
  }))

  db_cloud_config = templatefile("${path.module}/configs/db/cloud_config.yaml.tftpl", {
    b64_bingo_config = local.b64_bingo_init_config
  })

  db_docker_compose_config = templatefile("${path.module}/configs/db/docker-compose.yaml.tftpl", {
    DB_USER        = var.db_user
    DB_PASSWORD    = random_password.db_password.result
    DB_NAME        = var.db_name
    YC_CR_REGISTRY = yandex_container_registry.docker_registry.id
  })
}

resource "yandex_iam_service_account" "db_instance" {
  name = "${var.sa_prefix}bingo-db-instance"
}

resource "yandex_resourcemanager_folder_iam_member" "db_instance_roles" {
  for_each = toset([
    "container-registry.images.puller",
  ])
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.db_instance.id}"
}

resource "yandex_compute_instance" "db_instance" {
  name                      = "db-instance"
  platform_id               = "standard-v2"
  service_account_id        = yandex_iam_service_account.db_instance.id
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
    docker-compose = local.db_docker_compose_config
    user-data      = local.db_cloud_config
    ssh-keys       = "ubuntu:${file(var.ssh_key)}"
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.db_instance_roles,
  ]

  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }
}
