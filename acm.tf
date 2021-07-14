resource "aws_acm_certificate" "aws_uc_feature_infrastructure" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "aws-uc-feature-infrastructure.${local.env_prefix[local.environment]}${local.dataworks_domain_name}"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags = {
    Name = "aws_uc_feature_infrastructure"
  }
}

data "aws_iam_policy_document" "aws_uc_feature_infrastructure_acm" {
  statement {
    effect = "Allow"

    actions = [
      "acm:ExportCertificate",
    ]

    resources = [
      aws_acm_certificate.aws_uc_feature_infrastructure.arn
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_infrastructure_acm" {
  name        = "ACMExport-aws-uc-feature-infrastructure-Cert"
  description = "Allow export of aws-uc-feature-infrastructure certificate"
  policy      = data.aws_iam_policy_document.aws_uc_feature_infrastructure_acm.json
  tags = {
    Name = "aws_uc_feature_infrastructure_acm"
  }
}

data "aws_iam_policy_document" "aws_uc_feature_infrastructure_certificates" {
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::${local.mgt_certificate_bucket}*",
      "arn:aws:s3:::${local.env_certificate_bucket}/*",
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_infrastructure_certificates" {
  name        = "aws_uc_feature_infrastructureGetCertificates"
  description = "Allow read access to the Crown-specific subset of the aws_uc_feature_infrastructure"
  policy      = data.aws_iam_policy_document.aws_uc_feature_infrastructure_certificates.json
  tags = {
    Name = "aws_uc_feature_infrastructure_certificates"
  }
}


