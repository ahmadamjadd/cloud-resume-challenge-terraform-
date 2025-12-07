# AWS Cloud Resume Challenge ☁️

![Architecture Diagram](https://img.shields.io/badge/Status-In%20Progress-yellow)
## 📖 Overview
This project is my implementation of the **Cloud Resume Challenge**. It is a full-stack serverless resume hosted on AWS, deployed 100% via **Infrastructure as Code (Terraform)**.

The goal is to move beyond the console and build a production-ready application that handles real-world concerns like security, automation, and CI/CD.

## 🏗️ Architecture
**Key Services Used:**
* **Compute:** AWS Lambda (Python)
* **Storage:** Amazon S3 (Static Website Hosting)
* **Database:** Amazon DynamoDB (NoSQL)
* **Networking:** Amazon CloudFront (CDN) & Route53 (DNS)
* **IaC:** Terraform
* **CI/CD:** GitHub Actions

## 🚀 Phases

### Phase 1: The Static Site (Current) ✅
- [x] Configured S3 Bucket with Terraform.
- [x] Enabled Static Website Hosting.
- [x] Applied strict Bucket Policies (No public write access).
- [x] Secure content delivery via CloudFront (HTTPS).

### Phase 2: The Backend (Upcoming) 🚧
- [ ] Create DynamoDB table for visitor counter.
- [ ] Write Python Lambda function to update count.
- [ ] Provision API Gateway to trigger Lambda.

### Phase 3: Automation (Upcoming) 🚧
- [ ] Set up GitHub Actions for automated Terraform deployment.
- [ ] Implement Cypress tests for the frontend.

## 🛠️ How to Deploy
**(For Recruiters & Developers)**

**Prerequisites:**
* AWS CLI configured with appropriate permissions.
* Terraform installed (v1.5+).

**Steps:**
1.  Clone the repo:
    ```bash
    git clone [https://github.com/YOUR_USERNAME/aws-cloud-resume-infrastructure.git](https://github.com/YOUR_USERNAME/aws-cloud-resume-infrastructure.git)
    cd aws-cloud-resume-infrastructure
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Plan and Apply:
    ```bash
    terraform plan
    terraform apply
    ```

## 📂 Project Structure
```bash
.
├── main.tf           # S3 & Basic Provider Config
├── cloudfront.tf     # CDN Configuration (In Progress)
├── backend.tf        # Remote State Management
├── .gitignore        # Safety net (blocks .tfstate)
└── README.md         # Documentation
