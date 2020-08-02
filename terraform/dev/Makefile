init:
	tfenv install
	terraform init \
		-backend-config="bucket=${TF_VAR_remote_backend}" \
		-backend-config="region=${AWS_DEFAULT_REGION}"

fmt:
	terraform fmt -recursive -diff ../

plan: fmt
	terraform plan

apply: fmt
	terraform apply
