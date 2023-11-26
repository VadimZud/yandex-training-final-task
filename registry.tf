resource "yandex_container_registry" "docker_registry" {
  name = "docker-registry"

  provisioner "local-exec" {
    environment = {
      YC_CR_REGISTRY = self.id
      APP_PATH       = "${path.module}/app"
    }

    command     = "scripts/build_push_docker_images.sh"
    interpreter = ["/bin/sh"]
  }
}
