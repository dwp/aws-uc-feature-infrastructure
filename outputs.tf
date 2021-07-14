output "aws_uc_feature_infrastructure_common_sg" {
  value = aws_security_group.aws_uc_feature_infrastructure_common
}

output "aws_uc_feature_infrastructure_emr_launcher_lambda" {
  value = aws_lambda_function.aws_uc_feature_infrastructure_emr_launcher
}

output "private_dns" {
  value = {
    mongo_latest_service_discovery_dns = aws_service_discovery_private_dns_namespace.aws_uc_feature_infrastructure_services
    mongo_latest_service_discovery     = aws_service_discovery_service.aws_uc_feature_infrastructure_services
  }
}
