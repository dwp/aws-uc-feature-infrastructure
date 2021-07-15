resource "aws_cloudwatch_event_target" "aws_uc_feature_success_start_object_tagger" {
  target_id = "aws_uc_feature_success"
  rule      = aws_cloudwatch_event_rule.aws_uc_feature_success.name
  arn       = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.uc_feature_job_queue.arn
  role_arn  = aws_iam_role.allow_batch_job_submission.arn

  batch_target {
    job_definition = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.job_definition.id
    job_name       = "aws-uc-feature-success-cloudwatch-event"
  }

  input = "{\"Parameters\": {\"data-s3-prefix\": \"${local.data_classification.data_s3_prefix}\", \"csv-location\": \"s3://${local.data_classification.config_bucket_id}/${local.data_classification.config_prefix}/${local.data_classification.config_file}}\"}}"
}


resource "aws_cloudwatch_event_target" "pdm_success_with_errors_start_object_tagger" {
  target_id = "aws_uc_feature_success_with_errors"
  rule      = aws_cloudwatch_event_rule.aws_uc_feature_succes_with_errors.name
  arn       = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.uc_feature_job_queue.arn
  role_arn  = aws_iam_role.allow_batch_job_submission.arn

  batch_target {
    job_definition = data.terraform_remote_state.aws_s3_object_tagger.outputs.s3_object_tagger_batch.job_definition.id
    job_name       = "aws-uc-feature-success-with-errors-cloudwatch-event"
  }

  input = "{\"Parameters\": {\"data-s3-prefix\": \"${local.data_classification.data_s3_prefix}\", \"csv-location\": \"s3://${local.data_classification.config_bucket_id}/${local.data_classification.config_prefix}/${local.data_classification.config_file}}\"}}"
}

resource "aws_iam_role" "allow_batch_job_submission" {
  name               = "AllowUcFeatureBatchJobSubmission"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_assume_role.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "cloudwatch_events_assume_role" {
  statement {
    sid    = "CloudwatchEventsAssumeRolePolicy"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "allow_batch_job_submission" {
  statement {
    sid    = "AllowBatchJobSubmission"
    effect = "Allow"

    actions = [
      "batch:SubmitJob",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_batch_job_submission" {
  name   = "AllowBatchJobSubmission"
  policy = data.aws_iam_policy_document.allow_batch_job_submission.json
}

resource "aws_iam_role_policy_attachment" "allow_batch_job_submission" {
  role       = aws_iam_role.allow_batch_job_submission.name
  policy_arn = aws_iam_policy.allow_batch_job_submission.arn
}
