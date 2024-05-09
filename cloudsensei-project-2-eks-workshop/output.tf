output "configure_kubectl" {
  description = "Command to update kubeconfig for this cluster"
  value       = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "environment_ebs_driver" {
  value = <<EOF
export EBS_CSI_ADDON_ROLE="${module.ebs_csi_driver_irsa.iam_role_arn}"
EOF
}

output "environment_fargate" {
  value = <<EOF
export FARGATE_IAM_PROFILE_ARN=${aws_iam_role.fargate.arn}
%{for index, id in data.aws_subnets.private.ids}
export PRIVATE_SUBNET_${index + 1}=${id}
%{endfor}
EOF
}

output "environment_karpenter" {
  value = <<EOF
export KARP_ROLE="${module.eks_blueprints_addons.karpenter.node_iam_role_name}"
export KARP_ARN="${module.eks_blueprints_addons.karpenter.node_iam_role_arn}"
EOF
}

output "lambda_arn" {
  value = aws_lambda_function.eks_control_plane_logs_to_opensearch.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}

output "environment_variables" {
  description = "Environment variables to be added to the IDE shell"
  value = {
    ADOT_IAM_ROLE_CI = module.iam_assumable_role_adot_ci.iam_role_arn
  }
}