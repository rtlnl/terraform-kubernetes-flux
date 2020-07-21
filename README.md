## Flux Terraform Module

This module will let you install Flux CD (https://fluxcd.io/) on a Kubernetes cluster.

Take a look at the [example](examples/minimal/main.tf) for a minimal example on how to call the module in your `main.tf` file.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| kubernetes | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| flux\_arguments | Arguments supplied to the flux container, for reference check the following: https://docs.fluxcd.io/en/latest/references/daemon/ | `list(string)` | <pre>[<br>  "--log-format=fmt",<br>  "--ssh-keygen-dir=/var/fluxd/keygen",<br>  "--ssh-keygen-format=RFC4716",<br>  "--git-readonly=false",<br>  "--git-user=Weave Flux",<br>  "--git-email=support@weave.works",<br>  "--git-verify-signatures=false",<br>  "--git-set-author=false",<br>  "--git-poll-interval=1m",<br>  "--git-timeout=20s",<br>  "--sync-interval=5m",<br>  "--git-ci-skip=false",<br>  "--automation-interval=1m",<br>  "--registry-rps=200",<br>  "--registry-burst=125",<br>  "--registry-trace=false",<br>  "--sync-state=git",<br>  "--memcached-service=",<br>  "--memcached-hostname=flux-memcached"<br>]</pre> | no |
| flux\_memcached\_hostname | Hostname of memcached, change this if you want to use your own version of memcached | `string` | `"flux-memcached"` | no |
| flux\_replicas | How many instances of flux should be created | `number` | `1` | no |
| flux\_resources | Resources to give to the flux deployment | `map(string)` | <pre>{<br>  "cpu": "50m",<br>  "memory": "64Mi"<br>}</pre> | no |
| flux\_version | SemVer version of Flux | `string` | `"1.20.0"` | no |
| git\_branch | Git branch that flux should monitor | `string` | `"master"` | no |
| git\_path | Git path that flux should monitor | `string` | `""` | no |
| git\_url | Github repository that should be monitored by Flux | `string` | n/a | yes |
| helm\_operator | Whether the helm operator should be installed next to Flux, will only work with Helm v3 by default, change the helm\_operator\_arguments to make it support v2. | `bool` | n/a | yes |
| helm\_operator\_arguments | Command line arguments supplied to the helm operator, check out https://docs.fluxcd.io/projects/helm-operator/en/stable/references/operator/ | `list(string)` | <pre>[<br>  "--enabled-helm-versions=v3",<br>  "--log-format=fmt",<br>  "--git-timeout=20s",<br>  "--git-poll-interval=5m",<br>  "--charts-sync-interval=3m",<br>  "--status-update-interval=30s",<br>  "--update-chart-deps=true",<br>  "--log-release-diffs=false",<br>  "--workers=4"<br>]</pre> | no |
| helm\_operator\_name | Name of the helm operator resources | `string` | `"helm-operator"` | no |
| helm\_operator\_replicas | How many instances of the helm operator should be created | `number` | `1` | no |
| helm\_operator\_resources | Resources to give to the helm operator deployment | `map(string)` | <pre>{<br>  "cpu": "50m",<br>  "memory": "64Mi"<br>}</pre> | no |
| helm\_operator\_version | SemVer Version of the helm operator | `string` | `"1.1.0"` | no |
| memcached | Whether to create an instance of Memcached alongside the Flux deployment | `bool` | `true` | no |
| memcached\_arguments | Command line arguments supplied to memcached | `list(string)` | <pre>[<br>  "-m 512",<br>  "-p 11211",<br>  "-I 5m"<br>]</pre> | no |
| memcached\_replicas | How many instances of memcached should be created | `number` | `1` | no |
| memcached\_resources | Resources to give to memcached deployment | `map(string)` | <pre>{<br>  "cpu": "50m",<br>  "memory": "64Mi"<br>}</pre> | no |
| memcached\_version | SemVer Version of memcached | `string` | `"1.5.20"` | no |
| namespace | Name of namespace where module should be installed | `string` | `"flux"` | no |

## Outputs

No output.
