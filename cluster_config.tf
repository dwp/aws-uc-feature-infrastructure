resource "aws_emr_security_configuration" "ebs_emrfs_em" {
  name          = "aws_uc_feature_ebs_emrfs"
  configuration = jsonencode(local.ebs_emrfs_em)
}

#TODO remove this
output "security_configuration" {
  value = aws_emr_security_configuration.ebs_emrfs_em
}

resource "aws_s3_bucket_object" "cluster" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_uc_feature/cluster.yaml"
  content = templatefile("${path.module}/cluster_config/cluster.yaml.tpl",
    {
      emr_cluster_name           = local.emr_cluster_name
      s3_log_bucket              = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix              = local.s3_log_prefix
      ami_id                     = var.emr_ami_id
      service_role               = aws_iam_role.aws_uc_feature_emr_service.arn
      instance_profile           = aws_iam_instance_profile.aws_uc_feature.arn
      security_configuration     = aws_emr_security_configuration.ebs_emrfs_em.id
      emr_release                = var.emr_release[local.environment]
      dwx_environment_tag_value  = local.common_repo_tags.Environment
      application_tag_value      = data.aws_default_tags.provider_tags.tags.Application
      function_tag_value         = data.aws_default_tags.provider_tags.tags.Function
      business_project_tag_value = data.aws_default_tags.provider_tags.tags.Business-Project
      environment_tag_value      = data.aws_default_tags.provider_tags.tags.Environment
    }
  )
  tags = {
    Name = "cluster"
  }
}

resource "aws_s3_bucket_object" "instances" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_uc_feature/instances.yaml"
  content = templatefile("${path.module}/cluster_config/instances.yaml.tpl",
    {
      keep_cluster_alive                  = local.keep_cluster_alive[local.environment]
      add_master_sg                       = aws_security_group.aws_uc_feature_common.id
      add_slave_sg                        = aws_security_group.aws_uc_feature_common.id
      subnet_ids                          = data.terraform_remote_state.internal_compute.outputs.uc_feature_subnet.subnets.*.id
      master_sg                           = aws_security_group.aws_uc_feature_master.id
      slave_sg                            = aws_security_group.aws_uc_feature_slave.id
      service_access_sg                   = aws_security_group.aws_uc_feature_emr_service.id
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
  key    = "emr/aws_uc_feature/steps.yaml"
  content = templatefile("${path.module}/cluster_config/steps.yaml.tpl",
    {
      s3_config_bucket    = data.terraform_remote_state.common.outputs.config_bucket.id
      action_on_failure   = local.step_fail_action[local.environment]
      s3_published_bucket = data.terraform_remote_state.common.outputs.published_bucket.id
      environment         = local.hcs_environment[local.environment]
      proxy_http_host     = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_http_port     = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      install_tenable     = local.tenable_install[local.environment]
      install_trend       = local.trend_install[local.environment]
      install_tanium      = local.tanium_install[local.environment]
      tanium_server_1     = data.terraform_remote_state.internal_compute.outputs.tanium_service_endpoint.dns
      tanium_server_2     = local.tanium2
      tanium_env          = local.tanium_env[local.environment]
      tanium_port         = var.tanium_port_1
      tanium_log_level    = local.tanium_log_level[local.environment]
      tenant              = local.tenant
      tenantid            = local.tenantid
      token               = local.token
      policyid            = local.policy_id[local.environment]
    }
  )
  tags = {
    Name = "steps"
  }
}


resource "aws_s3_bucket_object" "configurations" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/aws_uc_feature/configurations.yaml"
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
      hive_tez_container_size                       = local.hive_tez_container_size[local.environment]
      hive_tez_java_opts                            = local.hive_tez_java_opts[local.environment]
      hive_auto_convert_join_noconditionaltask_size = local.hive_auto_convert_join_noconditionaltask_size[local.environment]
      tez_grouping_min_size                         = local.tez_grouping_min_size[local.environment]
      tez_grouping_max_size                         = local.tez_grouping_max_size[local.environment]
      tez_am_resource_memory_mb                     = local.tez_am_resource_memory_mb[local.environment]
      tez_am_launch_cmd_opts                        = local.tez_am_launch_cmd_opts[local.environment]
      tez_runtime_io_sort_mb                        = local.tez_runtime_io_sort_mb[local.environment]
      hive_bytes_per_reducer                        = local.hive_bytes_per_reducer[local.environment]
      hive_tez_sessions_per_queue                   = local.hive_tez_sessions_per_queue[local.environment]
      llap_number_of_instances                      = local.llap_number_of_instances[local.environment]
      llap_daemon_yarn_container_mb                 = local.llap_daemon_yarn_container_mb[local.environment]
      hive_max_reducers                             = local.hive_max_reducers[local.environment]
      map_reduce_vcores_per_task                    = local.map_reduce_vcores_per_task[local.environment]
      map_reduce_vcores_per_node                    = local.map_reduce_vcores_per_node[local.environment]

      hive_metastore_username      = data.terraform_remote_state.internal_compute.outputs.metadata_store_users.uc_feature_writer.username
      hive_metastore_pwd           = data.terraform_remote_state.internal_compute.outputs.metadata_store_users.uc_feature_writer.secret_name
      hive_metastore_endpoint      = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.endpoint
      hive_metastore_database_name = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.database_name
      hive_metastore_location      = local.hive_metastore_location
      s3_published_bucket          = data.terraform_remote_state.common.outputs.published_bucket.id
      s3_processed_bucket          = data.terraform_remote_state.common.outputs.processed_bucket.id
    }
  )
  tags = {
    Name = "configurations"
  }
}

