terraform {
  required_version = "1.1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
}

resource "aws_iot_certificate" "main" {
  active = true
}

resource "aws_iot_policy" "main" {
  name = "PubSubToAnyTopic"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iot_policy_attachment" "main" {
  policy = aws_iot_policy.main.name
  target = aws_iot_certificate.main.arn
}

data "aws_iot_endpoint" "main" {}
