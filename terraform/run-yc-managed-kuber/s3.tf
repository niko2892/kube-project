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