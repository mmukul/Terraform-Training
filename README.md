### Install Terraform

yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
yum install unzip -y
unzip awscliv2.zip
sudo ./aws/install

### Sync System Time

timedatectl set-ntp true

### Deployment Steps:

1.  Save the script as `main.tf`.
2.  Run `terraform init` to initialize the configuration.
3.  Run `terraform plan` to preview the infrastructure.
4.  Run `terraform apply` to deploy.

### Post-Deployment:

-   Access SonarQube at `http://<instance_public_ip>:9000`.
-   Default login credentials are `admin`/`admin`.
-   Verify database connection and SonarQube status through the web UI or server logs.
