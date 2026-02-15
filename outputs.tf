output "instance_hostname" {
  description = "Output the public dns name for the created instance"
  value       = aws_instance.app_server.public_dns
}