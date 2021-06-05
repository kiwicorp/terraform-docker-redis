# terraform-docker-redis - variables.tf

variable "image_version" {
  type        = string
  description = <<-DESCRIPTION
  Container image version. This module uses the official 'redis' Docker image.
  DESCRIPTION
  default     = "latest"
}

variable "start" {
  type        = bool
  description = "Whether to start the container or just create it."
  default     = true
}

variable "restart" {
  type        = string
  description = <<-DESCRIPTION
  The restart policy of the container. Must be one of: "no", "on-failure", "always",
  "unless-stopped".
  DESCRIPTION
  default     = "unless-stopped"
}

variable "create_data_volume" {
  type        = bool
  description = "Create a volume for the '/data' directory."
  default     = true
}

variable "data_volume_name" {
  type        = string
  description = <<-DESCRIPTION
  The name of the data volume. If empty, a name will be automatically generated like this:
  'redis_data_{random-uuid}'.
  DESCRIPTION
  default     = ""
}

variable "data_volume_driver" {
  type        = string
  description = "Storage driver for the data volume."
  default     = "local"
}

variable "data_volume_driver_opts" {
  type        = map(any)
  description = "Storage driver options for the data volume."
  default     = {}
}

variable "container_name" {
  type        = string
  description = <<-DESCRIPTION
  The name of the redis container. If empty, one will be generated like this:
  'redis_{random-uuid}'.
  DESCRIPTION
  default     = ""
}

variable "labels" {
  type        = map(string)
  description = "Labels to attach to created resources that support labels."
  default     = {}
}

variable "upload_config" {
  type        = bool
  description = "Upload a configuration file."
  default     = false
}

variable "config_content" {
  type        = string
  description = "Contents of the configuration file that should be uploaded."
  default     = ""
}

variable "config_file" {
  type        = string
  description = <<-DESCRIPTION
  Path to the file in the container where the configuration will be uploaded.
  DESCRIPTION
  default     = "/etc/redis.conf"
}

variable "upload_db_dump" {
  type        = bool
  description = "Upload a database dump file."
  default     = false
}

variable "db_dump_content_base64" {
  type        = string
  description = <<-DESCRIPTION
  Contents of the database dump file that should be uploaded. Must be passed as
  a base64-encoded string.
  DESCRIPTION
  default     = ""
}

variable "db_dump_file" {
  type        = string
  description = <<-DESCRIPTION
  Path to the file in the container where the database dump will be uploaded.
  DESCRIPTION
  default     = "/data/dump.rdb"
}
