resource "aws_s3_bucket_object" "metadata_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/aws_uc_feature_infrastructure/metadata.sh"
  content    = file("${path.module}/bootstrap_actions/metadata.sh")
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  tags = {
    Name = "metadata_script"
  }
}

resource "aws_s3_bucket_object" "download_scripts_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws_uc_feature_infrastructure/download_scripts.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_scripts.sh",
    {
      VERSION                               = local.aws_uc_feature_infrastructure_version[local.environment]
      aws_uc_feature_infrastructure_LOG_LEVEL = local.aws_uc_feature_infrastructure_log_level[local.environment]
      ENVIRONMENT_NAME                      = local.environment
      S3_COMMON_LOGGING_SHELL               = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, data.terraform_remote_state.common.outputs.application_logging_common_file.s3_id)
      S3_LOGGING_SHELL                      = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.logging_script.key)
      scripts_location                      = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, "component/aws_uc_feature_infrastructure")
  })
  tags = {
    Name = "download_scripts_sh"
  }
}

resource "aws_s3_bucket_object" "emr_setup_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws_uc_feature_infrastructure/emr-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/emr-setup.sh",
    {
      aws_uc_feature_infrastructure_LOG_LEVEL = local.aws_uc_feature_infrastructure_log_level[local.environment]
      aws_default_region                    = "eu-west-2"
      full_proxy                            = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      full_no_proxy                         = local.no_proxy
      acm_cert_arn                          = aws_acm_certificate.aws_uc_feature_infrastructure.arn
      private_key_alias                     = "private_key"
      truststore_aliases                    = join(",", var.truststore_aliases)
      truststore_certs                      = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
      dks_endpoint                          = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
      cwa_metrics_collection_interval       = local.cw_agent_metrics_collection_interval
      cwa_namespace                         = local.cw_agent_namespace
      cwa_log_group_name                    = aws_cloudwatch_log_group.aws_uc_feature_infrastructure.name
      S3_CLOUDWATCH_SHELL                   = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.cloudwatch_sh.key)
      cwa_bootstrap_loggrp_name             = aws_cloudwatch_log_group.aws_uc_feature_infrastructure_cw_bootstrap_loggroup.name
      cwa_steps_loggrp_name                 = aws_cloudwatch_log_group.aws_uc_feature_infrastructure_cw_steps_loggroup.name
      name                                  = local.emr_cluster_name
  })
  tags = {
    Name = "emr_setup_sh"
  }
}

resource "aws_s3_bucket_object" "ssm_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/aws_uc_feature_infrastructure/start_ssm.sh"
  content = file("${path.module}/bootstrap_actions/start_ssm.sh")
  tags = {
    Name = "ssm_script"
  }
}

resource "aws_s3_bucket_object" "status_metrics_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws_uc_feature_infrastructure/status_metrics.sh"
  content = templatefile("${path.module}/bootstrap_actions/status_metrics.sh",
    {
      aws_uc_feature_infrastructure_pushgateway_hostname = local.aws_uc_feature_infrastructure_pushgateway_hostname
      dynamodb_final_step                              = local.dynamodb_final_step[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "logging_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/aws_uc_feature_infrastructure/logging.sh"
  content = file("${path.module}/bootstrap_actions/logging.sh")
  tags = {
    Name = "logging_script"
  }
}

resource "aws_cloudwatch_log_group" "aws_uc_feature_infrastructure" {
  name              = local.cw_agent_log_group_name
  retention_in_days = 180
  tags = {
    Name = "aws_uc_feature_infrastructure"
  }
}

resource "aws_cloudwatch_log_group" "aws_uc_feature_infrastructure_cw_bootstrap_loggroup" {
  name              = local.cw_agent_bootstrap_loggrp_name
  retention_in_days = 180
  tags = {
    Name = "aws_uc_feature_infrastructure_cw_bootstrap_loggroup"
  }
}

resource "aws_cloudwatch_log_group" "aws_uc_feature_infrastructure_cw_steps_loggroup" {
  name              = local.cw_agent_steps_loggrp_name
  retention_in_days = 180
  tags = {
    Name = "aws_uc_feature_infrastructure_cw_steps_loggroup"
  }
}

resource "aws_s3_bucket_object" "cloudwatch_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws_uc_feature_infrastructure/cloudwatch.sh"
  content = templatefile("${path.module}/bootstrap_actions/cloudwatch.sh",
    {
      emr_release = var.emr_release[local.environment]
    }
  )
  tags = {
    Name = "cloudwatch_sh"
  }
}

resource "aws_s3_bucket_object" "metrics_setup_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature_infrastructure/metrics-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/metrics-setup.sh",
    {
      proxy_url         = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      metrics_pom       = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.metrics_pom.key)
      prometheus_config = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.prometheus_config.key)
    }
  )
  tags = {
    Name = "metrics_setup_sh"
  }
}

resource "aws_s3_bucket_object" "metrics_pom" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature_infrastructure/metrics/pom.xml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/pom.xml")
  tags = {
    Name = "metrics_pom"
  }
}

resource "aws_s3_bucket_object" "prometheus_config" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature_infrastructure/metrics/prometheus_config.yml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/prometheus_config.yml")
  tags = {
    Name = "prometheus_config"
  }
}

resource "aws_s3_bucket_object" "dynamo_json_file" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature_infrastructure/dynamo_schema.json"
  content    = file("${path.module}/bootstrap_actions/dynamo_schema.json")
  tags = {
    Name = "dynamo_schema"
  }
}

resource "aws_s3_bucket_object" "update_dynamo_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws_uc_feature_infrastructure/update_dynamo.sh"
  content = templatefile("${path.module}/bootstrap_actions/update_dynamo.sh",
    {
      dynamodb_table_name = local.data_pipeline_metadata
      dynamodb_final_step = local.dynamodb_final_step[local.environment]
    }
  )
  tags = {
    Name = "update_dynamo"
  }
}
