# TFE onPrem
This Terraform module accelerator deploys TFE onPrem whether virtualized (VMware) or on physical `tin` servers in what is referred to as a `Standalone Deployment`.

 There are a number of different _deployment scenarios_ supported; see the [Examples](###Examples) section for further details supporting the various [Operational Modes](https://www.terraform.io/docs/enterprise/before-installing/index.html#operational-mode-decision)
 - TODO External Service
 - TODO Mounted Disc
 - TODO demo
  and Deployment

 The module code should be reviewed, potentially tweaked/customized, and **tested in a non-production environment**.
<p>&nbsp;</p>


## Prerequisites
- Terraform >= 0.14 installed on clients/workstations

TODO
<p>&nbsp;</p>


## Getting Started

You should review the [Terraform Enterprise Pre-Install Checklist](https://www.terraform.io/docs/enterprise/before-installing/index.html) before you start as this identifies pre-requisites and service decisions, that may be required before you begin.

A good place to start is with one of the [examples](./examples/README.md) which in turn will link to a _deployment scenario_ nested within the [tests](./tests) directory. The deployment scenarios contain actual Terraform code that can be referenced and deployed after populating a `terraform.tfvars`.
The "happy path" scenario that is probably the quickest and easiest to deploy and manage can be found [here](./tests/TODO). The input variable default values of the module favor this scenario.

<p>&nbsp;</p>


## Usage

### Examples
See the [examples](./examples/README.md) section for detailed information on _deployment scenarios_ this module accelerator supports.
<p>&nbsp;</p>

### Installation Method
Both **online** and **airgap** installation methods are supported by this module.

For **online**, specify a value for `tfe_release_sequence` and omit `airgap_install`, `replicated_bundle_path`, and `tfe_airgap_bundle_path`. For example:
```hcl
tfe_release_sequence = 534
```

For **airgap**, specify values for `airgap_install`, `replicated_bundle_path`, and `tfe_airgap_bundle_path`; and omit `tfe_release_sequence`. For example:
```hcl
airgap_install         = true
replicated_bundle_path = "s3://my-tfe-bootstrap-bucket/replicated.tar.gz"
tfe_airgap_bundle_path = "s3://my-tfe-bootstrap-bucket/tfe-534.airgap"
```

Note: if `airgap_install = true`, the templated install shell script assumes Linux package repositories cannot be reached. So, the server or image specified must contain the following software dependencies:
- unzip
- jq
- awscli
- docker (version 19.03.8 recommended)

_If you are deploying into an airgapped environment but your templates or servers can reach a Linux package repository, then modify the `install_dependencies()` function within the `./templates/tfe_user_data.sh.tpl` file._
<p>&nbsp;</p>

### Load Balancing

TODO
<p>&nbsp;</p>


### Secrets Management

TODO
<p>&nbsp;</p>

#### Install Secrets
Create a single secret with two key/value pairs, naming the keys exactly as follows:
  - `console_password`
  - `enc_password`


- **Certificate** -
TODO
<p>&nbsp;</p>

- **Private Key** -
TODO
<p>&nbsp;</p>

- **Custom CA bundle**
TODO
<p>&nbsp;</p>


An example command to help format the string before storing your custom CA bundle as a secret
```
sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' ./my-custom-ca-bundle.pem
```
<p>&nbsp;</p>

### Active-Active

TODO
<p>&nbsp;</p>


### Database

TODO
<p>&nbsp;</p>


### Alternative Terraform Build Worker (TBW) Image
The module supports running a custom Terraform Build Worker container image. The only supported container registry at this time (without requiring additional tweaks to the module code) is AWS Elastic Container Registry (ECR). In order to enable this functionality, specify the following input variables:
```hcl
tbw_image            = "custom_image"
custom_tbw_ecr_repo  = "<my-ecr-repo-name>"
custom_tbw_image_tag = "<my-image-tag>" (e.g. `v1` or `latest`)
```

Pushing the docker image up to the ECR repository becomes an additional module prereq when leveraging this functionality.
<p>&nbsp;</p>


## Post Deploy

### Logging In

TODO
<p>&nbsp;</p>



## Troubleshooting

TODO
<p>&nbsp;</p>



## Providers

| Name | Version |
|------|---------|
| TODO: |  |
| random | `3.1.0` |
| template | `2.2.0` |


## Inputs

TODO
<p>&nbsp;</p>
