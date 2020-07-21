## Flux Terraform Module

This module will let you install Flux CD (https://fluxcd.io/) on a Kubernetes cluster.

If you enable the helm operator, also manually apply the HelmRelease CRD, otherwise the helm operator will not work.
```
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| kubernetes | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| flux\_extra\_arguments | Extra arguments supplied to the flux container, for reference check the following: https://docs.fluxcd.io/en/latest/references/daemon/ | `list(string)` | `[]` | no |
| flux\_version | SemVer version of Flux | `string` | `"1.20.0"` | no |
| git\_branch | Git branch that flux should monitor | `string` | `"master"` | no |
| git\_path | Git path that flux should monitor | `string` | `""` | no |
| git\_url | Github repository that should be monitored by Flux | `string` | n/a | yes |
| helm\_operator | Whether the helm operator should be installed next to Flux, if set to true, don't forget to manually apply the CRD, otherwise it will not work | `string` | n/a | yes |
| helm\_operator\_version | SemVer Version of the helm operator | `string` | `"1.1.0"` | no |
| memcached\_version | SemVer Version of memcached | `string` | `"1.5.20"` | no |
| namespace | Name of namespace where module should be installed | `string` | `"flux"` | no |

## Outputs

No output.
