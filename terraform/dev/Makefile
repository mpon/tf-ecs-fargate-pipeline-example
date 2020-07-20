init:
	terraform init -backend-config="bucket=${REMOTE_BACKEND}"

fmt:
	terraform fmt -recursive -diff ../

plan: fmt
	terraform plan

apply: fmt
	terraform apply
