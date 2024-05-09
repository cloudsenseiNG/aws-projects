locals {
  grafana_values = <<EOF
serviceAccount:
  create: false
  name: grafana

env:
  AWS_SDK_LOAD_CONFIG: true
  GF_AUTH_SIGV4_AUTH_ENABLED: true

ingress:
  enabled: true
  hosts: []
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
  ingressClassName: alb

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: ${aws_prometheus_workspace.this.prometheus_endpoint}
      access: proxy
      jsonData:
        httpMethod: "POST"
        sigV4Auth: true
        sigV4AuthType: "default"
        sigV4Region: ${data.aws_region.current.name}
      isDefault: true

dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: default
      orgId: 1
      folder: ""
      type: file
      disableDeletion: false
      editable: false
      options:
        path: /var/lib/grafana/dashboards/default
    - name: orders-service
      orgId: 1
      folder: "retail-app-metrics"
      type: file
      disableDeletion: false
      editable: false
      options:
        path: /var/lib/grafana/dashboards/orders-service    

dashboardsConfigMaps:
  orders-service: "order-service-metrics-dashboard"

dashboards:
  default:
    kubernetesCluster:
      gnetId: 3119
      revision: 2
      datasource: Prometheus

sidecar:
  dashboards:
    enabled: true
    searchNamespace: ALL
    label: app.kubernetes.io/component
    labelValue: grafana
EOF
  cw_log_group_name = "eks-cloudwatch-log-group"
  addon_context = {
  aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
  aws_caller_identity_arn        = data.aws_caller_identity.current.arn
  aws_eks_cluster_endpoint       = module.eks.cluster_endpoint
  aws_partition_id               = data.aws_partition.current.partition
  aws_region_name                = data.aws_region.current.name
  eks_cluster_id                 = module.eks.cluster_name
  eks_oidc_issuer_url            = module.eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn          = module.eks.oidc_provider_arn
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
  source  = "terraform-aws-modules/eks/aws"
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

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

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

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "aws_ebs_csi_driver" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.25.0//modules/kubernetes-addons/aws-ebs-csi-driver"

  enable_amazon_eks_aws_ebs_csi_driver = true

  addon_config = {
    kubernetes_version = module.eks.cluster_version
    preserve           = false
  }

  addon_context = local.addon_context
}

module "aws-for-fluentbit" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1//modules/kubernetes-addons/aws-for-fluentbit"

  cw_log_group_name = local.cw_log_group_name

  addon_context = local.addon_context
}

module "preprovision" {
  source = "./preprovision"
  # count  = var.resources_precreated ? 0 : 1

  eks_cluster_id = var.cluster_name
  tags           = local.tags
}

module "kubecost" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  depends_on = [
    time_sleep.wait
  ]

  name             = "kubecost"
  description      = "Kubecost Helm Chart deployment configuration"
  namespace        = "kubecost"
  create_namespace = true
  chart            = "cost-analyzer"
  chart_version    = "1.106.3"
  repository       = "oci://public.ecr.aws/kubecost"
  values           = [data.http.kubecost_values.body, templatefile("${path.module}/values.yaml", {})]
  wait             = true

  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
}

resource "time_sleep" "wait" {
  depends_on = [
    module.eks_blueprints_addons
  ]

  create_duration = "10s"
}

resource "time_sleep" "blueprints_addons_sleep" {
  depends_on = [
    module.eks_blueprints_addons,
    module.aws_ebs_csi_driver
  ]

  create_duration = "15s"
}

module "adot_operator" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.25.0//modules/kubernetes-addons/opentelemetry-operator"

  depends_on = [
    time_sleep.blueprints_addons_sleep
  ]

  addon_config = {
    kubernetes_version = module.eks.cluster_version
    addon_version      = "v0.92.1-eksbuild.1"
    most_recent        = false

    preserve = false
  }

  addon_context = local.addon_context
}

resource "aws_prometheus_workspace" "this" {
  alias = module.eks.cluster_id

  # tags = var.tags
}

module "iam_assumable_role_adot" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "5.39.0"
  create_role  = true
  role_name    = "${module.eks.cluster_name}-adot-collector"
  provider_url = module.eks.cluster_oidc_issuer_url
  role_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
  ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:other:adot-collector"]

  # tags = var.tags
}

module "iam_assumable_role_adot_ci" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.39.0"
  create_role                   = true
  role_name                     = "${module.eks.cluster_name}-adot-collector-ci"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_policy_arns              = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:other:adot-collector-ci"]

}
resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

module "eks_blueprints_kubernetes_grafana_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.25.0//modules/kubernetes-addons/grafana"

  depends_on = [
    time_sleep.blueprints_addons_sleep,
    kubernetes_config_map.order_service_metrics_dashboard
  ]

  addon_context = local.addon_context

  irsa_policies = [
    aws_iam_policy.grafana.arn
  ]

  helm_config = {
    create_namespace = false
    namespace        = kubernetes_namespace.grafana.metadata[0].name

    values = [local.grafana_values]
  }
}

resource "kubernetes_config_map" "order_service_metrics_dashboard" {
  metadata {
    name      = "order-service-metrics-dashboard"
    namespace = kubernetes_namespace.grafana.metadata[0].name

    labels = {
      grafana_dashboard = 1
    }
  }

  data = {
    "order-service-metrics-dashboard.json" = <<EOF
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "target": {
          "limit": 100,
          "matchAny": false,
          "tags": [],
          "type": "dashboard"
        },
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            }
          },
          "mappings": []
        },
        "overrides": []
      },
      "gridPos": {
        "h": 9,
        "w": 9,
        "x": 0,
        "y": 0
      },
      "id": 2,
      "options": {
        "legend": {
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "pieType": "pie",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "builder",
          "expr": "sum by(productId) (watch_orders_total{productId!=\"*\"})",
          "legendFormat": "__auto",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Orders by Product ",
      "type": "piechart"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 9,
        "w": 6,
        "x": 9,
        "y": 0
      },
      "id": 6,
      "options": {
        "colorMode": "value",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "auto",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "auto"
      },
      "pluginVersion": "9.2.2",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "code",
          "expr": "sum(watch_orders_total{productId=\"*\"}) by (productId)",
          "legendFormat": "__auto",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Order Count",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 15,
        "x": 0,
        "y": 9
      },
      "id": 4,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "editorMode": "code",
          "expr": "sum by (productId)(rate(watch_orders_total{productId=\"*\"}[2m]))",
          "legendFormat": "__auto",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Order Rate",
      "type": "timeseries"
    }
  ],
  "schemaVersion": 37,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-3h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "Order Service Metrics",
  "uid": "r7QHEZEVz",
  "version": 1,
  "weekStart": ""
}
EOF
  }
}

resource "aws_cloudwatch_dashboard" "order_metrics_ci" {
  dashboard_name = "Order-Service-Metrics-1"

  dashboard_body = jsonencode(
    {
      "widgets" : [
        {
          "height" : 6,
          "width" : 6,
          "y" : 0,
          "x" : 0,
          "type" : "metric",
          "properties" : {
            "metrics" : [
              [{ "expression" : "SELECT COUNT(watch_orders_total) FROM \"ContainerInsights/Prometheus\" WHERE productId != '*' GROUP BY productId", "label" : "Query1", "id" : "q1", "region" : "us-west-2" }]
            ],
            "view" : "pie",
            "region" : "us-west-2",
            "title" : "Orders by ProductId",
            "period" : 300,
            "stat" : "Average"
          }
        },
        {
          "height" : 6,
          "width" : 6,
          "y" : 0,
          "x" : 6,
          "type" : "metric",
          "properties" : {
            "sparkline" : true,
            "view" : "singleValue",
            "metrics" : [
              [{ "expression" : "SELECT SUM(watch_orders_total) FROM \"ContainerInsights/Prometheus\" WHERE productId = '*'", "label" : "Query1", "id" : "q1" }]
            ],
            "region" : "us-west-2",
            "stat" : "Average",
            "period" : 300,
            "title" : "Order Count"
          }
        }
      ]
  })
}