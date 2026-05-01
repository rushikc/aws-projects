resource "aws_iam_role" "scheduler" {
  name = "${var.project_name}-scheduler-invoke"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "scheduler_invoke" {
  name = "${var.project_name}-scheduler-invoke-lambda"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = aws_lambda_function.dev_scheduler.arn
    }]
  })
}

resource "aws_scheduler_schedule" "stop_dev" {
  name        = "${var.project_name}-stop-friday"
  description = "Stop tagged Dev EC2/RDS (see Lambda TAG_KEY/TAG_VALUE)."
  state       = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.stop_schedule
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn      = aws_lambda_function.dev_scheduler.arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ action = "stop" })
  }
}

resource "aws_scheduler_schedule" "start_dev" {
  name        = "${var.project_name}-start-monday"
  description = "Start tagged Dev EC2/RDS (see Lambda TAG_KEY/TAG_VALUE)."
  state       = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.start_schedule
  schedule_expression_timezone = var.schedule_timezone

  target {
    arn      = aws_lambda_function.dev_scheduler.arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ action = "start" })
  }
}

resource "aws_lambda_permission" "scheduler_stop" {
  statement_id  = "AllowExecutionFromSchedulerStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dev_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.stop_dev.arn
}

resource "aws_lambda_permission" "scheduler_start" {
  statement_id  = "AllowExecutionFromSchedulerStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dev_scheduler.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = aws_scheduler_schedule.start_dev.arn
}
