# main.tf - Provision a t3.medium EC2 instance on Amazon Linux 2 with SonarQube and PostgreSQL

# Provider configuration
provider "aws" {
  region = "ap-south-1" # Mumbai region
}

# Create a key pair for SSH access (optional)
resource "aws_key_pair" "student_key_pair" {
  key_name   = "student_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAr..." # Replace with your public key
}

# Security group to allow SSH access and SonarQube (port 9000)
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube_sg"
  description = "Allow SSH and SonarQube access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance with user data to install SonarQube and PostgreSQL
resource "aws_instance" "sonarqube_server" {
  ami           = "ami-0e306788ff2473ccb" # Amazon Linux 2 AMI ID (Mumbai region)
  instance_type = "t3.medium" # Recommended instance type for SonarQube

  key_name = aws_key_pair.student_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system and install required packages
              sudo yum update -y
              sudo yum install -y java-17-openjdk wget git vim unzip

              # Install PostgreSQL
              sudo amazon-linux-extras install -y postgresql14
              sudo systemctl enable postgresql
              sudo systemctl start postgresql

              # Set up PostgreSQL database for SonarQube
              sudo -u postgres psql -c "CREATE USER sonar WITH PASSWORD 'sonar';"
              sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
              sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"

              # Download and install SonarQube
              wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.1.69595.zip
              unzip sonarqube-9.9.1.69595.zip
              sudo mv sonarqube-9.9.1.69595 /opt/sonarqube

              # Set permissions
              sudo useradd -m -d /opt/sonarqube sonaruser
              sudo chown -R sonaruser:sonaruser /opt/sonarqube

              # Configure SonarQube to use PostgreSQL
              echo "sonar.jdbc.username=sonar" | sudo tee -a /opt/sonarqube/conf/sonar.properties
              echo "sonar.jdbc.password=sonar" | sudo tee -a /opt/sonarqube/conf/sonar.properties
              echo "sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube" | sudo tee -a /opt/sonarqube/conf/sonar.properties

              # Start SonarQube as sonaruser
              sudo su - sonaruser -c "/opt/sonarqube/bin/linux-x86-64/sonar.sh start"
              EOF

  tags = {
    Name = "SonarQube-Server"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.sonarqube_server.public_ip
}
