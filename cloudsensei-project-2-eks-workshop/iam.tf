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

# Random suffix for IAM roles, policies
resource "random_string" "suffix" {
  length  = 6
  special = false
}

# Lambda execution role for OpenSearch exporter
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.lambda_function_name}-Role-${random_string.suffix.result}"

  # Trust relationship 
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

  # Attach inline policies for Lambda function to: 
  #    Write to OpenSearch index
  #    Get SSM parameter with OpenSearch host 
  #    Write CloudWatch logs for this Lambda function
  inline_policy {
    name = "policy-${random_string.suffix.result}"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["es:*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["ssm:GetParameter", "kms:Decrypt"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = local.cw_logs_arn_prefix
        },
        {
          Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
          Effect   = "Allow"
          Resource = "${local.cw_logs_arn_prefix}:log-group:/aws/lambda/${local.lambda_function_name}:*"
        }
      ]
    })
  }
}