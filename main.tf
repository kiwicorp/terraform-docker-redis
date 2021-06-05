# terraform-docker-redis - main.tf

resource "random_uuid" "this" {}

data "docker_registry_image" "this" {
  name = "redis:${var.image_version}"
}

resource "docker_image" "this" {
  name          = data.docker_registry_image.this.name
  pull_triggers = [data.docker_registry_image.this.sha256_digest]
}

resource "docker_volume" "data" {
  count = var.create_data_volume ? 1 : 0

  name        = local.data_volume_name
  driver      = var.data_volume_driver
  driver_opts = var.data_volume_driver_opts

  dynamic "labels" {
    for_each = var.labels
    iterator = label
    content {
      label = label.key
      value = label.value
    }
  }
}

resource "docker_container" "this" {
  name  = local.container_name
  image = docker_image.this.latest

  ports {
    internal = var.internal_port
    external = var.external_port
    protocol = "tcp"
    ip       = var.ip
  }

  dynamic "upload" {
    for_each = local.config
    iterator = upload
    content {
      file    = upload.value.file
      content = upload.value.content
    }
  }

  dynamic "upload" {
    for_each = local.db_dump_base64
    iterator = upload
    content {
      file           = upload.value.file
      content_base64 = upload.value.content_base64
    }
  }

  dynamic "upload" {
    for_each = local.db_dump_source
    iterator = upload
    content {
      file        = upload.value.file
      source      = upload.value.source
      source_hash = upload.value.source_hash
    }
  }

  # data volume
  dynamic "volumes" {
    for_each = docker_volume.data
    iterator = volume
    content {
      volume_name    = volume.value.name
      container_path = "/data"
    }
  }

  dynamic "labels" {
    for_each = var.labels
    iterator = label
    content {
      label = label.key
      value = label.value
    }
  }

  must_run = true
  restart  = var.restart
  start    = var.start
}

locals {
  uuid = var.uuid != "" ? var.uuid : random_uuid.this.result

  data_volume_name = var.create_data_volume ? (
    var.data_volume_name != "" ? var.data_volume_name : (
      "redis_data_${local.uuid}"
    )
  ) : ""

  container_name = var.container_name != "" ? var.container_name : (
    "redis_${local.uuid}"
  )

  config = var.upload_config ? [{
    content = var.config_content
    file    = var.config_file
  }] : []

  db_dump_base64 = var.upload_db_dump && (var.db_dump_content_base64 != "") ? [{
    content_base64 = var.db_dump_content_base64
    file           = var.db_dump_file
  }] : []

  db_dump_source = var.upload_db_dump && (var.db_dump_source != "") ? [{
    source      = var.db_dump_source
    source_hash = var.db_dump_source_hash != "" ? (
      var.db_dump_source_hash
    ) : filesha256(var.db_dump_source)
    file        = var.db_dump_file
  }] : []
}
