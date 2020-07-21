variable "namespace" {
  type        = string
  description = "Name of namespace where module should be installed"
  default     = "flux"
}

variable "git_url" {
  type        = string
  description = "Github repository that should be monitored by Flux"
}

variable "git_branch" {
  type        = string
  description = "Git branch that flux should monitor"
  default     = "master"
}

variable "git_path" {
  type        = string
  description = "Git path that flux should monitor"
  default     = ""
}

variable "flux_version" {
  type        = string
  description = "SemVer version of Flux"
  default     = "1.20.0"
}

variable "flux_memcached_hostname" {
  type        = string
  description = "Hostname of memcached, change this if you want to use your own version of memcached"
  default     = "flux-memcached"
}

variable "flux_arguments" {
  type        = list(string)
  description = "Arguments supplied to the flux container, for reference check the following: https://docs.fluxcd.io/en/latest/references/daemon/"
  default = [
    "--log-format=fmt",
    "--ssh-keygen-dir=/var/fluxd/keygen",
    "--ssh-keygen-format=RFC4716",
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
    "--registry-trace=false",
    "--sync-state=git",
    "--memcached-service=",
    "--memcached-hostname=flux-memcached",
  ]
}

variable "flux_resources" {
  type        = map(string)
  description = "Resources to give to the flux deployment"
  default = {
    cpu    = "50m"
    memory = "64Mi"
  }
}

variable "flux_replicas" {
  type        = number
  description = "How many instances of flux should be created"
  default     = 1
}

variable "helm_operator" {
  type        = bool
  description = "Whether the helm operator should be installed next to Flux, will only work with Helm v3 by default, change the helm_operator_arguments to make it support v2."
}

variable "helm_operator_name" {
  type        = string
  description = "Name of the helm operator resources"
  default     = "helm-operator"
}

variable "helm_operator_arguments" {
  type        = list(string)
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
    "--workers=4"
  ]
}

variable "helm_operator_version" {
  type        = string
  description = "SemVer Version of the helm operator"
  default     = "1.1.0"
}

variable "helm_operator_resources" {
  type        = map(string)
  description = "Resources to give to the helm operator deployment"
  default = {
    cpu    = "50m"
    memory = "64Mi"
  }
}

variable "helm_operator_replicas" {
  type        = number
  description = "How many instances of the helm operator should be created"
  default     = 1
}

variable "memcached" {
  type        = bool
  description = "Whether to create an instance of Memcached alongside the Flux deployment"
  default     = true
}

variable "memcached_version" {
  type        = string
  description = "SemVer Version of memcached"
  default     = "1.5.20"
}

variable "memcached_arguments" {
  type        = list(string)
  description = "Command line arguments supplied to memcached"
  default = [
    "-m 512",
    "-p 11211",
    "-I 5m"
  ]
}

variable "memcached_resources" {
  type        = map(string)
  description = "Resources to give to memcached deployment"
  default = {
    cpu    = "50m"
    memory = "64Mi"
  }
}

variable "memcached_replicas" {
  type        = number
  description = "How many instances of memcached should be created"
  default     = 1
}
