resource "aws_security_group" "web" {
  name        = "bootcamp-web-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bootcamp-web-sg"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-00d8fc944fb171e29"
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  tags = {
    Name = "bootcamp-web-server"
  }

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    apt update -y
    DEBIAN_FRONTEND=noninteractive apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
  EOF

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_id" {
  value = aws_instance.web.id
}
