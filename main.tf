resource "kubernetes_namespace" "flux" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "flux_git_deploy" {
  metadata {
    name      = "${local.flux}-git-deploy"
    namespace = kubernetes_namespace.flux.metadata.0.name
  }
  type = "Opaque"
  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_service_account" "flux" {
  metadata {
    name      = local.flux
    namespace = kubernetes_namespace.flux.metadata.0.name
    labels    = local.flux_labels
  }
}

resource "kubernetes_cluster_role" "flux" {
  metadata {
    name   = local.flux
    labels = local.flux_labels
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

resource "kubernetes_cluster_role_binding" "flux" {
  metadata {
    name   = local.flux
    labels = local.flux_labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.flux
    namespace = kubernetes_namespace.flux.metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.flux
  }
}



resource "kubernetes_service" "flux" {
  metadata {
    name      = local.flux
    namespace = kubernetes_namespace.flux.metadata.0.name
    labels    = local.flux_labels
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 3030
      target_port = "http"
    }

    selector = local.flux_labels
    type     = "ClusterIP"
  }
}

resource "kubernetes_deployment" "flux" {
  metadata {
    name      = local.flux
    namespace = kubernetes_namespace.flux.metadata.0.name
    labels    = local.flux_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.flux_labels
    }

    template {
      metadata {
        labels = local.flux_labels
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

        volume {
          name = "git-keygen"

          empty_dir {
            medium = "Memory"
          }
        }

        container {
          name  = local.flux
          image = "docker.io/fluxcd/flux:${var.flux_version}"
          args = concat([
            "--k8s-secret-name=${kubernetes_secret.flux_git_deploy.metadata.0.name}",
            "--git-url=${var.git_url}",
            "--git-branch=${var.git_branch}",
            "--git-path=${var.git_path}",
          ], var.flux_arguments)

          port {
            name           = "http"
            container_port = 3030
            protocol       = "TCP"
          }

          resources {
            requests {
              cpu    = var.flux_resources["cpu"]
              memory = var.flux_resources["memory"]
            }
          }


          volume_mount {
            name       = "git-key"
            read_only  = true
            mount_path = "/etc/fluxd/ssh"
          }

          volume_mount {
            name       = "git-keygen"
            mount_path = "/var/fluxd/keygen"
          }

          liveness_probe {
            http_get {
              path = "/api/flux/v6/identity.pub"
              port = "3030"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }

          readiness_probe {
            http_get {
              path = "/api/flux/v6/identity.pub"
              port = "3030"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }

          image_pull_policy = "IfNotPresent"
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        service_account_name = local.flux
      }
    }
  }
}



