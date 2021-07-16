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

resource "aws_s3_bucket_object" "mandatory_reconsideration" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature/mandatory_reconsideration.sh"
  content = templatefile("${path.module}/steps/mandatory_reconsideration.sh",
    {
      target_db              = local.uc_feature_db
      serde                  = local.serde
      lazy_serde                  = local.lazy_serde
      data_path              = local.data_path
      published_bucket       = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
      uc_feature_scripts_location = local.uc_feature_scripts_location
    }
  )
}
