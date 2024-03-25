locals {

  function_iam_role_name = var.function_iam_role_name == "default" ? (
    "${var.labels.component}-lambda"
  ) : var.function_iam_role_name

}

# IAM roles that the Amazon ECS container agent and the Docker daemon can assume
data "aws_iam_policy_document" "function_iam" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "function_iam_role" {
  name                 = local.function_iam_role_name
  path                 = var.function_iam_role_path
  assume_role_policy   = join("", data.aws_iam_policy_document.function_iam.*.json)
  permissions_boundary = var.permissions_boundary == "" ? null : var.permissions_boundary
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.function_iam_role_name }
  )
}

resource "aws_iam_role_policy_attachment" "function_iam_role_default" {
  for_each   = toset(var.function_role_policy_arns_default)
  role       = aws_iam_role.function_iam_role.name
  policy_arn = each.key
}

resource "aws_iam_role_policy" "function_iam_role" {
  for_each = var.function_role_policy_statements
  name     = "${local.function_iam_role_name}-${each.key}"
  role     = aws_iam_role.function_iam_role.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value
  })
}

resource "aws_iam_role_policy_attachment" "function_iam_role" {
  for_each   = toset(var.function_role_policy_arns)
  role       = aws_iam_role.function_iam_role.name
  policy_arn = each.key
}


resource "aws_lambda_permission" "lambda_function" {
  for_each      = var.aws_lambda_permission
  statement_id  = each.key
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}