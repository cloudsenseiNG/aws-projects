locals {
 # fix the code with the correct values
  cw_log_group_name = "eks-cloudwatch-log-group"
  addon_context = {
  aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
  aws_caller_identity_arn        = data.aws_caller_identity.current.arn
  aws_eks_cluster_endpoint       = local.eks.cluster_endpoint
  aws_partition_id               = data.aws_partition.current.partition
  aws_region_name                = data.aws_region.current.name
  eks_cluster_id                 = local.eks.cluster_name
  eks_oidc_issuer_url            = local.eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn          = local.eks.oidc_provider_arn
  tags                           = {}
  irsa_iam_role_path             = "/"
  irsa_iam_permissions_boundary  = ""
  }
  tags = {
    created-by = "eks-workshop-v2"
    env        = var.cluster_name
  }
}
module "eks" {
  source  = "terraform-aws-locals/eks/aws"
  version = "~> 19.16"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }

        enableNetworkPolicy = "true"
      })
    }
  }

  vpc_id     = local.vpc.vpc_id
  subnet_ids = local.vpc.private_subnets

  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    default = {
      instance_types       = ["m5.large"]
      force_update_version = true
      release_version      = var.ami_release_version

      min_size     = 3
      max_size     = 6
      desired_size = 3

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        workshop-default = "yes"
      }
    }
  }

  tags = merge(local.tags, {
    "karpenter.sh/discovery" = var.cluster_name
  })
}

module "aws-for-fluentbit" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1//locals/kubernetes-addons/aws-for-fluentbit"

  cw_log_group_name = local.cw_log_group_name

  addon_context = local.addon_context
}