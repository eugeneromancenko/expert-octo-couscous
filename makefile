# Define variables
PROJECT_ID=formal-scout-382613
BUCKET_NAME=formal-scout-state222
# Email for bigquery_role_assignment
YOUR_EMAIL=eugene@romancenko.com

REGION=europe-west2
ENV=dev

# Define commands
TERRAFORM_CMD=terraform
SED=sed -i 's/your-email/$(YOUR_EMAIL)/g' variables.tf
TERRAFORM_INIT=$(TERRAFORM_CMD) init -backend-config="bucket=$(BUCKET_NAME)" -backend-config="prefix=terraform/state.tfstate"
TERRAFORM_PLAN=$(TERRAFORM_CMD) plan -var project=$(PROJECT_ID) -var region=$(REGION) -var env=$(ENV) -out=tfplan
TERRAFORM_APPLY=$(TERRAFORM_CMD) apply tfplan --auto-approve
TERRAFORM_DESTROY=$(TERRAFORM_CMD) destroy -var project=$(PROJECT_ID) -var region=$(REGION) -var env=$(ENV) --auto-approve

# Define targets
.PHONY: all
all: create-bucket set-email init plan apply

.PHONY: create-bucket
create-bucket:
	gsutil mb -p $(PROJECT_ID) -l $(REGION) gs://$(BUCKET_NAME)
	sleep 5

.PHONY: init
init:
	$(TERRAFORM_INIT)

.PHONY: set-email
set-email:
	$(SED)

.PHONY: plan
plan:
	$(TERRAFORM_PLAN)

.PHONY: apply
apply:
	$(TERRAFORM_APPLY)

.PHONY: destroy
destroy:
	$(TERRAFORM_DESTROY)

.PHONY: clean
clean:
	rm -rf .terraform
	rm -f tfplan
