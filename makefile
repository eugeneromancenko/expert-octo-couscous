# Define variables
PROJECT_ID=boreal-matrix-382609
BUCKET_NAME=boreal-matrix-state
REGION=europe-west2
ENV=dev

# Define commands
TERRAFORM_CMD=terraform
TERRAFORM_INIT=$(TERRAFORM_CMD) init -backend-config="bucket=$(BUCKET_NAME)" -backend-config="prefix=terraform/state.tfstate"
TERRAFORM_PLAN=$(TERRAFORM_CMD) plan -var project=$(PROJECT_ID) -var region=$(REGION) -var env=$(ENV) -out=tfplan
TERRAFORM_APPLY=$(TERRAFORM_CMD) apply tfplan
TERRAFORM_DESTROY=$(TERRAFORM_CMD) destroy -var project=$(PROJECT_ID)

# Define targets
.PHONY: all
all: create-bucket init plan apply

.PHONY: create-bucket
create-bucket:
	gsutil mb -p $(PROJECT_ID) -l $(REGION) gs://$(BUCKET_NAME)

.PHONY: init
init:
	$(TERRAFORM_INIT)

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
