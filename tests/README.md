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
