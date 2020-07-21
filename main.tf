module "flux" {
  source = "./module"

  flux_extra_arguments = ["--registry-include-image=docker-registry.rtl-di.nl/*", "--sync-garbage-collection=true"]
  git_url = "git@github.com:nielstenboom/flux"
  helm_operator = false
}