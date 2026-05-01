output "lambda_function_name" {
  description = "Name of the start/stop Lambda function."
  value       = aws_lambda_function.dev_scheduler.function_name
}

output "lambda_function_arn" {
  description = "ARN of the start/stop Lambda function."
  value       = aws_lambda_function.dev_scheduler.arn
}

output "schedule_stop_arn" {
  description = "EventBridge Scheduler schedule ARN for the stop window."
  value       = aws_scheduler_schedule.stop_dev.arn
}

output "schedule_start_arn" {
  description = "EventBridge Scheduler schedule ARN for the start window."
  value       = aws_scheduler_schedule.start_dev.arn
}
