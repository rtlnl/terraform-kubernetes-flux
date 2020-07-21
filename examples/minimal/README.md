## Example

Call the module like the following in your main.tf for a minimal installation of FluxCD!

```terraform
module "flux" {
  source = "rtlnl/flux/aws"

  git_url = "git@github.com:myname/repo"
  helm_operator = false
}
```