Here’s the complete `README.md` file with all the information and steps integrated:

```markdown
# Student Course Enquiry Application Deployment Guide

This repository contains the infrastructure code to deploy a Student Course Enquiry web application on AWS using Terraform. The application consists of an Apache web server, a MySQL database, and a FastAPI backend to handle course enquiry submissions.

The infrastructure includes:
- **VPC (Virtual Private Cloud)** setup
- **Subnets** for public and private resources
- **EC2 instances** to host the Apache web server (frontend) and FastAPI application (backend)
- **Security Groups** to manage access control
- **MySQL database** to store course enquiry data

### Prerequisites

Before deploying the infrastructure using Terraform, ensure that you have completed the following steps:

## 1. **Create an SSH Key Pair in AWS**

To SSH into your EC2 instance after it's deployed, you need an SSH key pair in your AWS account. Follow these steps to create a key pair:

### Step 1: Navigate to the EC2 Console
- Go to the [EC2 Dashboard](https://console.aws.amazon.com/ec2/) in your AWS account.

### Step 2: Create a New Key Pair
- In the left sidebar, click on **Key Pairs** under **Network & Security**.
- Click on **Create Key Pair**.
- Choose a name for your key pair (e.g., `my-key-pair`).
- Select the **RSA** key type and **2048 bits** for key size.
- Click on **Create Key Pair**.
- The private key file (`.pem`) will be downloaded to your machine. Store this file securely, as it is required to SSH into the EC2 instance.

### Step 3: Update the Terraform Configuration

Once you've created your key pair, you need to update the Terraform configuration to use this key pair for the EC2 instance:

1. Open the `terraform.tfvars` file.
2. Add or update the `key_name` variable with the name of the key pair you just created. For example:
   ```hcl
   key_name = "my-key-pair"
   ```
   Replace `my-key-pair` with the actual name of your key pair.

## 2. **Check AWS Region**

Ensure that your Terraform configuration is using the correct AWS region. By default, the configuration specifies `us-east-1` (Northern Virginia). If you're using a different region, you may need to adjust the `region` variable in the `provider` block in the Terraform configuration.

---

### Infrastructure Overview

This application is hosted on AWS and follows a multi-tier architecture with the following resources:

| **Resource**       | **CIDR Block**          | **Description**                                      |
|--------------------|-------------------------|------------------------------------------------------|
| **VPC**            | `172.16.0.0/16`         | Virtual Private Cloud (VPC) for networking isolation. |
| **Public Subnet 1**| `172.16.1.0/24`         | Subnet for public-facing EC2 instances (Apache Server). |
| **Private Subnet 1**| `172.16.2.0/24`        | Subnet for private resources (FastAPI, MySQL).       |
| **Public Subnet 2**| `172.16.3.0/24`         | Additional public-facing subnet (if needed).         |
| **Private Subnet 2**| `172.16.4.0/24`        | Additional private subnet for scaling.               |

### EC2 Instances and Application Flow

- **EC2 Instance 1 (Web Server)**: Hosts an Apache web server with a student enquiry form. The form sends data to FastAPI on the backend.
- **EC2 Instance 2 (FastAPI & MySQL)**: Runs the FastAPI application, which processes the form data and saves it to a MySQL database.
- **MySQL Database**: Stores the data submitted by the students (name, email, phone, query, and course).
- **Security Groups**: Defined to allow communication between Apache and FastAPI on the relevant ports (80 for Apache and 8000 for FastAPI).

### Application Access

Once the infrastructure is deployed:

1. The Apache web server will be accessible on the public IP address of the EC2 instance. Open a browser and navigate to the public IP of the EC2 instance.
2. The student enquiry form will be displayed. Upon submission, the form data is sent to the FastAPI backend running on the same EC2 instance.
3. The FastAPI backend will save the data to the MySQL database, which is also running on the same EC2 instance.

---

### User Data Script

The setup of Apache, MySQL, FastAPI, and the required MySQL database configuration is done through the **user data script** that runs when the EC2 instance is launched. This script can be found in the repository and includes the following steps:
1. Install Apache and configure the web server.
2. Install and configure MySQL, create the `tcb_db` database, and configure the `tcbadmin` user.
3. Install FastAPI and dependencies.
4. Set up the FastAPI app to handle course enquiry submissions and insert them into the MySQL database.

---

### Steps to Deploy

1. **Clone the Repository**
   Clone the repository to your local machine:
   ```bash
   git clone <repo-url>
   cd <repo-name>
   ```

2. **Install Terraform**
   Ensure Terraform is installed on your system. If not, install it from [here](https://www.terraform.io/downloads.html).

3. **Update `terraform.tfvars`**
   - Open the `terraform.tfvars` file.
   - Set your `key_name` variable to the name of your created key pair:
     ```hcl
     key_name = "my-key-pair"
     ```

4. **Initialize Terraform**
   Run the following command to initialize the Terraform working directory:
   ```bash
   terraform init
   ```

5. **Deploy Infrastructure**
   Apply the Terraform configuration to deploy the infrastructure:
   ```bash
   terraform apply
   ```
   - Review the plan and confirm by typing `yes`.

6. **Access the Application**
   After the deployment is complete, retrieve the public IP address of the EC2 instance. You can find this in the **Outputs** of your Terraform plan.

   Navigate to `http://<public-ip>` in your browser to access the student course enquiry form.

7. **Verify Data in MySQL**
   To verify that the form submissions are saved in the MySQL database, SSH into the EC2 instance using the key pair you created:
   CLick on EC2 and click on Connect and choose SSH client TAB to get the ssh details with public IP-address

   ```bash
   ssh -i /path/to/your-key.pem ubuntu@<public-ip>
   ```

   Log in to the MySQL database:
   ```bash
   mysql -u tcbadmin -pTcb@2025
   ```

   Select the database and check the data:
   ```sql
   USE tcb_db;
   SELECT * FROM tcb_enquiry;
   ```

---

### Clean Up

To avoid ongoing charges, make sure to destroy the infrastructure after testing by running the following command:
```bash
terraform destroy
```

This will terminate all resources created by Terraform.

---

### Notes

- Make sure your security group allows inbound traffic on port 80 (Apache) and port 8000 (FastAPI) for the EC2 instance.
- If you need to modify the application or infrastructure, update the relevant Terraform files and re-apply the changes using `terraform apply`.
- The user data script configures all services (Apache, MySQL, FastAPI) automatically when the EC2 instance is launched.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

### Key Updates:
- **Creating SSH Key Pair**: Instructions on creating an SSH key pair and updating the `terraform.tfvars` file with the key name.
- **AWS Region Check**: Ensures that the correct AWS region is set.
- **Infrastructure Overview**: A table explaining the VPC and subnet setup, with detailed architecture descriptions.
- **User Data Script**: Explains how the script sets up Apache, MySQL, and FastAPI.
- **Accessing Application**: Describes how to access the form and verify data in MySQL.
- **MySQL Verification**: Added steps to login into MySQL and check the data using the `SELECT * FROM tcb_enquiry;` query.

This `README.md` provides clear instructions to users for deploying, interacting with, and verifying the deployment of the application.
