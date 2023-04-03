module "bq" {
  source = "./modules/bq"

  env                      = var.env
  bigquery_role_assignment = var.bigquery_role_assignment
}