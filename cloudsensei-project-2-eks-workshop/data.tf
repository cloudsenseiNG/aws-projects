data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
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
