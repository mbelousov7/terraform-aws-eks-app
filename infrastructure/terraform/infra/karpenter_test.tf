locals {

  test_namespace_count  = 0
  test_deployment_count = 0
  test_replicas_count   = 20
  node_selector = {
    "name" = "default"
    //"glr-high-integrity" = "enable"
  }

}


resource "kubernetes_namespace" "example" {

  count    = local.test_namespace_count
  provider = kubernetes.eks
  metadata {
    annotations = {
      name = "test"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "test"
  }
}

resource "kubernetes_deployment" "example" {

  count    = local.test_deployment_count
  provider = kubernetes.eks

  depends_on = [kubernetes_namespace.example]

  metadata {
    name      = "terraform-example-${count.index}"
    namespace = "test"
    labels = {
      test = "MyExampleApp-${count.index}"
    }
  }

  spec {

    progress_deadline_seconds = 180
    replicas                  = local.test_replicas_count
    selector {
      match_labels = {
        test = "MyExampleApp-${count.index}"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp-${count.index}"
        }
      }

      spec {
        node_selector = local.node_selector

        container {

          image             = "nginx:1.21.6"
          name              = "example"
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              cpu    = "0.2"
              memory = "200Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

