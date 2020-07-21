module "flux" {
  source = "rtlnl/flux/aws"

  git_url = "git@github.com:myname/repo"
  # if set to true, also manually apply CRD as described in README
  helm_operator = false
}