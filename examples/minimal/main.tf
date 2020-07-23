module "flux" {
  source = "rtlnl/flux/aws"

  git_url               = "git@github.com:myname/repo"
  install_helm_operator = false
}