output "awsiot_cert_pem" {
  value     = aws_iot_certificate.main.certificate_pem
  sensitive = true
}

output "awsiot_private_key" {
  value     = aws_iot_certificate.main.private_key
  sensitive = true
}

output "awsiot_endpoint" {
  value = data.aws_iot_endpoint.main.endpoint_address
}
