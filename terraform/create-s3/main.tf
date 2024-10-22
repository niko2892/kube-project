terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  # backend "s3" {
  #   endpoint          = "https://storage.yandexcloud.net"
  #   dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1g51q1dos9of1b1ig5s/etnntu1sheicvm8un255"
  #   bucket            = "tfstate-default-trainee"
  #   region            = "ru-central1"
  #   key               = "example-remote-state/terraform.tfstate"

  #   dynamodb_table    = "tfstates-locks"

  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   skip_requesting_account_id  = true
  #   skip_s3_checksum            = true
  # }
}

provider "yandex" {
  token ="${var.token}"
  zone = "${var.zone}"
}

resource "yandex_storage_bucket" "tfstate_bucket" {
  depends_on = [
    yandex_kms_symmetric_key.this,
    yandex_iam_service_account.terraform-deployer,
    yandex_resourcemanager_folder_iam_member.terraform-state-admin
  ]

  access_key = var.sa_access_key
  secret_key = var.sa_secret_key

  bucket = "tfstate-${var.folder_name}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "cleanupoldversions"
    enabled = true
    noncurrent_version_expiration {
      days = 60
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.this.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  policy = local.bucket_policy
}