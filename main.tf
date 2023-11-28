terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "sa_prefix" {
  type    = string
  default = ""
}

variable "db_user" {
  type    = string
  default = "bingo"
}

variable "db_name" {
  type    = string
  default = "bingo"
}

variable "ssh_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

data "yandex_compute_image" "container_optimized_image" {
  family = "container-optimized-image"
}

resource "yandex_vpc_network" "bingo" {
  name = "bingo"
}

resource "yandex_vpc_subnet" "bingo" {
  network_id     = yandex_vpc_network.bingo.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}
