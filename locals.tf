locals {

    helm_operator = "helm-operator"
    helm_operator_labels = {
      app = "helm-operator"
    }
    
    config = "${file("${path.module}/templates/config.yaml")}"
}