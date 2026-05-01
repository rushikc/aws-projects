variable "aws_region" {
  description = "AWS region where Lambda runs and where resources are managed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for resource names."
  type        = string
  default     = "light-switch"
}

variable "tag_key" {
  description = "Tag key used to select EC2 and RDS instances (e.g. Environment)."
  type        = string
  default     = "Environment"
}

variable "tag_value" {
  description = "Tag value that marks dev resources (e.g. Dev)."
  type        = string
  default     = "Dev"
}

variable "schedule_timezone" {
  description = "IANA timezone for stop/start cron expressions (e.g. America/New_York)."
  type        = string
  default     = "Etc/UTC"
}

variable "stop_schedule" {
  description = "EventBridge Scheduler cron expression for stop (default: 18:00 on Friday)."
  type        = string
  default     = "cron(0 18 ? * FRI *)"
}

variable "start_schedule" {
  description = "EventBridge Scheduler cron expression for start (default: 08:00 on Monday)."
  type        = string
  default     = "cron(0 8 ? * MON *)"
}
