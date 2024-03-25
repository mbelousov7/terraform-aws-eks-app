locals {

  ingress_nginx_count      = var.bootstrap_eks_count == 1 && var.ingress_nginx_helm_count == 1 ? 1 : 0
  ingress_nginx_lb_count   = var.bootstrap_eks_count == 1 && var.ingress_nginx_lb_count == 1 ? 1 : 0
  ingress_nginx_chart_name = "ingress-nginx" //do not change
  ingress_nginx_namespace  = "ingress-nginx" //do not change
  ingress_nginx_class      = "nginx"         //do not change


  ingress_nginx_labels = merge(
    { env = var.tf_zone },
    { prefix = local.ingress_nginx_chart_name },
    { stack = var.tf_stack },
  )

  ingress_nginx_security_group = {
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "Allow HTTP access"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "Allow HTTP access"
        cidr_blocks = ["0.0.0.0/0"]
      },
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Allow All access"
        cidr_blocks = ["0.0.0.0/0"]
      },
    ]
  }
}


/*module "ingress_nginx_security_group" {
  count         = 1 //local.ingress_nginx_count
  source        = "./../../shared/terraform-modules/aws-security-group"
  vpc_id        = data.aws_vpc.main.id
  ingress_rules = local.ingress_nginx_security_group.ingress_rules
  egress_rules  = local.ingress_nginx_security_group.egress_rules
  labels        = merge(local.ingress_nginx_labels, { component = local.ingress_nginx_chart_name }, )
}*/

data "aws_lb" "ingress_nginx" {
  count = local.ingress_nginx_lb_count
  tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
  }
}


resource "helm_release" "ingress_nginx_eks" {
  count    = local.ingress_nginx_count
  provider = helm.eks
  chart    = "./../../shared/helm-charts/ingress-nginx-4.9.1"

  name = local.ingress_nginx_chart_name

  namespace        = local.ingress_nginx_namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/helm/helm-chart-ingress-nginx.yaml",
      {

        ingress_nginx_class = local.ingress_nginx_class

        ingress_nginx_default = true

        default_backend_enabled = true

        image = var.ingress_nginx_helm_chart_config.image

        //https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
        config = {
          ssl-redirect          = "false"
          use-forwarded-headers = "true"
          //use-gzip                  = "true"
          //gzip-types                = "text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript"
          allow-snippet-annotations = "true"
          //http-snippet              = "proxy_cache_path /tmp/nginx_cache levels=1:2 keys_zone=static-cache:10m max_size=1g inactive=60m use_temp_path=off;"
        }

        service = {
          enableHttp  = true
          enableHttps = true
          annotations = [
            "service.beta.kubernetes.io/aws-load-balancer-type: nlb",
            "service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing",
            "service.beta.kubernetes.io/aws-load-balancer-attributes: load_balancing.cross_zone.enabled=true",

            //"service.beta.kubernetes.io/aws-load-balancer-internal: true",
            //"service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp",
            //"service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: 3600",
            //"service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: '*'",
            //"service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https",
            //"service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${var.ingress_nginx_helm_chart_config.ingress_nginx_acm_cert_arn}",
            //"service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: ELBSecurityPolicy-TLS-1-2-2017-01",
          ]
        }

        replica_count = 2

        node_selector = [
          "kubernetes.io/os: linux",
          "name: default",
        ]

    })

  ]

}

