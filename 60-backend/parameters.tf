resource "aws_ssm_parameter" "backend_private_ip" {
  name  = "/backend/private_ip"
  type  = "String"
  value = aws_instance.backend.private_ip
  overwrite = true
}