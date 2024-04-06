resource "aws_iam_role" "fargate" {
  name                  = "${module.eks.cluster_name}-fargate"
  description           = "EKS Fargate IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.fargate_assume_role_policy.json
  force_detach_policies = true
  tags                  = local.tags
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  policy_arn = "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}


resource "aws_iam_policy" "cwlogs" {
  name        = "${module.eks.cluster_name}-fargate-cwlogs"
  description = "Allow fargate profiles to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.cwlogs.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  policy_arn = aws_iam_policy.cwlogs.arn
  role       = aws_iam_role.fargate.name
}