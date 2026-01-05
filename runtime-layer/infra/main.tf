module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = local.namespace
  name      = local.name
}

data "aws_caller_identity" "current" {}

locals {
  profile    = var.profile
  region     = var.region
  identity   = data.aws_caller_identity.current
  account_id = local.identity.account_id
  name       = var.name
  namespace  = var.namespace
  id         = module.label.id
  # prefixes
  ssm_prefix = "${"/"}${join("/", compact([
    module.label.namespace != "" ? module.label.namespace : null,
    module.label.name != "" ? module.label.name : null
  ]))}"
  pascal_prefix = replace(title(module.label.id), "/\\W+/", "")
}

module "lambda" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-function.git?ref=v1.1.0"

  source_dir       = "../app/src"
  
  runtime         = "provided.al2023"
  handler =       "handler.run"
  architecture    = "arm64"

  memory_size     = 2048 # 1024 # 512 # 
  timeout         = 10

  layers = [
    module.layer.layer_arn
  ]

  context         = module.label.context
  attributes      = ["function"]

  depends_on      = [ module.layer ]
}

module "layer" {
  source      = "git::https://github.com/ql4b/terraform-aws-lambda-layer.git?ref=v1.0.0"
  
  context     = module.label.context
  attributes  = ["bootstap"]
  
  source_dir                = "../runtime/build"
  compatible_architectures  = ["arm64"]
  compatible_runtimes       = ["provided.al2023"]
}