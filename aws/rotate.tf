data "aws_iam_policy" "ec2_full" {
  name = "AmazonEC2FullAccess"
}

resource "aws_iam_role" "rotate_lambda" {
  name = "rotate_instances"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  managed_policy_arns = [data.aws_iam_policy.ec2_full.arn, data.aws_iam_policy.logs_access.arn]
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/rotate_instances"
  retention_in_days = 1
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/rotate.py"
  output_path = "${path.module}/lambda.zip"
}


resource "aws_lambda_function" "rotate_instances" {
  filename      = "${path.module}/lambda.zip"
  function_name = "rotate_instances"
  role          = aws_iam_role.rotate_lambda.arn
  handler       = "rotate.run"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime = "python3.8"
  depends_on = [aws_cloudwatch_log_group.lambda_log]
  environment {
      variables = {
          ROTATE_EVERY_MINUTES = var.rotate_every_minutes
      }
  }
}

resource "aws_cloudwatch_event_rule" "interval" {
  name                = "every-minute"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "rotate_instance" {
  rule      = "${aws_cloudwatch_event_rule.interval.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.rotate_instances.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_rotate_instances" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rotate_instances.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.interval.arn}"
}