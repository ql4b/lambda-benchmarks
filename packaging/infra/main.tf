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
  source = "git::https://github.com/ql4b/terraform-aws-lambda-function.git?ref=v1.0.1"

  source_dir       = "../app/src"
  template_dir     = "../app/src"
  create_templates = true

  runtime = "provided.al2023"
  # handler          = "bootstrap"
  handler = "handler.run"

  memory_size = 2048 # 1024 # 512 # 
  timeout     = 20

  context    = module.label.context
  attributes = ["function"]
}

resource "aws_lambda_function_url" "lambda" {
  function_name      = module.lambda.function_name
  authorization_type = "NONE"
}

module "runtime" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-runtime.git?ref=v1.0.0"

  # attributes = ["bash"]
  deploy_tag = "latest"
  context    = module.label.context
}

data "aws_ecr_image" "runtime_image" {
  repository_name = module.runtime.ecr.repository_name
  image_tag       = "latest"
}

module "lambda_image" {
  source = "git::https://github.com/ql4b/terraform-aws-lambda-function.git?ref=v1.0.1"

  package_type = "Image"
  image_uri    = "${module.runtime.ecr.repository_url}@${data.aws_ecr_image.runtime_image.image_digest}"
  image_config = {
    command = ["handler.run"]
  }

  memory_size = 2048
  timeout     = 20

  attributes = [ "image" ]
  context = module.label.context
}
  