data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_uc_feature" {
  name               = "aws_uc_feature"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name = "aws_uc_feature"
  }
}

resource "aws_iam_instance_profile" "aws_uc_feature" {
  name = "aws_uc_feature"
  role = aws_iam_role.aws_uc_feature.id
  tags = {
    Name = "aws_uc_feature"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "amazon_ssm_managed_instance_core" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_ebs_cmk" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_ebs_cmk_encrypt.arn
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_acm" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_acm.arn
}

data "aws_iam_policy_document" "aws_uc_feature_extra_ssm_properties" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstanceStatus",
    ]

    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ds:CreateComputer",
      "ds:DescribeDirectories",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::eu-west-2.elasticmapreduce",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::eu-west-2.elasticmapreduce/libs/script-runner/*",
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_extra_ssm_properties" {
  name        = "AwsEmrTemplateRepositoryExtraSSM"
  description = "Additional properties to allow for SSM and writing logs"
  policy      = data.aws_iam_policy_document.aws_uc_feature_extra_ssm_properties.json
  tags = {
    Name = "aws_uc_feature_extra_ssm_properties"
  }
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_extra_ssm_properties" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_extra_ssm_properties.arn
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_certificates" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_certificates.arn
}

data "aws_iam_policy_document" "aws_uc_feature_write_logs" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
      "s3:PutObject*",

    ]

    resources = [
      "${data.terraform_remote_state.security-tools.outputs.logstore_bucket.arn}/${local.s3_log_prefix}",
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_write_logs" {
  name        = "aws-uc-feature-WriteLogs"
  description = "Allow writing of aws_uc_feature logs"
  policy      = data.aws_iam_policy_document.aws_uc_feature_write_logs.json
  tags = {
    Name = "aws_uc_feature_write_logs"
  }
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_write_logs" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_write_logs.arn
}

data "aws_iam_policy_document" "aws_uc_feature_read_config" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.config_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_read_config" {
  name        = "aws-uc-feature-ReadConfig"
  description = "Allow reading of aws_uc_feature config files"
  policy      = data.aws_iam_policy_document.aws_uc_feature_read_config.json
  tags = {
    Name = "aws_uc_feature_read_config"
  }
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_read_config" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_read_config.arn
}

data "aws_iam_policy_document" "aws_uc_feature_read_artefacts" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.management_artefact.outputs.artefact_bucket.cmk_arn,
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_read_artefacts" {
  name        = "aws-uc-feature-ReadArtefacts"
  description = "Allow reading of aws_uc_feature software artefacts"
  policy      = data.aws_iam_policy_document.aws_uc_feature_read_artefacts.json
  tags = {
    Name = "aws_uc_feature_read_artefacts"
  }
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_read_artefacts" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_read_artefacts.arn
}

data "aws_iam_policy_document" "aws_uc_feature_write_dynamodb" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:${local.account[local.environment]}:table/${local.data_pipeline_metadata}"
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_write_dynamodb" {
  name        = "AwsEmrTemplateRepositoryDynamoDB"
  description = "Allows read and write access toaws_uc_feature's EMRFS DynamoDB table"
  policy      = data.aws_iam_policy_document.aws_uc_feature_write_dynamodb.json
  tags = {
    Name = "aws_uc_feature_write_dynamodb"
  }
}

resource "aws_iam_role_policy_attachment" "analytical_dataset_generator_dynamodb" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_write_dynamodb.arn
}

data "aws_iam_policy_document" "aws_uc_feature_metadata_change" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:ModifyInstanceMetadataOptions",
      "ec2:*Tags",
    ]

    resources = [
      "arn:aws:ec2:${var.region}:${local.account[local.environment]}:instance/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_read_write_processed_bucket" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_read_write_processed_bucket.arn
}

resource "aws_iam_policy" "aws_uc_feature_metadata_change" {
  name        = "aws-uc-feature-MetadataOptions"
  description = "Allow editing of Metadata Options"
  policy      = data.aws_iam_policy_document.aws_uc_feature_metadata_change.json
  tags = {
    Name = "aws_uc_feature_metadata_change"
  }
}

resource "aws_iam_role_policy_attachment" "aws_uc_feature_metadata_change" {
  role       = aws_iam_role.aws_uc_feature.name
  policy_arn = aws_iam_policy.aws_uc_feature_metadata_change.arn
}
