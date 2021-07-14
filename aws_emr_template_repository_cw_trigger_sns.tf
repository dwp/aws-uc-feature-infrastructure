resource "aws_sns_topic" "aws_uc_feature_infrastructure_cw_trigger_sns" {
  name = "aws_uc_feature_infrastructure_cw_trigger_sns"

  tags = {
    "Name" = "aws_uc_feature_infrastructure_cw_trigger_sns"
  }
}

output "aws_uc_feature_infrastructure_cw_trigger_sns_topic" {
  value = aws_sns_topic.aws_uc_feature_infrastructure_cw_trigger_sns
}
