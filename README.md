# Overview of Deployed Application

This application is deployed on AWS using Terraform and involves several key components:

## 1. **Virtual Private Cloud (VPC) Setup**

The **VPC** and its subnets are configured as follows:

| Component           | CIDR Block       | Description                                   |
|---------------------|------------------|-----------------------------------------------|
| **VPC**             | `172.16.0.0/16`  | Custom VPC for the application.               |
| **Public Subnet 1** | `172.16.1.0/24`  | Public subnet for external-facing resources.  |
| **Private Subnet 1**| `172.16.2.0/24`  | Private subnet for backend resources.         |
| **Public Subnet 2** | `172.16.3.0/24`  | Another public subnet for resources.          |
| **Private Subnet 2**| `172.16.4.0/24`  | Another private subnet for backend resources. |

## 2. **Security Groups**

A **Security Group** is configured for the EC2 instance to allow:

- **Inbound traffic** on port `80` (HTTP) for the Apache web server.
- **Inbound traffic** on port `8000` for the FastAPI application.

The security group setup allows access from the internet to both the web server and FastAPI, while also ensuring secure internal communication for backend processes like database access.

## 3. **EC2 Instance Setup**

An **EC2 instance** is deployed within the **public subnet** of the VPC and configured to run the following services:

- **Apache Web Server**: Hosts the student enquiry/registration form.
- **MySQL Database**: Stores the form submissions.
- **FastAPI Application**: Processes the form data and saves it to the MySQL database.

## 4. **FastAPI and MySQL Integration**

- The **FastAPI app** listens for POST requests on port `8000` and handles the submission of form data.
- The data (student name, course, email, mobile, and query) is inserted into a **MySQL database** hosted on the same EC2 instance.

---

## 5. **Userdata Script Setup**

The setup for **Apache**, **MySQL**, and **FastAPI** is automated via a **userdata script**. The script:

- Installs and configures the **Apache Web Server** to serve the enquiry form.
- Installs **MySQL** and sets up a database to store form submissions.
- Installs **FastAPI** and sets it up to process form data and save it to the MySQL database.

This script is available in the repository and is executed automatically when the EC2 instance is launched.

---

## Accessing the Application

Once the infrastructure is deployed, you can access the application through the public IP of the EC2 instance:

1. **Get the Public IP of the EC2 Instance**
   - After deploying the infrastructure with Terraform, you can find the **public IP** of your EC2 instance in the AWS console or through Terraform outputs.
   
2. **Access the Registration Form**
   - Open a web browser and visit:
     ```
     http://<EC2_PUBLIC_IP>
     ```
   - This will load the student enquiry/registration form hosted by the Apache web server.

3. **Submit the Form**
   - Fill in the form with the necessary details (name, course, email, mobile, and query).
   - When you click **Submit**, the form data is sent to the FastAPI Python application running on port `8000` of the EC2 instance.
   - FastAPI processes the data and saves it into the MySQL database.

4. **Confirmation**
   - Upon successful submission, a confirmation message is displayed on the frontend, indicating that the data was saved successfully. If there is an error, an error message is shown.

---

## Summary of Components:

- **VPC**: Contains public and private subnets to segment traffic.
- **EC2 Instance**: Runs Apache Web Server, FastAPI Python application, and MySQL database.
- **Frontend**: The student enquiry form is served via Apache Web Server.
- **Backend**: FastAPI handles the form submission, processes it, and stores the data in MySQL.

---

