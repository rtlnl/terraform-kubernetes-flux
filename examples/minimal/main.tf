module "flux" {
  source = "rtlnl/flux/aws"

  git_url = "git@github.com:myname/repo"
  helm_operator = false
}