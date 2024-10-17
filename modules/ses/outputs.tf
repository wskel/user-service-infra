output "ses_configuration_set_arn" {
  description = "The ARN of the SES configuration set"
  value       = aws_ses_configuration_set.this.arn
}

output "ses_domain_identity_arn" {
  description = "The ARN of the SES domain identity"
  value       = aws_ses_domain_identity.this.arn
}

output "ses_email_identity_arn" {
  description = "The ARN of the SES email identity for the verified receiver"
  value       = aws_ses_email_identity.receiver.arn
}

output "ses_verified_receiver_email" {
  description = "The verified email address for receiving emails"
  value       = aws_ses_email_identity.receiver.email
}

output "iam_user_arn" {
  description = "The ARN of the created IAM user"
  value       = aws_iam_user.ses_user.arn
}

output "iam_user_name" {
  description = "The name of the created IAM user"
  value       = aws_iam_user.ses_user.name
}
