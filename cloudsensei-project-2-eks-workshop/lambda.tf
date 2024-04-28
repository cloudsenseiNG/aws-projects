locals {
  cw_logs_arn_prefix   = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
  lambda_function_name = "${module.eks.cluster_name}-control-plane-logs"

  # ARNs for Lambda Extension Layer that provides caching of SSM parameter store values
  parameter_lambda_extension_arns = {
    af-south-1     = "arn:aws:lambda:af-south-1:317013901791:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-east-1      = "arn:aws:lambda:ap-east-1:768336418462:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-northeast-1 = "arn:aws:lambda:ap-northeast-1:133490724326:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-northeast-2 = "arn:aws:lambda:ap-northeast-2:738900069198:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-northeast-3 = "arn:aws:lambda:ap-northeast-3:576959938190:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-south-1     = "arn:aws:lambda:ap-south-1:176022468876:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-south-2     = "arn:aws:lambda:ap-south-2:070087711984:layer:AWS-Parameters-and-Secrets-Lambda-Extension:8",
    ap-southeast-1 = "arn:aws:lambda:ap-southeast-1:044395824272:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-southeast-2 = "arn:aws:lambda:ap-southeast-2:665172237481:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-southeast-3 = "arn:aws:lambda:ap-southeast-3:490737872127:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    ap-southeast-4 = "arn:aws:lambda:ap-southeast-4:090732460067:layer:AWS-Parameters-and-Secrets-Lambda-Extension:1",
    ca-central-1   = "arn:aws:lambda:ca-central-1:200266452380:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    cn-north-1     = "arn:aws-cn:lambda:cn-north-1:287114880934:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    cn-northwest-1 = "arn:aws-cn:lambda:cn-northwest-1:287310001119:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    eu-central-1   = "arn:aws:lambda:eu-central-1:187925254637:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    eu-central-2   = "arn:aws:lambda:eu-central-2:772501565639:layer:AWS-Parameters-and-Secrets-Lambda-Extension:8",
    eu-north-1     = "arn:aws:lambda:eu-north-1:427196147048:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    eu-south-1     = "arn:aws:lambda:eu-south-1:325218067255:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    eu-south-2     = "arn:aws:lambda:eu-south-2:524103009944:layer:AWS-Parameters-and-Secrets-Lambda-Extension:8",
    eu-west-1      = "arn:aws:lambda:eu-west-1:015030872274:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    eu-west-2      = "arn:aws:lambda:eu-west-2:133256977650:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    eu-west-3      = "arn:aws:lambda:eu-west-3:780235371811:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    il-central-1   = "arn:aws:lambda:il-central-1:148806536434:layer:AWS-Parameters-and-Secrets-Lambda-Extension:1",
    me-south-1     = "arn:aws:lambda:me-south-1:832021897121:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    me-central-1   = "arn:aws:lambda:me-central-1:858974508948:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    sa-east-1      = "arn:aws:lambda:sa-east-1:933737806257:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    us-east-1      = "arn:aws:lambda:us-east-1:177933569100:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    us-east-2      = "arn:aws:lambda:us-east-2:590474943231:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    us-gov-east-1  = "arn:aws-us-gov:lambda:us-gov-east-1:129776340158:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    us-gov-west-1  = "arn:aws-us-gov:lambda:us-gov-west-1:127562683043:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    us-west-1      = "arn:aws:lambda:us-west-1:997803712105:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11",
    us-west-2      = "arn:aws:lambda:us-west-2:345057560386:layer:AWS-Parameters-and-Secrets-Lambda-Extension:11"
  }
}

# Create Lambda function to export logs to OpenSearch
resource "aws_lambda_function" "eks_control_plane_logs_to_opensearch" {
  filename      = "${path.module}/function.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "logs-to-opensearch.handler"

  # Attach Lambda Layer for AWS Parameters and Secrets Lambda Extension ARNs
  layers = [local.parameter_lambda_extension_arns[data.aws_region.current.name]]

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"

  environment {
    variables = {
      OPENSEARCH_HOST_PARAMETER_PATH = "/eksworkshop/${module.eks.cluster_name}/opensearch/host"
      OPENSEARCH_INDEX_NAME          = "eks-control-plane-logs"
      SSM_PARAMETER_STORE_TTL        = 300
    }
  }
}

# Enable CloudWatch Logs to invoke Lambda function that exports to OpenSearch. 
# This sets up resource-based policy for Lambda.  Note that source ARN for the EKS 
# control plane log group has not yet been created at the time of terraform apply.  
# The logs group is created later when workshop participant (manually) run the 
# step to enable EKS Control Plane Logs.  
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch_${random_string.suffix.result}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eks_control_plane_logs_to_opensearch.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = "${local.cw_logs_arn_prefix}:log-group:/aws/eks/${module.eks.cluster_name}/cluster:*"
}
