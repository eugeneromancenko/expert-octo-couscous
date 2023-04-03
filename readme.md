# README

This is a guide on how to use the code in this repository to provision a private K8s cluster on GKE using Terraform. 

## Prerequisites
Before you begin, you must have the following:
- Terraform installed on your machine
- A GCP account with $300 credits or more
- The `gcloud` CLI tool installed and authenticated with your GCP account
- Enable the following GCP APIs:
  - `compute.googleapis.com`
  - `container.googleapis.com`

## Getting started
1. Clone this repository: `git clone <repo-url>`
2. Navigate to the cloned repository directory: `cd <repo-name>`
3. Initialize the Terraform working directory: `terraform init -backend-config=./backend.tfvars`
4. Create a new Terraform execution plan: `terraform plan -var-file=common.tfvars`
5. Apply the Terraform configuration to create the infrastructure: `terraform apply -var-file=common.tfvars`

## Terraform Configuration
The Terraform code in this repository is split into two tasks:

### Task 1
Task 1 provisions a regional private K8s cluster on GKE with a dedicated service account, new VPC, and a subnet in the London region. It also creates two node-pools, one with 3 nodes without auto-scaling and another with 0 node by default with auto-scaling enabled. The outbound internet access to the private cluster is allowed without assigning externalIP addresses to it.

### Task 2
Task 2 creates a new BigQuery dataset called `vmo2_tech_test` and assigns a specific role to a user using a local Terraform module called `bigquery_dataset_access`.

## Variables
The `variables.tf` file contains the variables used in this Terraform configuration. You can edit this file to customize the values to your preference.

## Conclusion
After following the steps outlined in this guide, you should have successfully provisioned a private K8s cluster on GKE and created a new BigQuery dataset with a specific role assigned to a user.
