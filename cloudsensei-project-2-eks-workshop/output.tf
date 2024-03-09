output "configure_kubectl" {
  description = "Command to update kubeconfig for this cluster"
  value       = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "environment" {
  value = <<EOF
export EBS_CSI_ADDON_ROLE="${module.ebs_csi_driver_irsa.iam_role_arn}"
EOF
}