resource "aws_instance" "web" {
  count = length(var.private_subnet_ids)

  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.web_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from instance ${count.index}" > /var/www/html/index.html
              EOF
}