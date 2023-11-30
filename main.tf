terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

variable "cloud_id" {
  type        = string
  description = "Yandex Cloud cloud id"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud folder id"
}

variable "zone" {
  type        = string
  description = "Yandex Cloud availability zone"
}

variable "token" {
  type        = string
  description = "Yandex Cloud IAM token"
}

variable "dns_name" {
  type        = string
  description = "service DNS name (for ssl certificate generation)"
}

variable "sa_prefix" {
  type        = string
  default     = ""
  description = "prefix for created service accounts"
}

variable "db_user" {
  type        = string
  default     = "bingo"
  description = "Postgresql DB user"
}

variable "db_name" {
  type        = string
  default     = "bingo"
  description = "Postgresql DB name"
}

variable "ssh_key" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "SSH public key path"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token     = var.token
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
