init:
	terraform init -backend-config="bucket=${TF_VAR_remote_backend}"

fmt:
	terraform fmt -recursive -diff ../

plan: fmt
	terraform plan

apply: fmt
	terraform apply
