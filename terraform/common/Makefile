init:
	terraform init -backend-config="bucket=${REMOTE_BACKEND}"

fmt:
	terraform fmt -recursive -diff
	terraform fmt -recursive -diff ../modules

plan: fmt
	terraform plan

apply: fmt
	terraform apply
