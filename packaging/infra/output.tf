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

output "function" {
  value = module.lambda
}

output "function_url" {
  value = aws_lambda_function_url.lambda.function_url
}

output "runtime" {
  sensitive = true
  value     = nonsensitive(module.runtime)
}

output "function_image" {
  value = module.lambda_image
}
