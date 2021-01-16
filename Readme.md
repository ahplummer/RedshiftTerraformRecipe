# Instructions for Redshift

## Create .env file
```
#!/bin/bash
export TF_VAR_REDSHIFT_NAME=""
export TF_VAR_DB_NAME=""
export TF_VAR_REDSHIFT_USER=""
export TF_VAR_REDSHIFT_PASSWORD=""
export TF_VAR_REGION="us-east-1"
#openssl rand -hex 10
export TF_VAR_BUCKET_NAME=""
export TF_VAR_BUCKET_KEY=""
export TF_VAR_ENGAGEMENT=""
```
## S3 Setup for remote state

* Login to AWS CLI
```
rm  -rf ~/.aws/credentials
aws configure
```

* Create S3 bucket for TF State.
```
 aws s3api  create-bucket --bucket $TF_VAR_BUCKET_NAME --region $TF_VAR_REGION
```

## Init TF Backend

```
terraform init --backend-config "bucket=$TF_VAR_BUCKET_NAME" --backend-config "key=$TF_VAR_BUCKET_KEY" --backend-config "region=$TF_VAR_REGION"
```

## Execing TF
* Plan:
```
terraform plan
```
* Execute, taking note of the IP at the end.
```
terraform -auto-approve
```
