# Terraform-dev
CloudFront の behaviors で仮の静的サイト(index.html)のみS3にルーティングする Terraform です。

Terraform that builds a wordpress environment and distributes only the hypothetical image display URL to s3 with cloudfront behaviors.

※ tfvars,main.tf はご自身の環境に合わせてください。  
※ db_instance の情報はハードコーディングされています。別途 secrets manager、parameter store を使用してください。  

terraform 基本コマンド

```
terraform init
```

```
terraform plan
```

```
terraform apply
```
```
terraform destroy
```