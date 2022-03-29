# Test <!-- omit in toc -->

The test are based on the usage of the Vagrant file contained in this folder.

- [Getting started](#getting-started)
	- [Running Vagrant](#running-vagrant)
	- [Running terraform](#running-terraform)
		- [defaults](#defaults)
## Getting started

You'll need
- a local terraform client (>= 0.14.1)
- Vagrant installed [https://www.vagrantup.com/](https://www.vagrantup.com/)

review the ./deployment-scenerio/main.tf for the variables being used

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

Once you run `vagrant up NAME` check the log messages, RHEL and CENTOS need a `vagrant reload` to manage SELINUX.

### Running terraform

The sub folders under `./tests` represent deployment scenarios once you've run `vagrant up` as the obove instructions travers into the desired scenario, alternatively copy a scenario and tweak for your use case.

```shell
.
├── defaults
│   ├── example.auto.tfvars
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── online-demo-mode
    ├── example.auto.tfvars
    ├── main.tf
    ├── outputs.tf
    └── variables.tf

```

#### defaults

The `defaults` scenario is a default install of Replicated the orchestrator used to deploy Terraform, once the terraform code as executed you will see a url as an out put of Terraform and when opened in a browser the deployment will be finishing. This scenario allows you to manually configure and deploy Terraform.

review the variables are set in `./defaults/example.auto.tfvars` based on `vagrant up centos7` adjust as required, or copy the folder and update for your scenario.

```bash

❯ cat tests/defaults/example.auto.tfvars
private-address        = "192.168.56.1"
public-address         = "127.0.0.1"
connection_private_key = "../.vagrant/machines/centos7/virtualbox/private_key"
verbose                = true

```

```bash
❯ cat ./defaults/main.tf
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
  public-address         = var.public-address
  private-address        = var.private-address
}
```

Once the terraform as completed an apply run, you should see two (2) resources

```bash

❯ tf apply -var-file=example.auto.tfvars

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.tfe.null_resource.replicated_default[0] will be created
  + resource "null_resource" "replicated_default" {
      + id = (known after apply)
    }

  # module.tfe.null_resource.tfe_install_deploy[0] will be created
  + resource "null_resource" "tfe_install_deploy" {
      + id = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + tfe_replicated_console_url = "https://localhost:8800"
...

```

From here you follow <https://www.terraform.io/enterprise/install/interactive/installer> to complete the installation.
