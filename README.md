### Explanation & Instructions:

-   **Instance Type**: A `t3.medium` instance is used for better CPU and memory resources.
-   **User Data Script**:
    -   Installs required packages (`java-17-openjdk`, `vim`, `git`, `wget`, `unzip`).
    -   Installs and configures PostgreSQL locally on the instance.
    -   Downloads and installs SonarQube, sets permissions, and starts SonarQube as a service.
-   **Security Group**: Opens port 22 for SSH and port 9000 for SonarQube web access.
-   **SonarQube Database Configuration**: Configured to connect to the locally hosted PostgreSQL instance.

### Cost Optimization:

-   **Single Instance**: Combines SonarQube and PostgreSQL on the same instance to avoid the cost of an additional RDS instance.
-   **t3.medium**: Provides a cost-effective balance of performance and price, better than t2 instances for production-like usage.

### Deployment Steps:

1.  Save the script as `main.tf`.
2.  Run `terraform init` to initialize the configuration.
3.  Run `terraform plan` to preview the infrastructure.
4.  Run `terraform apply` to deploy.

### Post-Deployment:

-   Access SonarQube at `http://<instance_public_ip>:9000`.
-   Default login credentials are `admin`/`admin`.
-   Verify database connection and SonarQube status through the web UI or server logs.
