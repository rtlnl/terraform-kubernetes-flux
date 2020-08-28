locals {

  flux = "flux"
  flux_labels = {
    app = "flux"
  }

  helm_operator = "helm-operator"
  helm_operator_labels = {
    app = "helm-operator"
  }

  memcached = "flux-memcached"
  memcached_labels = {
    app = "flux-memcached"
  }

  config = file("${path.module}/templates/config.yaml")
}
