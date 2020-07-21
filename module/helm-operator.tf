resource "kubernetes_service_account" "helm_operator" {
  count = var.helm_operator ? 1 : 0
  metadata {
    name = "helm-operator"
    namespace = var.namespace

    labels = {
      app = "helm-operator"
    }
  }
}

resource "kubernetes_config_map" "helm_operator_kube_config" {
  count = var.helm_operator ? 1 : 0
  metadata {
    name = "helm-operator-kube-config"
    namespace = var.namespace
  }

  data = {
    config = local.config
  }
}

resource "kubernetes_cluster_role" "helm_operator" {
  count = var.helm_operator ? 1 : 0
  metadata {
    name = "helm-operator"

    labels = {
      app = "helm-operator"
    }
  }

  rule {
    verbs      = ["*"]
    api_groups = ["*"]
    resources  = ["*"]
  }

  rule {
    verbs             = ["*"]
    non_resource_urls = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "helm_operator" {
  count = var.helm_operator ? 1 : 0
  metadata {
    name = "helm-operator"

    labels = {
      app = "helm-operator"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "helm-operator"
    namespace = "flux"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "helm-operator"
  }
}

resource "kubernetes_service" "helm_operator" {
  count = var.helm_operator ? 1 : 0
  metadata {
    name = "helm-operator"
    namespace = var.namespace
    labels = {
      app = "helm-operator"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 3030
      target_port = "http"
    }

    selector = {
      app = "helm-operator"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "helm_operator" {
  count = var.helm_operator ? 1 : 0
  metadata {
    name = "helm-operator"
    namespace = var.namespace

    labels = {
      app = "helm-operator"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "helm-operator"
      }
    }

    template {
      metadata {
        labels = {
          app = "helm-operator"
        }
      }

      spec {
        automount_service_account_token = true
        volume {
          name = "git-key"

          secret {
            secret_name  = kubernetes_secret.flux_git_deploy.metadata.0.name
            default_mode = "0400"
          }
        }

        container {
          name  = "flux-helm-operator"
          image = "docker.io/fluxcd/helm-operator:${var.helm_operator_version}"
          args  = ["--enabled-helm-versions=v3", "--log-format=fmt", "--git-timeout=20s", "--git-poll-interval=5m", "--charts-sync-interval=3m", "--status-update-interval=30s", "--update-chart-deps=true", "--log-release-diffs=false", "--workers=4", "--tiller-namespace=kube-system"]

          port {
            name           = "http"
            container_port = 3030
          }

          resources {
            requests {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          volume_mount {
            name       = "git-key"
            read_only  = true
            mount_path = "/etc/fluxd/ssh"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "3030"
            }

            initial_delay_seconds = 1
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "3030"
            }

            initial_delay_seconds = 1
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "helm-operator"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

