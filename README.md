# TFE on AWS
This Terraform module accelerator deploys TFE on AWS. There are a number of different _deployment scenarios_ supported; see the [Examples](###Examples) section for further details. The [Operational Mode](https://www.terraform.io/docs/enterprise/before-installing/index.html#operational-mode-decision) is _External Services_, both _online_ and _airgap_ installation methods are supported, and Active/Active is supported. Prior to deploying in production, the module code should be reviewed, potentially tweaked/customized, and **tested in a non-production environment**.
<p>&nbsp;</p>


## Prerequisites
- Terraform >= 0.14 installed on clients/workstations
- AWS account w/ the ability to deploy resources into via Terraform CLI
- S3 "bootstrap" bucket used to stage required files to automate TFE install:
  - TFE license file from Replicated (`.rli` file extension)
  - TFE airgap bundle (only if installation method is _airgap_)
  - `replicated.tar.gz` bundle (only if installation method is _airgap_)
- VPC w/ subnets (minimum of 2) in different Availability Zones
- TLS/SSL certificate in one of the following configurations:
  - Route53 Hosted Zone of the type **public** so ACM certificate validation works
  - Custom CA certificate files staged in AWS Secrets Manager
- TFE install secrets stored in AWS Secrets Manager or specified directly as input variables
- A mechanism for shell access to EC2 instance (SSH key pair, SSM, etc.)  
  
Note: a prereqs helper module exists [here](https://github.com/hashicorp/is-terraform-aws-tfe-standalone-prereqs).
<p>&nbsp;</p>


## Getting Started
A good place to start is with one of the [examples](./examples/README.md) which in turn will link to a _deployment scenario_ nested within the [tests](./tests) directory. The deployment scenarios contain actual Terraform code that can be referenced and deployed after populating a `terraform.tfvars`. The "happy path" scenario that is probably the quickest and easiest to deploy and manage can be found [here](./tests/alb-ext-r53-acm-ol/README.md). The input variable default values of the module favor this scenario.
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

Note: if `airgap_install = true`, the `user_data` (cloud-init) script assumes Linux package repositories cannot be reached. So, the AMI specified must contain the following software dependencies:
- unzip
- jq
- awscli
- docker (version 19.03.8 recommended)

_If you are deploying into an airgapped environment but your EC2 instances can reach a Linux package repository, then modify the `install_dependencies()` function within the `./templates/tfe_user_data.sh.tpl` file._
<p>&nbsp;</p>

### Load Balancing
This module supports both the AWS Application Load Balancer (ALB) and the Network Load Balancer (NLB) via the input variable `load_balancer_type`. The [examples](./examples/README.md) section contains more detail on how to choose based on the _deployment_scenario_, but in general here are the differences:

#### ALB
- Module default variable values favor the ALB deployment scenarios
- ALB is a layer 7 HTTPS load balancer and works really well when used in combination with Route53 and ACM
- Module will either create the TFE TLS/SSL certificate on the fly via ACM, or the certificate can be imported into ACM as a module prereq
- Input variable `tls_bootstrap_type` defaults to `self-signed` because the TFE TLS/SSL certificate will be terminated at the load balancer-level

#### NLB
- NLB is a layer 4 TCP load balancer that does TLS-passthrough in the supported deployment scenarios
- NLB is ideal for users who want to terminate TLS/SSL end-to-end at the instance-level rather than at the load balancer-level
- Input variable `tls_bootstrap_type` should be set to `server-path` because the TFE server certificate files must exist on the instance where TLS/SSL will be terminated
- Typically the TFE server certificate files are placed in AWS Secrets Manager as a module prereq (see [TLS/SSL-Certificates](####TLS/SSL-Certificates) within the [Secrets Management](###Secrets-Management) section)
- The subnet CIDR's must be in the `ingress_cidr_443_allow` so the NLB health checks can reach the instance(s) properly
- If the NLB is deployed onto private subnets and the `load_balancer_schema` is set to `internal`, then `hairpin_addressing` must be set to `true` because the NLB does not support loopback addressing
- If `hairpin_addressing` is `true` and a proxy is also in use, then the TFE FQDN (`tfe_hostname`) must be added to the `extra_no_proxy` input
<p>&nbsp;</p>

### Secrets Management
By default, this module expects the necessary secrets for the deployment to be stored in AWS Secrets Manager as a module prereq. Terraform will automatically grant the TFE IAM Instance Profile read access to the secrets based on the ARNs specified for the corresponding input variables detailed below. Then, when the EC2 instance boots and the cloud-init process executes, the secrets will automatically be retrieved from Secrets Manager via `awscli`.

#### Install Secrets
Create a single secret with two key/value pairs, naming the keys exactly as follows:
  - `console_password`
  - `enc_password`

Specify the ARN of the secret for the input variable `tfe_install_secrets_arn`. If it is not desirable to use AWS Secrets Manager for the _install secrets_, it is also possible to specify the secrets directly as variable values for the input variables `console_password` and `enc_password`.

#### TLS/SSL Certificates (optional)
These secrets are only necessary in deployment scenarios where `tls_bootstrap_type` is set to `server-path` (and typically the NLB is in use).

- **Certificate** - store this as a plaintext secret in Secrets Manager and specify the ARN for the input variable `tfe_cert_secret_arn`
- **Private Key** - store this as a base64-encoded plaintext secret in Secrets Manager and specify the ARN for the input variable `tfe_privkey_secret_arn`\
(_i.e._ `cat privkey.pem | base64 -w 0`)
- **Custom CA bundle** - store this as a plaintext secret, replace any new lines with `\n` because JSON does not support raw new line characters, and specify the ARN for the input variable `ca_bundle_secret_arn`

An example command to help format the string before storing your custom CA bundle as a secret for `ca_bundle_secret_arn`:
```
sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' ./my-custom-ca-bundle.pem
```
<p>&nbsp;</p>

### Active-Active
The module supports deploying TFE in the Active-Active architecture, including external Redis and multiple nodes within the Autoscaling Group. In order to enable Active-Active, specify the following input variables:
```hcl
enable_active_active = true
redis_subnet_ids     = ["subnet-00000000000000000", "subnet-11111111111111111", "subnet-22222222222222222"] # private subnet IDs
redis_password       = "MyTfeRedisPasswd123!" # optional password to enable transit encryption with Redis
```
<p>&nbsp;</p>

### Database
This module supports an Amazon RDS and AWS Aurora RDS for the database requirement of TFE. The variable `rds_is_aurora` controls which database type is created. By default this is set to `false` and an AWS RDS database will be deployed. This module supports the initial deployment of either database type, however it does not support migration between one or the other after deployment. If this variable is changed after TFE has been deployed the existing database will be deleted and a new one created, which will result in data loss.
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
After the Terraform run has completed successfully, give the EC2 instance around 7-12 minutes after it has finished initializing before launching a browser and attempting to login to TFE. First connect to the TFE Admin Console on port 8800 (`https://<tfe_hostname>:8800`) and authenticate using the value of `console_password`. From the Dashboard page, after verifying the application is started, click the **open** link underneath the **Stop Now** button to create the Initial Admin User and in turn the initial Organization.
<p>&nbsp;</p>


## Troubleshooting
To monitor the progress of the install (cloud-init process), SSH into the EC2 instance and run `journalctl -xu cloud-final -f` to tail the logs (or remove the `-f` if the cloud-init process has finished).  If the operating system is Ubuntu, logs can also be viewed via `tail -f /var/log/cloud-init-output.log`.
<p>&nbsp;</p>


## Providers

| Name | Version |
|------|---------|
| aws | `~> 3.33.0` |
| random | `3.1.0` |
| template | `2.2.0` |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| airgap\_install | Boolean for TFE installation method to be airgap. | `bool` | `false` | no |
| ami\_id | Custom AMI ID for TFE EC2 Launch Template. If specified, value of `os_distro` must coincide with this custom AMI OS distro. | `string` | `null` | no |
| asg\_health\_check\_grace\_period | The amount of time to wait for a new TFE instance to be healthy. If this threshold is breached, the ASG will terminate the instance and launch a new one. | `number` | `900` | no |
| asg\_instance\_count | Desired number of EC2 instances to run in Autoscaling Group. Leave at `1` unless Active/Active is enabled. | `number` | `1` | no |
| asg\_max\_size | Max number of EC2 instances to run in Autoscaling Group. Increase after Active/Active is enabled. | `number` | `1` | no |
| aurora\_rds\_availability\_zones | List of Availability Zones to spread Aurora DB cluster across. | `list(string)` | `null` | no |
| aurora\_rds\_engine\_mode | Aurora engine mode. | `string` | `"provisioned"` | no |
| aurora\_rds\_engine\_version | Engine version of Aurora PostgreSQL. | `number` | `12.4` | no |
| aurora\_rds\_global\_cluster\_id | Aurora Global Database cluster identifier. Intended to be used by Aurora DB Cluster instance in Secondary region. | `string` | `null` | no |
| aurora\_rds\_instance\_class | Instance class of Aurora PostgreSQL database. | `string` | `"db.r5.xlarge"` | no |
| aurora\_rds\_replica\_count | Amount of Aurora Replica instances to deploy within the Aurora DB cluster within the same region. | `number` | `1` | no |
| aurora\_rds\_replication\_source\_identifier | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica. Intended to be used by Aurora Replica in Secondary region. | `string` | `null` | no |
| aurora\_source\_region | Source region for Aurora Cross-Region Replication. Only specify for Secondary instance. | `string` | `null` | no |
| aws\_ssm\_enable | Boolean to attach the `AmazonSSMManagedInstanceCore` policy to the TFE role, allowing the SSM agent (if present) to function. | `bool` | `false` | no |
| bucket\_replication\_configuration | Map containing S3 Cross-Region Replication configuration. | `any` | `{}` | no |
| ca\_bundle\_secret\_arn | ARN of AWS Secrets Manager secret for private/custom CA bundles. New lines must be replaced by `<br>` character prior to storing as a plaintext secret. | `string` | `""` | no |
| capacity\_concurrency | Total concurrent Terraform Runs (Plans/Applies) allowed within TFE. | `string` | `"10"` | no |
| capacity\_memory | Maxium amount of memory (MB) that a Terraform Run (Plan/Apply) can consume within TFE. | `string` | `"512"` | no |
| common\_tags | Map of common tags for taggable AWS resources. | `map(string)` | `{}` | no |
| console\_password | Password to unlock TFE Admin Console accessible via port 8800. Specify `aws_secretsmanager` to retrieve from AWS Secrets Manager via `tfe_install_secrets_arn` input. | `string` | `"aws_secretsmanager"` | no |
| create\_tfe\_alias\_record | Boolean to create Route53 Alias Record for `tfe_hostname` resolving to Load Balancer DNS name. If `true`, `route53_hosted_zone_tfe` is also required. | `bool` | `true` | no |
| custom\_tbw\_ecr\_repo | Name of AWS Elastic Container Registry (ECR) Repository where custom Terraform Build Worker (tbw) image exists. Only specify if `tbw_image` is set to `custom_image`. | `string` | `""` | no |
| custom\_tbw\_image\_tag | Tag of custom Terraform Build Worker (tbw) image. Examples: `v1`, `latest`. Only specify if `tbw_image` is set to `custom_image`. | `string` | `"latest"` | no |
| destination\_bucket | Destination S3 Bucket for Cross-Region Replication configuration. Should exist in Secondary region. | `string` | `""` | no |
| ec2\_subnet\_ids | List of subnet IDs to use for the EC2 instance. Private subnets is the best practice. | `list(string)` | n/a | yes |
| enable\_active\_active | Boolean to enable TFE Active/Active and in turn deploy Redis cluster. | `bool` | `false` | no |
| enable\_metrics\_collection | Boolean to enable internal TFE metrics collection. | `bool` | `true` | no |
| enc\_password | Password to protect unseal key and root token of TFE embedded Vault. Specify `aws_secretsmanager` to retrieve from AWS Secrets Manager via `tfe_install_secrets_arn` input. | `string` | `"aws_secretsmanager"` | no |
| encrypt\_ebs | Boolean for encrypting the root block device of the TFE EC2 instance(s). | `bool` | `false` | no |
| extra\_no\_proxy | A comma-separated string of hostnames or IP addresses to add to the TFE no\_proxy list. Only specify if a value for `http_proxy` is also specified. | `string` | `""` | no |
| force\_tls | Boolean to require all internal TFE application traffic to use HTTPS by sending a 'Strict-Transport-Security' header value in responses, and marking cookies as secure. Only enable if `tls_bootstrap_type` is `server-path`. | `bool` | `false` | no |
| friendly\_name\_prefix | String value for friendly name prefix for AWS resource names. | `string` | n/a | yes |
| hairpin\_addressing | Boolean to enable TFE services to direct requests to the servers' internal IP address rather than the TFE hostname/FQDN. Only enable if `tls_bootstrap_type` is `server-path`. | `bool` | `false` | no |
| http\_proxy | Proxy address to configure for TFE to use for outbound connections/requests. | `string` | `""` | no |
| ingress\_cidr\_22\_allow | List of CIDR ranges to allow SSH ingress to TFE EC2 instance (i.e. bastion host IP, workstation IP, etc.). | `list(string)` | `[]` | no |
| ingress\_cidr\_443\_allow | List of CIDR ranges to allow ingress traffic on port 443 to TFE server or load balancer. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ingress\_cidr\_8800\_allow | List of CIDR ranges to allow TFE Replicated admin console (port 8800) traffic ingress to TFE server or load balancer. | `list(string)` | `null` | no |
| instance\_size | EC2 instance type for TFE Launch Template. | `string` | `"m5.xlarge"` | no |
| is\_secondary | Boolean indicating whether TFE instance deployment is for Primary region or Secondary region. | `bool` | `false` | no |
| kms\_key\_arn | ARN of KMS key to encrypt TFE RDS, S3, EBS, and Redis resources. | `string` | `""` | no |
| lb\_subnet\_ids | List of subnet IDs to use for the load balancer. If LB is external, these should be public subnets. | `list(string)` | n/a | yes |
| load\_balancer\_schema | Load balancer exposure. Specify `external` if load balancer is to be public/external-facing, or `internal` if load balancer is to be private/internal-facing. | `string` | `"external"` | no |
| load\_balancer\_type | String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb). | `string` | `"alb"` | no |
| os\_distro | Linux OS distribution for TFE EC2 instance. Choose from `amzn2`, `ubuntu`, `rhel`, `centos`. | `string` | `"amzn2"` | no |
| rds\_allocated\_storage | Size capacity (GB) of RDS PostgreSQL database. | `string` | `"50"` | no |
| rds\_allow\_major\_version\_upgrade | Boolean to allow major version upgrades of the database. | `bool` | `false` | no |
| rds\_auto\_minor\_version\_upgrade | Boolean to enable the automatic upgrading of new minor versions during the specified `rds_preferred_maintenance_window`. | `bool` | `true` | no |
| rds\_backup\_retention\_period | The number of days to retain backups for. Must be between 0 and 35. Must be greater than 0 if the database is used as a source for a Read Replica. | `number` | `35` | no |
| rds\_copy\_tags\_to\_snapshot | Boolean to enable copying tags to RDS snapshot. | `bool` | `true` | no |
| rds\_database\_name | Name of database. | `string` | `"tfe"` | no |
| rds\_deletion\_protection | Boolean to proctect the database from being deleted. The database cannot be deleted when `true`. | `bool` | `false` | no |
| rds\_engine\_version | Version of RDS PostgreSQL. | `number` | `12.6` | no |
| rds\_instance\_class | Instance class of RDS PostgreSQL database. | `string` | `"db.m5.xlarge"` | no |
| rds\_is\_aurora | Boolean for deploying global Amazon Aurora PostgreSQL instead of Amazon RDS for PostgreSQL | `bool` | `false` | no |
| rds\_multi\_az | Boolean to create a standby instance in a different AZ than the primary and enable HA. | `bool` | `true` | no |
| rds\_password | Password for RDS master DB user. | `string` | n/a | yes |
| rds\_preferred\_backup\_window | Daily time range (UTC) for RDS backup to occur. Must not overlap with `rds_preferred_maintenance_window` if specified. | `string` | `"04:00-04:30"` | no |
| rds\_preferred\_maintenance\_window | Window (UTC) to perform RDS database maintenance. Must not overlap with `rds_preferred_backup_window` if specified. | `string` | `"Sun:08:00-Sun:09:00"` | no |
| rds\_skip\_final\_snapshot | Boolean for RDS to take a final snapshot. | `bool` | `false` | no |
| rds\_subnet\_ids | List of subnet IDs to use for RDS Database Subnet Group. Private subnets is the best practice. | `list(string)` | n/a | yes |
| rds\_username | Username for the master DB user. | `string` | `"tfe"` | no |
| redis\_at\_rest\_encryption\_enabled | Boolean to enable encryption at rest on Redis cluster. A `kms_key_arn` is required when set to `true`. | `bool` | `false` | no |
| redis\_engine\_version | Redis version number | `string` | `"5.0.6"` | no |
| redis\_multi\_az\_enabled | Boolean for deploying Redis nodes in multiple Availability Zones and enabling automatic failover. | `bool` | `true` | no |
| redis\_node\_type | Type of Redis node from a compute, memory, and network throughput standpoint. | `string` | `"cache.m4.large"` | no |
| redis\_parameter\_group\_name | Name of parameter group to associate with Redis cluster. | `string` | `"default.redis5.0"` | no |
| redis\_password | Password (auth token) used to enable transit encryption (TLS) with Redis. | `string` | `""` | no |
| redis\_port | Port number the Redis nodes will accept connections on. | `number` | `6379` | no |
| redis\_replica\_count | Number of replica nodes in Redis cluster. | `number` | `1` | no |
| redis\_subnet\_ids | List of subnet IDs to use for Redis cluster subnet group. | `list(string)` | `null` | no |
| remove\_import\_settings\_from | Replicated setting to automatically remove the `/etc/tfe-settings.json` file (referred to as `ImportSettingsFrom` by Replicated) after installation. | `bool` | `false` | no |
| replicated\_bundle\_path | Full path of Replicated bundle (`replicated.tar.gz`) in S3 bucket. A local filepath is not supported because the Replicated bundle is too large for user\_data. Only specify if `airgap_install` is `true`. Should start with `s3://`. | `string` | `""` | no |
| restrict\_worker\_metadata\_access | Boolean to block Terraform build worker containers from being able to access the EC2 instance metadata endpoint. | `bool` | `false` | no |
| route53\_hosted\_zone\_acm | Route53 Hosted Zone name to create ACM Certificate Validation CNAME record in. Required if `tls_certificate_arn` is not specified. | `string` | `null` | no |
| route53\_hosted\_zone\_tfe | Route53 Hosted Zone name to create `tfe_hostname` Alias record in. Required if `create_tfe_alias_record` is `true`. | `string` | `null` | no |
| ssh\_key\_pair | Name of existing SSH key pair to attach to TFE EC2 instance. | `string` | `""` | no |
| syslog\_endpoint | Syslog endpoint for Logspout to forward TFE logs to. | `string` | `""` | no |
| tbw\_image | Terraform Build Worker container image to use. Set this to `custom_image` to use alternative container image. | `string` | `"default_image"` | no |
| tfe\_airgap\_bundle\_path | Full path of TFE airgap bundle in S3 bucket. A local filepath is not supported because the airgap bundle is too large for user\_data. Only specify if `airgap_install` is `true`. Should start with `s3://`. | `string` | `""` | no |
| tfe\_bootstrap\_bucket | Name of existing S3 bucket containing prerequisite files for TFE automated install. Typically would contain TFE license file and airgap files if `airgap_install` is `true`. | `string` | `""` | no |
| tfe\_cert\_secret\_arn | ARN of AWS Secrets Manager secret for TFE server certificate in PEM format. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored. | `string` | `""` | no |
| tfe\_hosted\_zone\_is\_private | Boolean indicating if `route53_hosted_zone_tfe` is a private zone. | `bool` | `false` | no |
| tfe\_hostname | Hostname/FQDN of TFE instance. This name should resolve to the load balancer DNS name and will be how users and systems access TFE. | `string` | n/a | yes |
| tfe\_install\_secrets\_arn | ARN of AWS Secrets Manager secret metadata for TFE install secrets. If specified, secret must contain key/value pairs for `console_password`, and `enc_password` | `string` | `""` | no |
| tfe\_license\_filepath | Full filepath of TFE license file (`.rli` file extension). A local filepath or S3 is supported. If s3, the path should start with `s3://`. | `string` | n/a | yes |
| tfe\_privkey\_secret\_arn | ARN of AWS Secrets Manager secret for TFE private key in PEM format and base64 encoded. Required if `tls_bootstrap_type` is `server-path`; otherwise ignored. | `string` | `""` | no |
| tfe\_release\_sequence | TFE application version release sequence number within Replicated. Ignored if `airgap_install` is `true`. | `number` | `0` | no |
| tfe\_tls\_certificate\_arn | ARN of TFE certificate imported in ACM to be used for Application Load Balancer HTTPS listeners. Required if `route53_hosted_zone_acm` is not specified. | `string` | `null` | no |
| tls\_bootstrap\_type | Defines where to terminate TLS/SSL. Set to `self-signed` to terminate at the load balancer, or `server-path` to terminate at the instance-level. | `string` | `"self-signed"` | no |
| vpc\_id | VPC ID that TFE will be deployed into. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| admin\_console\_url | URL of TFE (Replicated) Admin Console based on `tfe_hostname` input. |
| aurora\_aws\_rds\_cluster\_endpoint | Aurora DB cluster instance endpoint. |
| aurora\_rds\_cluster\_arn | ARN of Aurora DB cluster. |
| aurora\_rds\_cluster\_members | List of instances that are part of this Aurora DB Cluster. |
| aurora\_rds\_global\_cluster\_id | Aurora Global Database cluster identifier. |
| aws\_db\_instance\_arn | ARN of RDS DB instance. |
| aws\_db\_instance\_endpoint | RDS DB instance endpoint. |
| lb\_dns\_name | DNS name of the Load Balancer. |
| s3\_bucket\_arn | ARN of TFE S3 bucket. |
| s3\_bucket\_name | Name of TFE S3 bucket. |
| s3\_crr\_iam\_role\_arn | ARN of S3 Cross-Region Replication IAM Role. |
| url | URL of TFE application based on `tfe_hostname` input. |
