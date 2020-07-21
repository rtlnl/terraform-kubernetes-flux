variable "namespace" {
  type        = string
  description = "Name of namespace where module should be installed"
  default     = "flux"
}

variable "helm_operator" {
  type = string
  description = "Whether the helm operator should be installed next to Flux, if set to true, don't forget to manually apply the CRD, otherwise it will not work"
}

variable "helm_operator_name" {
  type = string
  description = "Name of the helm operator resources"
  default = "helm-operator" 
}

variable "helm_operator_arguments" {
  type = list(string)
  description = "Command line arguments supplied to the helm operator, check out https://docs.fluxcd.io/projects/helm-operator/en/stable/references/operator/"
  default = [
    "--enabled-helm-versions=v3", 
    "--log-format=fmt", 
    "--git-timeout=20s", 
    "--git-poll-interval=5m", 
    "--charts-sync-interval=3m", 
    "--status-update-interval=30s", 
    "--update-chart-deps=true", 
    "--log-release-diffs=false", 
    "--workers=4", 
    "--tiller-namespace=kube-system"
  ]
}

variable "helm_operator_version" {
  type = string
  description = "SemVer Version of the helm operator"
  default = "1.1.0"
}

variable "flux_version" {
  type = string
  description  = "SemVer version of Flux"
  default = "1.20.0"
}

variable "flux_extra_arguments" {
  type = list(string)
  description = "Extra arguments supplied to the flux container, for reference check the following: https://docs.fluxcd.io/en/latest/references/daemon/"
  default = []
}

variable "git_url" {
  type = string
  description = "Github repository that should be monitored by Flux"
}

variable "git_branch" {
  type = string
  description =  "Git branch that flux should monitor"
  default = "master"
}

variable "git_path" {
  type = string
  description = "Git path that flux should monitor"
  default = ""
}

variable "memcached_version" {
  type = string
  description = "SemVer Version of memcached"
  default = "1.5.20"
}

