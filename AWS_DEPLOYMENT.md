# AWS Deployment Guide for E-Commerce Stack

This guide details the complete deployment setup for the **NestJS Backend**, **React Frontend**, and **MySQL Database** on Amazon Web Services (AWS).

---

## 🏗️ Architecture Overview

```
[ Client Browser ]
        │
        ▼
[ AWS Application Load Balancer (ALB) ]
    ├──► Port 80 / 443 ──► [ ECS Fargate: React Frontend (Nginx) ]
    └──► Port 3000 /api ──► [ ECS Fargate: NestJS Backend API ]
                                   │
                                   ▼
                         [ AWS RDS: MySQL 8.0 ]
```

---

## 🚀 Step 1: AWS Prerequisites & ECR Repositories

1. **Install AWS CLI**: Ensure AWS CLI is installed and configured (`aws configure`).
2. **Create Amazon ECR Repositories**:
   ```bash
   aws ecr create-repository --repository-name ecommerce-backend --region us-east-1
   aws ecr create-repository --repository-name ecommerce-frontend --region us-east-1
   ```

---

## 🛢️ Step 2: Provision AWS RDS MySQL Database

1. Open AWS Management Console -> **RDS** -> **Create Database**.
2. Select **MySQL 8.0**.
3. DB Instance Identifier: `ecommerce-db`
4. Master Username: `jwt_user` (or admin user)
5. Master Password: `<YOUR_SECURE_PASSWORD>`
6. Connectivity:
   - VPC: Default VPC (or Custom VPC)
   - Publicly Accessible: No (Recommended) or Yes for initial setup.
   - Security Group: Allow Inbound MySQL port `3306` from your ECS Security Group.
7. Note down the **RDS Endpoint** (e.g., `ecommerce-db.xxxxxx.us-east-1.rds.amazonaws.com`).

---

## 🔐 Step 3: Configure AWS SSM Parameter Store (Secrets)

Store production secrets safely in **AWS Systems Manager (SSM) Parameter Store**:

```bash
aws ssm put-parameter --name "/ecommerce/DB_HOST" --value "ecommerce-db.xxxxxx.us-east-1.rds.amazonaws.com" --type "String"
aws ssm put-parameter --name "/ecommerce/DB_USER" --value "jwt_user" --type "String"
aws ssm put-parameter --name "/ecommerce/DB_PASSWORD" --value "<YOUR_SECURE_PASSWORD>" --type "SecureString"
aws ssm put-parameter --name "/ecommerce/DB_NAME" --value "jwt_auth" --type "String"
aws ssm put-parameter --name "/ecommerce/JWT_SECRET" --value "<YOUR_JWT_SECRET>" --type "SecureString"
```

---

## 📦 Step 4: Provision AWS ECS Cluster & Services

1. Open AWS Management Console -> **Elastic Container Service (ECS)**.
2. **Create Cluster**:
   - Cluster Name: `ecommerce-cluster`
   - Infrastructure: AWS Fargate (serverless).
3. **Register Task Definitions**:
   ```bash
   aws ecs register-task-definition --cli-input-json file://aws/ecs-backend-task.json
   aws ecs register-task-definition --cli-input-json file://aws/ecs-frontend-task.json
   ```
4. **Create ECS Services**:
   - Service Name: `ecommerce-backend-service` (linking to `ecommerce-backend-task`)
   - Service Name: `ecommerce-frontend-service` (linking to `ecommerce-frontend-task`)

---

## 🔄 Step 5: Configure Automated CI/CD (GitHub Actions)

Add the following **Secrets** in your GitHub Repository (**Settings** -> **Secrets and variables** -> **Actions**):

| Secret Name | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your AWS IAM User Access Key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS IAM User Secret Access Key |
| `AWS_REGION` | `us-east-1` (or your preferred region) |

Once configured, pushing to the `aws_deployment` or `main` branch will automatically:
1. Build both Docker images for Backend and Frontend.
2. Push them to Amazon ECR.
3. Deploy new tasks to Amazon ECS with zero downtime.

---

## 🛠️ Local Docker Testing (Before AWS Push)

Test the complete containerized stack locally at any time:

```bash
docker compose build --no-cache
docker compose up -d
```
- Frontend: `http://localhost`
- Backend API: `http://localhost:3000`
- MySQL: `localhost:3307`
