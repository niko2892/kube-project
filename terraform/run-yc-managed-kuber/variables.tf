variable "cloud_catalog_title" {
  type = string
  description = "Название каталога"
}

variable "token" {
  type = string
  description = "токен"
}

variable "cloud_id" {
  type = string
  description = "id облака"
}

variable "folder_id" {
  type = string
  description = "id каталога"
}

variable "zone" {
  type = string
  description = "зона доступности"
}

variable "folder_name" {
  type = string
  description = "название фолдера"
  default = "default"
}