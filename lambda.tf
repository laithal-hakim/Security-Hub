data "archive_file" "aws_ec2_security_group_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/aws_ec2_security_group_delete/"
  output_path = "${path.module}/tmp/aws_ec2_security_group_delete.zip"
}

data "aws_iam_policy_document" "aws_ec2_security_group_delete_lambda" {

  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
      "lambda:*",
      "cloudwatch:*"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "aws_ec2_security_group_delete_lambda" {
  name        = "aws_ec2_security_group_delete"
  path        = "/"
  description = "Provides full access to EC2 and Lambda"
  policy      = data.aws_iam_policy_document.aws_ec2_security_group_delete_lambda.json
}

resource "aws_iam_role" "aws_ec2_security_group_delete_lambda" {
  name               = "aws_ec2_security_group_delete_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "aws_ec2_security_group_delete_lambda" {
  role       = aws_iam_role.aws_ec2_security_group_delete_lambda.name
  policy_arn = aws_iam_policy.aws_ec2_security_group_delete_lambda.arn
}

resource "aws_lambda_function" "aws_ec2_security_group_delete" {
  filename      = data.archive_file.aws_ec2_security_group_lambda.output_path
  function_name = "aws_ec2_security_group_delete"
  role          = aws_iam_role.aws_ec2_security_group_delete_lambda.arn
  handler       = "main.delete_all_security_groups"
  timeout       = 60
  #   layers        = [aws_lambda_layer_version.pandas_lambda_layer.arn]

  source_code_hash = data.archive_file.aws_ec2_security_group_lambda.output_base64sha256

  runtime = "python3.11"
}

# Scheduling Trigger
resource "aws_cloudwatch_event_rule" "hourly" {
  name                = "30_days_invocation_ec2_security_group"
  description         = "Trigger Lambda 30 days"
  schedule_expression = "rate(30 days)"
}

resource "aws_cloudwatch_event_target" "aws_ec2_security_group_delete" {
  rule      = aws_cloudwatch_event_rule.hourly.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.aws_ec2_security_group_delete.arn
}

resource "aws_lambda_permission" "allow_eventbridge_ec2_security_group" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_ec2_security_group_delete.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hourly.arn
}
