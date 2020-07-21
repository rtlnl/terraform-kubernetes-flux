module "flux" {
  source = "./module"

  git_url = "git@github.com:myname/repo"
  helm_operator = false
}