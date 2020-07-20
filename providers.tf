provider "kubernetes" {
#   config_context_auth_info = "ops"
  config_context_cluster   = "kind-kind"
  version = "~> 1.11"
}