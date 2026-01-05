output "env" {
  value = {
    profile    = local.profile
    region     = local.region
    namespace  = module.label.namespace
    name       = module.label.name
    id         = module.label.id
    account_id = local.account_id
  }
}

output "lambda" {
  value = module.lambda
}

output "layer" {
  value = module.layer
}