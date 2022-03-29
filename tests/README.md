# Test

The test are based on the usage of the Vagrant file contained in this folder.

## Getting started

You'll need
- a local terraform client (>= 0.14.1)
- Vagrant installed [https://www.vagrantup.com/](https://www.vagrantup.com/)

review the ./testname/main.tf for the variables being used

### Running Vagrant

run `vagrant status` to see the available OS' then launch one by name i.e`vagrant up centos07`

```shell
vagrant status
Current machine states:

rhel7                     not created (virtualbox)
centos7                   not created (virtualbox)
ubuntu20                  not created (virtualbox)
amzn2                     not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

```

### Running terraform

The sub folders under `./tests` represent deployment scenarios once you've run `vagrant up` as the obove instructions travers into the desired scenario, alternatively copy a scenario and tweak for your use case.

```shell
.
├── defaults
│   ├── example.auto.tfvars
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── demo
    ├── example.auto.tfvars
    ├── main.tf
    ├── outputs.tf
    └── variables.tf

```

#### default

The `default` scenario is a default install of Replicated the orchetrator used to deploy Terraform, once the terraform code as executed you will see a url as an out put of Terrafrom and when opened in a browser the deployment will be finishing. This scenerio allows you to manually configure and deploy Terraform.

```shell
❯ cat main.tf
module "tfe" {
  source             = "../.."
  tfe_hostname       = "localhost"
  tfe_fqdn           = "localhost"
  physical           = true
  replicated_install = true
  // run `vagrant up` from the `terraform-onprem-tfe/tests/physical-demo` folder
  connection_user        = "vagrant"
  connection_port        = 2222
  connection_private_key = var.connection_private_key
  verbose                = var.verbose
}
```
