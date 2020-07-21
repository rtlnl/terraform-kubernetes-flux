resource "kubernetes_namespace" "flux" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "flux_git_deploy" {
  metadata {
    name      = "flux-git-deploy"
    namespace = kubernetes_namespace.flux.metadata.0.name
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "flux_kube_config" {
  metadata {
    name      = "flux-kube-config"
    namespace = kubernetes_namespace.flux.metadata.0.name
  }

  data = {
    config = local.config
  }
}

resource "kubernetes_service_account" "flux" {
  metadata {
    name      = "flux"
    namespace = kubernetes_namespace.flux.metadata.0.name

    labels = {
      app = "flux"
    }
  }
}

resource "kubernetes_cluster_role" "flux" {
  metadata {
    name = "flux"

    labels = {
      app = "flux"
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

resource "kubernetes_cluster_role_binding" "flux" {
  metadata {
    name = "flux"

    labels = {
      app = "flux"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "flux"
    namespace = "flux"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "flux"
  }
}

resource "kubernetes_service" "flux_memcached" {
  metadata {
    name      = "flux-memcached"
    namespace = kubernetes_namespace.flux.metadata.0.name

    labels = {
      app = "flux-memcached"
    }
  }

  spec {
    port {
      name        = "memcached"
      protocol    = "TCP"
      port        = 11211
      target_port = "memcached"
    }

    selector = {
      app = "flux-memcached"
    }
  }
}

resource "kubernetes_service" "flux" {
  metadata {
    name      = "flux"
    namespace = kubernetes_namespace.flux.metadata.0.name

    labels = {
      app = "flux"
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
      app = "flux"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "flux" {
  metadata {
    name      = "flux"
    namespace = kubernetes_namespace.flux.metadata.0.name

    labels = {
      app = "flux"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "flux"
      }
    }

    template {
      metadata {
        labels = {
          app = "flux"
        }
      }

      spec {
        automount_service_account_token = true
        volume {
          name = "kubedir"

          config_map {
            name = kubernetes_config_map.flux_kube_config.metadata.0.name
          }
        }

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
          name  = "flux"
          image = "docker.io/fluxcd/flux:${var.flux_version}"
          args = concat([
          "--log-format=fmt", 
          "--ssh-keygen-dir=/var/fluxd/keygen", 
          "--ssh-keygen-format=RFC4716", 
          "--k8s-secret-name=${kubernetes_secret.flux_git_deploy.metadata.0.name}", 
          "--memcached-hostname=flux-memcached", 
          "--sync-state=git", 
          "--memcached-service=", 
          "--git-url=${var.git_url}", 
          "--git-branch=${var.git_branch}", 
          "--git-path=${var.git_path}", 
          "--git-readonly=false", 
          "--git-user=Weave Flux", 
          "--git-email=support@weave.works", 
          "--git-verify-signatures=false", 
          "--git-set-author=false", 
          "--git-poll-interval=1m", 
          "--git-timeout=20s", 
          "--sync-interval=5m", 
          "--git-ci-skip=false", 
          "--automation-interval=1m", 
          "--registry-rps=200", 
          "--registry-burst=125", 
          "--registry-trace=false"
          ], var.flux_extra_arguments)

          port {
            name           = "http"
            container_port = 3030
            protocol       = "TCP"
          }

          env {
            name  = "KUBECONFIG"
            value = "/root/.kubectl/config"
          }

          resources {
            requests {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          volume_mount {
            name       = "kubedir"
            mount_path = "/root/.kubectl"
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

        service_account_name = "flux"
      }
    }
  }
}

resource "kubernetes_deployment" "flux_memcached" {
  metadata {
    name      = "flux-memcached"
    namespace = kubernetes_namespace.flux.metadata.0.name

    labels = {
      app = "flux-memcached"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "flux-memcached"
      }
    }

    template {
      metadata {
        labels = {
          app = "flux-memcached"
        }
      }

      spec {
        container {
          name  = "memcached"
          image = "memcached:${var.memcached_version}"
          args  = ["-m 512", "-p 11211", "-I 5m"]

          port {
            name           = "memcached"
            container_port = 11211
          }

          resources {
            requests {
              cpu    = "50m"
              memory = "64Mi"
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

