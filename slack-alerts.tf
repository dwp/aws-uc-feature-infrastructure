resource "aws_cloudwatch_event_rule" "aws_uc_feature_infrastructure_failed" {
  name          = "aws_uc_feature_infrastructure_failed"
  description   = "Sends failed message to slack when aws_uc_feature_infrastructure cluster terminates with errors"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED_WITH_ERRORS"
    ],
    "name": [
      "aws-uc-feature-infrastructure"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_infrastructure_failed"
  }
}

resource "aws_cloudwatch_event_rule" "aws_uc_feature_infrastructure_terminated" {
  name          = "aws_uc_feature_infrastructure_terminated"
  description   = "Sends failed message to slack when aws_uc_feature_infrastructure cluster terminates by user request"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws-uc-feature-infrastructure"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_infrastructure_terminated"
  }
}

resource "aws_cloudwatch_event_rule" "aws_uc_feature_infrastructure_success" {
  name          = "aws_uc_feature_infrastructure_success"
  description   = "checks that all steps complete"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws-uc-feature-infrastructure"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_infrastructure_success"
  }
}

resource "aws_cloudwatch_event_rule" "aws_uc_feature_infrastructure_running" {
  name          = "aws_uc_feature_infrastructure_running"
  description   = "checks that aws_uc_feature_infrastructure is running"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "RUNNING"
    ],
    "name": [
      "aws-uc-feature-infrastructure"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_infrastructure_running"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_infrastructure_failed" {
  count                     = local.aws_uc_feature_infrastructure_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_infrastructure_failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster failed with errors"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_infrastructure_failed.name
  }
  tags = {
    Name              = "aws_uc_feature_infrastructure_failed",
    notification_type = "Error",
    severity          = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_infrastructure_terminated" {
  count                     = local.aws_uc_feature_infrastructure_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_infrastructure_terminated"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster terminated by user request"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_infrastructure_terminated.name
  }
  tags = {
    Name              = "aws_uc_feature_infrastructure_terminated",
    notification_type = "Information",
    severity          = "High"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_infrastructure_success" {
  count                     = local.aws_uc_feature_infrastructure_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_infrastructure_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_uc_feature_infrastructure completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_infrastructure_success.name
  }
  tags = {
    Name              = "aws_uc_feature_infrastructure_success",
    notification_type = "Information",
    severity          = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_infrastructure_running" {
  count                     = local.aws_uc_feature_infrastructure_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_infrastructure_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_uc_feature_infrastructure running"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_infrastructure_running.name
  }
  tags = {
    Name              = "aws_uc_feature_infrastructure_running",
    notification_type = "Information",
    severity          = "Critical"
  }
}
