output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}

output "frontend_instance_ids" {
  value = [aws_instance.ecommerce_frontend_az1.id, aws_instance.ecommerce_frontend_az2.id]
}