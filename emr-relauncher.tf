variable "dataworks_emr_relauncher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

resource "aws_lambda_function" "aws_uc_feature_emr_relauncher" {
  filename      = "${var.dataworks_emr_relauncher_zip["base_path"]}/dataworks-emr-relauncher-${var.dataworks_emr_relauncher_zip["version"]}.zip"
  function_name = "aws_uc_feature_emr_relauncher"
  role          = aws_iam_role.aws_uc_feature_emr_relauncher_lambda_role.arn
  handler       = "event_handler.handler"
  runtime       = "python3.8"
  source_code_hash = filebase64sha256(
    format(
      "%s/dataworks-emr-relauncher-%s.zip",
      var.dataworks_emr_relauncher_zip["base_path"],
      var.dataworks_emr_relauncher_zip["version"]
    )
  )
  publish = false
  timeout = 60

  environment {
    variables = {
      SNS_TOPIC       = aws_sns_topic.aws_uc_feature_cw_trigger_sns.arn
      TABLE_NAME      = local.data_pipeline_metadata
      MAX_RETRY_COUNT = local.aws_uc_feature_max_retry_count[local.environment]
      LOG_LEVEL       = local.aws_uc_feature_log_level[local.environment]
    }
  }

  tags = {
    Name = "aws_uc_feature_emr_relauncher"
  }
}

resource "aws_cloudwatch_event_target" "aws_uc_feature_emr_relauncher_target" {
  rule      = aws_cloudwatch_event_rule.aws_uc_feature_failed.name
  target_id = "aws_uc_feature_emr_relauncher_target"
  arn       = aws_lambda_function.aws_uc_feature_emr_relauncher.arn
}

resource "aws_iam_role" "aws_uc_feature_emr_relauncher_lambda_role" {
  name               = "aws_uc_feature_emr_relauncher_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.aws_uc_feature_emr_relauncher_assume_policy.json
  tags = {
    Name = "aws_uc_feature_emr_relauncher_lambda_role"
  }
}

resource "aws_lambda_permission" "aws_uc_feature_emr_relauncher_invoke_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_uc_feature_emr_relauncher.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.aws_uc_feature_failed.arn
}

data "aws_iam_policy_document" "aws_uc_feature_emr_relauncher_assume_policy" {
  statement {
    sid     = "UcFeatureEMRLauncherLambdaAssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "aws_uc_feature_emr_relauncher_scan_dynamo_policy" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:Scan"
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:${local.account[local.environment]}:table/${local.data_pipeline_metadata}"
    ]
  }
}

data "aws_iam_policy_document" "aws_uc_feature_emr_relauncher_sns_policy" {
  statement {
    sid    = "AllowAccessToSNSLauncherTopic"
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = [
      aws_sns_topic.aws_uc_feature_cw_trigger_sns.arn
    ]
  }
}

data "aws_iam_policy_document" "aws_uc_feature_emr_relauncher_pass_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/*"
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_emr_relauncher_scan_dynamo_policy" {
  name        = "aws_uc_featureEmrRelauncherScanDynamoDb"
  description = "Allow Emr relauncher to scan pipeline metadata table"
  policy      = data.aws_iam_policy_document.aws_uc_feature_emr_relauncher_scan_dynamo_policy.json
  tags = {
    Name = "aws_uc_feature_emr_relauncher_scan_dynamo_policy"
  }
}

resource "aws_iam_policy" "aws_uc_feature_emr_relauncher_sns_policy" {
  name        = "aws_uc_featureEmrRelauncherSnsPublish"
  description = "Allow aws_uc_feature to run job flow"
  policy      = data.aws_iam_policy_document.aws_uc_feature_emr_relauncher_sns_policy.json
  tags = {
    Name = "aws_uc_feature_emr_relauncher_sns_policy"
  }
}

resource "aws_iam_policy" "aws_uc_feature_emr_relauncher_pass_role_policy" {
  name        = "aws_uc_featureEmrRelauncherPassRole"
  description = "Allow Emr relauncher to publish messages to launcher topic"
  policy      = data.aws_iam_policy_document.aws_uc_feature_emr_relauncher_pass_role_document.json
  tags = {
    Name = "aws_uc_feature_emr_relauncher_pass_role_policy"
  }
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_emr_relauncher_pass_role_attachment" {
  role       = aws_iam_role.aws_uc_feature_emr_relauncher_lambda_role.name
  policy_arn = aws_iam_policy.aws_uc_feature_emr_relauncher_pass_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_emr_relauncher_policy_execution" {
  role       = aws_iam_role.aws_uc_feature_emr_relauncher_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_emr_relauncher_sns_attachment" {
  role       = aws_iam_role.aws_uc_feature_emr_relauncher_lambda_role.name
  policy_arn = aws_iam_policy.aws_uc_feature_emr_relauncher_sns_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_emr_relauncher_scan_dynamo_attachment" {
  role       = aws_iam_role.aws_uc_feature_emr_relauncher_lambda_role.name
  policy_arn = aws_iam_policy.aws_uc_feature_emr_relauncher_scan_dynamo_policy.arn
}
