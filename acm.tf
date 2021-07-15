resource "aws_acm_certificate" "aws_uc_feature" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "${local.emr_cluster_name}.${local.env_prefix[local.environment]}${local.dataworks_domain_name}"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags = {
    Name = "aws_uc_feature"
  }
}

data "aws_iam_policy_document" "aws_uc_feature_acm" {
  statement {
    effect = "Allow"

    actions = [
      "acm:ExportCertificate",
    ]

    resources = [
      aws_acm_certificate.aws_uc_feature.arn
    ]
  }
}

resource "aws_iam_policy" "aws_uc_feature_acm" {
  name        = "ACMExport-${local.emr_cluster_name}-Cert"
  description = "Allow export of aws-uc-feature certificate"
  policy      = data.aws_iam_policy_document.aws_uc_feature_acm.json
  tags = {
    Name = "aws_uc_feature_acm"
  }
}

data "aws_iam_policy_document" "aws_uc_feature_certificates" {
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

resource "aws_iam_policy" "aws_uc_feature_certificates" {
  name        = "aws_uc_featureGetCertificates"
  description = "Allow read access to the Crown-specific subset of the aws_uc_feature"
  policy      = data.aws_iam_policy_document.aws_uc_feature_certificates.json
  tags = {
    Name = "aws_uc_feature_certificates"
  }
}


