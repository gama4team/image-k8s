cd ../2-terraform-ami/

/usr/bin/terraform init
/usr/bin/terraform fmt
TF_VAR_versao="1.0" /usr/bin/terraform apply -auto-approve
/usr/bin/terraform output
