{
    "aws_access_key_id": {},
    "aws_instance_profile": {},
    "aws_secret_access_key": {},
    "azure_account_key": {},
    "azure_account_name": {},
    "azure_container": {},
    "azure_endpoint": {},
    "ca_certs": {},
    "capacity_concurrency": {
        "value": "10"
    },
    "disk_path": {},
    "enc_password": {
        "value": "${enc_password}"
    },
    "extern_vault_addr": {},
    "extern_vault_enable": {
        "value": "0"
    },
    "extern_vault_path": {},
    "extern_vault_role_id": {},
    "extern_vault_secret_id": {},
    "extern_vault_token_renew": {},
    "extra_no_proxy": {},
    "hostname": {
        "value": "${hostname}"
    },
    "installation_type": %{ if installation_type == "demo" }{
        "value": "poc"
    }%{ else }
       {"value": "${installation_type}"}
    %{ endif },
    "placement": {
        "value": "placement_s3"
    },
    "postgres_url": {
        "value": "REPLACE WITH YOUR POSTGRE URL - EXAMPLE: postgresql://postgres:password@dbserver.customer.com:5432/dbname?sslmode=disable"
    },
    "production_type": %{ if production_type != "" }{
        "value": "${production_type}"
    }%{ else }{}%{ endif },
    "s3_bucket": {
        "value": "REPLACE WITH YOUR S3 BUCKET NAME"
    },
    "s3_region": {
        "value": "REPLACE WITH THE REGION OF YOUR S3 BUCKET. EXAMPLE: us-east-1"
    },
    "s3_sse": {},
    "s3_sse_kms_key_id": {},
    "vault_path": {
        "value": "/var/lib/tfe-vault"
    },
    "vault_store_snapshot": {
        "value": "1"
    }
}
