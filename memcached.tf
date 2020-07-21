resource "kubernetes_deployment" "flux_memcached" {
  count = var.memcached ? 1 : 0
  metadata {
    name      = local.memcached
    namespace = kubernetes_namespace.flux.metadata.0.name
    labels    = local.memcached_labels
  }

  spec {
    replicas = var.memcached_replicas

    selector {
      match_labels = local.memcached_labels
    }

    template {
      metadata {
        labels = local.memcached_labels
      }

      spec {
        container {
          name  = "memcached"
          image = "memcached:${var.memcached_version}"
          args  = var.memcached_arguments

          port {
            name           = "memcached"
            container_port = 11211
          }

          resources {
            requests {
              cpu    = var.memcached_resources["cpu"]
              memory = var.memcached_resources["memory"]
            }
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user  = 11211
            run_as_group = 11211
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

resource "kubernetes_service" "flux_memcached" {
  count = var.memcached ? 1 : 0
  metadata {
    name      = local.memcached
    namespace = kubernetes_namespace.flux.metadata.0.name
    labels    = local.memcached_labels
  }

  spec {
    port {
      name        = "memcached"
      protocol    = "TCP"
      port        = 11211
      target_port = "memcached"
    }
    selector = local.memcached_labels
  }
}
