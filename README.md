# Terraform_CloudFront
wordpress 環境を構築し CloudFront の behaviors で仮の静的サイト(index.html)のみS3にルーティングする Terraform です。

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
