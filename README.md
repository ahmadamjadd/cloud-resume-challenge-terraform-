# AWS Cloud Resume Challenge ☁️

![Architecture Diagram](https://img.shields.io/badge/Status-Functional-success)

## 📖 Overview
This project is my implementation of the **Cloud Resume Challenge**. It is a full-stack serverless resume hosted on AWS, deployed 100% via **Infrastructure as Code (Terraform)**.

The goal is to move beyond the console and build a production-ready application that handles real-world concerns like security, automation, and CI/CD.

## 🏗️ Architecture
The website uses a serverless backend to track and display visitor counts dynamically. 

**Key Services Used:**
* **Compute:** AWS Lambda (Python)
* **Storage:** Amazon S3 (Static Website Hosting)
* **Database:** Amazon DynamoDB (NoSQL)
* **Networking:** Amazon CloudFront (CDN) & Route53 (DNS)
* **IaC:** Terraform
* **CI/CD:** GitHub Actions

## 🚀 Phases

### Phase 1: The Static Site ✅
- [x] Configured S3 Bucket with Terraform.
- [x] Enabled Static Website Hosting.
- [x] Applied strict Bucket Policies (No public write access).
- [x] Secure content delivery via CloudFront (HTTPS).

### Phase 2: The Serverless Backend ✅
- [X] Create DynamoDB table for visitor counter.
- [X] Write Python Lambda function to update count.
- [X] Provision API Gateway to trigger Lambda.

### Phase 3: Automation (Upcoming) 🚧
- [ ] Set up GitHub Actions for automated Terraform deployment.
- [ ] Implement Cypress tests for the frontend.

## 🛠️ How to Deploy
**(For Recruiters & Developers)**

**Prerequisites:**
* AWS CLI configured with appropriate permissions.
* Terraform installed (v1.5+).

**Deployment Steps (Requires Two Terraform Runs):**

1.  Clone the repo:
    ```bash
    git clone [https://github.com/ahmadamjadd/cloud-resume-challenge-terraform-.git](https://github.com/ahmadamjadd/cloud-resume-challenge-terraform-.git)
    cd aws-cloud-resume-infrastructure
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  **FIRST APPLY: Create Infrastructure & Get API URL**
    ```bash
    terraform apply
    ```
    * **CRITICAL STEP:** After this first apply, the API Gateway endpoint will be created. You must find the output variable (if defined) or check the AWS Console for the full API URL (e.g., `https://[ID].execute-api.ap-south-1.amazonaws.com/`).

4.  **MANUAL UPDATE: Inject URL into Frontend Code**
    * Open `index.html`.
    * Find the JavaScript variable `const apiUrl = "...";`
    * Paste the API Gateway URL you just found inside the quotes. **Save the file.**

5.  **SECOND APPLY: Upload Corrected Frontend**
    ```bash
    terraform apply
    ```
    * This second run detects the change in `index.html` and uploads the file with the correct, working API endpoint to S3.

6.  **Find the CloudFront URL**
    * The final website URL will be the domain name of your CloudFront distribution, found in the Terraform output or the AWS console.

## 📂 Project Structure
```bash
.
├── main.tf           # S3 & API Gateway/Lambda Config
├── cloudfront.tf     # CDN Configuration
├── backend.tf        # Remote State Management
├── .gitignore        # Safety net (blocks .tfstate)
└── README.md         # Documentation