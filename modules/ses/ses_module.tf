# Random suffix for IAM user
resource "random_id" "iam_user_suffix" {
  byte_length = 8
}

# SES Domain Identity
resource "aws_ses_domain_identity" "this" {
  domain = var.domain_name
}

# SES Domain DKIM
resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

# SES Custom MAIL FROM Domain
resource "aws_ses_domain_mail_from" "this" {
  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = "${var.ses_mail_from_subdomain}.${var.domain_name}"
}

# IAM User with random suffix
resource "aws_iam_user" "ses_user" {
  name = "${var.ses_iam_user_name}-${random_id.iam_user_suffix.hex}"

  # ignore manually added access key(s)
  lifecycle {
    ignore_changes = all
  }

  tags = local.tags
}

# Verify the receiver email address
resource "aws_ses_email_identity" "receiver" {
  email = var.ses_verified_receiver_email
}

# SES Configuration Set
resource "aws_ses_configuration_set" "this" {
  name = var.ses_configuration_set
}

# IAM Policy
resource "aws_iam_user_policy" "ses_policy" {
  name = "ses_send_email_policy"
  user = aws_iam_user.ses_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail"
        ]
        Resource = aws_ses_domain_identity.this.arn
        Condition = {
          StringEquals = {
            "ses:FromAddress" = var.ses_allowed_sender_email
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
        ]
        Resource = aws_ses_email_identity.receiver.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:UseConfigurationSet"
        ]
        Resource = aws_ses_configuration_set.this.arn
      }
    ]
  })
}

# SES Domain Identity Verification
resource "aws_route53_record" "ses_verification" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.this.verification_token]
}

# SPF Record for main domain
resource "aws_route53_record" "spf" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:${aws_ses_domain_mail_from.this.mail_from_domain} ~all"]
}

# MX Record for MAIL FROM domain
resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id = var.route53_zone_id
  name    = aws_ses_domain_mail_from.this.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

# SPF Record for MAIL FROM domain
resource "aws_route53_record" "ses_mail_from_spf" {
  zone_id = var.route53_zone_id
  name    = aws_ses_domain_mail_from.this.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

# DKIM Records
resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = var.route53_zone_id
  name    = "${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# DMARC Record
resource "aws_route53_record" "dmarc" {
  zone_id = var.route53_zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=none; rua=mailto:${var.dmarc_report_email}"]
}
