resource "aws_emr_security_configuration" "ebs_emrfs_em" {
  name          = "aws_uc_feature_infrastructure_ebs_emrfs"
  configuration = jsonencode(local.ebs_emrfs_em)
}

#TODO remove this
output "security_configuration" {
  value = aws_emr_security_configuration.ebs_emrfs_em
}

resource "aws_s3_bucket_object" "cluster" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_uc_feature_infrastructure/cluster.yaml"
  content = templatefile("${path.module}/cluster_config/cluster.yaml.tpl",
    {
      s3_log_bucket          = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix          = local.s3_log_prefix
      ami_id                 = var.emr_ami_id
      service_role           = aws_iam_role.aws_uc_feature_infrastructure_emr_service.arn
      instance_profile       = aws_iam_instance_profile.aws_uc_feature_infrastructure.arn
      security_configuration = aws_emr_security_configuration.ebs_emrfs_em.id
      emr_release            = var.emr_release[local.environment]
      environment_tag_value  = local.common_repo_tags.Environment
    }
  )
  tags = {
    Name = "cluster"
  }
}

resource "aws_s3_bucket_object" "instances" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_uc_feature_infrastructure/instances.yaml"
  content = templatefile("${path.module}/cluster_config/instances.yaml.tpl",
    {
      keep_cluster_alive = local.keep_cluster_alive[local.environment]
      add_master_sg      = aws_security_group.aws_uc_feature_infrastructure_common.id
      add_slave_sg       = aws_security_group.aws_uc_feature_infrastructure_common.id
      subnet_id = (
        local.use_capacity_reservation[local.environment] == true ?
        data.terraform_remote_state.internal_compute.outputs.aws_uc_feature_infrastructure_subnet.subnets[index(data.terraform_remote_state.internal_compute.outputs.aws_uc_feature_infrastructure_subnet.subnets.*.availability_zone, data.terraform_remote_state.common.outputs.ec2_capacity_reservations.emr_m5_16_x_large_2a.availability_zone)].id :
        data.terraform_remote_state.internal_compute.outputs.aws_uc_feature_infrastructure_subnet.subnets[index(data.terraform_remote_state.internal_compute.outputs.aws_uc_feature_infrastructure_subnet.subnets.*.availability_zone, local.emr_subnet_non_capacity_reserved_environments)].id
      )
      master_sg                           = aws_security_group.aws_uc_feature_infrastructure_master.id
      slave_sg                            = aws_security_group.aws_uc_feature_infrastructure_slave.id
      service_access_sg                   = aws_security_group.aws_uc_feature_infrastructure_emr_service.id
      instance_type_core_one              = var.emr_instance_type_core_one[local.environment]
      instance_type_master                = var.emr_instance_type_master[local.environment]
      core_instance_count                 = var.emr_core_instance_count[local.environment]
      capacity_reservation_preference     = local.emr_capacity_reservation_preference
      capacity_reservation_usage_strategy = local.emr_capacity_reservation_usage_strategy
    }
  )
  tags = {
    Name = "instances"
  }
}

resource "aws_s3_bucket_object" "steps" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_uc_feature_infrastructure/steps.yaml"
  content = templatefile("${path.module}/cluster_config/steps.yaml.tpl",
    {
      s3_config_bucket    = data.terraform_remote_state.common.outputs.config_bucket.id
      action_on_failure   = local.step_fail_action[local.environment]
      s3_published_bucket = data.terraform_remote_state.common.outputs.published_bucket.id
    }
  )
  tags = {
    Name = "steps"
  }
}


resource "aws_s3_bucket_object" "configurations" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_uc_feature_infrastructure/configurations.yaml"
  content = templatefile("${path.module}/cluster_config/configurations.yaml.tpl",
    {
      s3_log_bucket                                 = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix                                 = local.s3_log_prefix
      proxy_no_proxy                                = replace(replace(local.no_proxy, ",", "|"), ".s3", "*.s3")
      proxy_http_host                               = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_http_port                               = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      proxy_https_host                              = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_https_port                              = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      environment                                   = local.environment
      hive_tez_container_size                       = var.hive_tez_container_size
      hive_tez_java_opts                            = var.hive_tez_java_opts
      hive_auto_convert_join_noconditionaltask_size = var.hive_auto_convert_join_noconditionaltask_size
      tez_grouping_min_size                         = var.tez_grouping_min_size
      tez_grouping_max_size                         = var.tez_grouping_max_size
      tez_am_resource_memory_mb                     = var.tez_am_resource_memory_mb
      tez_am_launch_cmd_opts                        = var.tez_am_launch_cmd_opts
      tez_runtime_io_sort_mb                        = var.tez_runtime_io_sort_mb
    }
  )
  tags = {
    Name = "configurations"
  }
}

