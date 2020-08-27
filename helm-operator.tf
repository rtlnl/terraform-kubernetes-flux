
data "template_file" "crds" {
  template = file("${path.module}/templates/crds.yaml")
}

resource "null_resource" "crds" {

  triggers = {
    manifest_sha1 = sha1("${data.template_file.crds.rendered}")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f - <<'EOF'\n${data.template_file.crds.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ${path.module}/templates/crds.yaml"
  }
}

resource "kubernetes_service_account" "helm_operator" {
  count = var.install_helm_operator ? 1 : 0
  metadata {
    name      = var.helm_operator_name
    namespace = var.namespace
    labels    = local.helm_operator_labels
  }
}

resource "kubernetes_config_map" "helm_operator_kube_config" {
  count = var.install_helm_operator ? 1 : 0
  metadata {
    name      = "${var.helm_operator_name}-kube-config"
    namespace = var.namespace
  }

  data = {
    config = local.config
  }
}

resource "kubernetes_cluster_role" "helm_operator" {
  count = var.install_helm_operator ? 1 : 0
  metadata {
    name   = var.helm_operator_name
    labels = local.helm_operator_labels
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
  count = var.install_helm_operator ? 1 : 0
  metadata {
    name   = var.helm_operator_name
    labels = local.helm_operator_labels
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
  count = var.install_helm_operator ? 1 : 0
  metadata {
    name      = var.helm_operator_name
    namespace = var.namespace
    labels    = local.helm_operator_labels
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
  count      = var.install_helm_operator ? 1 : 0
  depends_on = [null_resource.crds]
  metadata {
    name      = var.helm_operator_name
    namespace = var.namespace
    labels    = local.helm_operator_labels
  }

  spec {
    replicas = var.helm_operator_replicas

    selector {
      match_labels = local.helm_operator_labels
    }

    template {
      metadata {
        labels = local.helm_operator_labels
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
          args  = var.helm_operator_arguments

          port {
            name           = "http"
            container_port = 3030
          }

          resources {
            requests {
              cpu    = var.helm_operator_resources["cpu"]
              memory = var.helm_operator_resources["memory"]
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

        service_account_name = var.helm_operator_name
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

