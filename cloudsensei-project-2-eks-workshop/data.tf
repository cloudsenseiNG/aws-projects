data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_iam_policy_document" "cwlogs" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
  }
}

data "aws_partition" "current" {}

# data "aws_vpc" "selected" {
#   tags = {
#     created-by = "eks-workshop-v2"
#     env        = module.eks.cluster_name
#   }
# }

data "aws_subnets" "private" {
  tags = {
    created-by = "eks-workshop-v2"
    env        = module.eks.cluster_name
  }

  filter {
    name   = "tag:Name"
    values = ["*Private*"]
  }
}

data "aws_iam_policy_document" "fargate_assume_role_policy" {
  statement {
    sid = "EKSFargateAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

# Create ZIP file with Lambda code
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/logs-to-opensearch.js"
  output_path = "${path.module}/function.zip"
}

data "http" "kubecost_values" {
  url = "https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/v1.106.3/cost-analyzer/values-eks-cost-monitoring.yaml"
}