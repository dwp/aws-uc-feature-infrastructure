resource "aws_s3_bucket_object" "create_uc_feature_dbs_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature/create_uc_feature_dbs.sh"
  content = templatefile("${path.module}/steps/create_uc_feature_dbs.sh",
    {
      uc_feature_db           = local.uc_feature_db
      hive_metastore_location = local.hive_metastore_location
      published_bucket        = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
    }
  )
}

resource "aws_s3_bucket_object" "build_uc_feature" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature/build_uc_feature.sh"
  content = templatefile("${path.module}/steps/build_uc_feature.sh",
    {
      uc_feature_scripts_location = local.aws_uc_feature_scripts_location
      published_bucket            = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
      target_db                   = local.uc_feature_db
      serde                       = local.serde
      processes                   = local.aws_uc_feature_processes[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "flush_pushgateway" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature/flush-pushgateway.sh"
  content = templatefile("${path.module}/steps/flush-pushgateway.sh",
    {
      uc_feature_pushgateway_hostname = local.aws_uc_feature_pushgateway_hostname
    }
  )
}

resource "aws_s3_bucket_object" "courtesy_flush" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature/courtesy-flush.sh"
  content = templatefile("${path.module}/steps/courtesy-flush.sh",
    {
      uc_feature_pushgateway_hostname = local.aws_uc_feature_pushgateway_hostname
    }
  )
}
