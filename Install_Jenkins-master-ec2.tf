provider "aws" {
  region = "ap-south-1" # Mumbai region
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = file("~/.ssh/id_rsa.pub") # Adjust the path to your public key
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "jenkins_server" {
  ami           = "ami-08c40ec9ead489470" # Amazon Linux 2 AMI for Mumbai region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.jenkins_key.key_name
  security_groups = [
    aws_security_group.jenkins_sg.name
  ]

  user_data = <<-EOF
              #!/bin/bash
              # Update packages
              yum update -y

              # Install Java (Amazon Corretto 8)
              amazon-linux-extras enable corretto8
              yum install -y java-1.8.0-amazon-corretto

              # Set JAVA_HOME
              echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto" >> /etc/profile
              echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
              source /etc/profile

              # Install Maven
              yum install -y maven

              # Set Maven environment variables
              echo "export M2_HOME=/usr/share/maven" >> /etc/profile
              echo "export MAVEN_HOME=/usr/share/maven" >> /etc/profile
              echo "export PATH=\$M2_HOME/bin:\$PATH" >> /etc/profile
              source /etc/profile

              # Install Jenkins
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum install -y jenkins

              # Start Jenkins
              systemctl start jenkins
              systemctl enable jenkins
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

output "jenkins_public_ip" {
  value       = aws_instance.jenkins_server.public_ip
  description = "Public IP of the Jenkins server"
}