resource "aws_cloudwatch_event_rule" "aws_uc_feature_failed" {
  name          = "aws_uc_feature_failed"
  description   = "Sends failed message to slack when aws_uc_feature cluster terminates with errors"
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
      "${local.emr_cluster_name}"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_failed"
  }
}

resource "aws_cloudwatch_event_rule" "aws_uc_feature_terminated" {
  name          = "aws_uc_feature_terminated"
  description   = "Sends failed message to slack when aws_uc_feature cluster terminates by user request"
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
      "${local.emr_cluster_name}"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_terminated"
  }
}

resource "aws_cloudwatch_event_rule" "aws_uc_feature_success" {
  name          = "aws_uc_feature_success"
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
      "${local.emr_cluster_name}"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_success"
  }
}

resource "aws_cloudwatch_event_rule" "aws_uc_feature_running" {
  name          = "aws_uc_feature_running"
  description   = "checks that aws_uc_feature is running"
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
      "${local.emr_cluster_name}"
    ]
  }
}
EOF

  tags = {
    Name = "aws_uc_feature_running"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_failed" {
  count                     = local.aws_uc_feature_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_failed"
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
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_failed.name
  }
  tags = {
    Name              = "aws_uc_feature_failed",
    notification_type = "Error",
    severity          = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_terminated" {
  count                     = local.aws_uc_feature_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_terminated"
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
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_terminated.name
  }
  tags = {
    Name              = "aws_uc_feature_terminated",
    notification_type = "Information",
    severity          = "High"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_success" {
  count                     = local.aws_uc_feature_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_uc_feature completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_success.name
  }
  tags = {
    Name              = "aws_uc_feature_success",
    notification_type = "Information",
    severity          = "Critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "aws_uc_feature_running" {
  count                     = local.aws_uc_feature_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_uc_feature_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_uc_feature running"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_uc_feature_running.name
  }
  tags = {
    Name              = "aws_uc_feature_running",
    notification_type = "Information",
    severity          = "Critical"
  }
}
