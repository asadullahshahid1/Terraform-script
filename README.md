# PayNest Document Verifier - Infrastructure

Terraform configuration for deploying the PayNest Document Verifier microservice on AWS.

Infrastructure Overview

- **Container hosting** with AWS App Runner
- **Image registry** with Amazon ECR  
- **Global CDN** with CloudFront
- **Security** with AWS WAF
- **DNS management** with Route 53
- **Secrets management** with AWS Secrets Manager
- **CI/CD pipeline** with AWS CodePipeline & CodeBuild
- **Monitoring** with CloudWatch

## File Structure

```
Terraform-script/
├── main.tf   
├── backend.tf                 
├── variables.tf               
├── outputs.tf                 
├── ecr.tf                    
├── secrets.tf                 
├── iam.tf                    
├── app-runner.tf              
├── cloudfront-waf.tf          
├── route53.tf                 
├── cloudwatch.tf             
└── cicd.tf                    

```

## Quick Start

### Prerequisites
1. **AWS CLI** configured
2. **Terraform** (>= 1.0) installed
3. **Route 53 hosted zone** for your domain
4. **GitHub repository** with application code
5. **S3 Bucket For State File**
6. **DynamoDb Table for state locking**



### Deploy Infrastructure
```bash
terraform init
terraform validate
terraform plan
terraform apply
```


## Core Components

### **Compute & Application**
- **App Runner Service** - Containerized application hosting
- **Auto-scaling** - Automatic scaling based on demand
- **Health checks** - Application health monitoring

### **Container Registry**
- **ECR Repository** - Docker image storage
- **Lifecycle policies** - Automatic image cleanup
- **Security scanning** - Vulnerability scanning on push

### **Content Delivery & Security**
- **CloudFront Distribution** - Global CDN with caching
- **WAF Web ACL** - Web application firewall
- **IP blocking** - Malicious IP address blocking
- **Rate limiting** - DDoS protection

### **DNS *
- **Route 53 Records** - DNS management

### **Security & Secrets**
- **Secrets Manager** - Secure configuration storage
- **KMS Key** - Encryption key management
- **IAM Roles** - Service access control

### **CI/CD Pipeline**
- **CodePipeline** - Deployment orchestration
- **CodeBuild** - Container build automation
- **S3 Artifacts** - Build artifact storage

### **Monitoring**
- **CloudWatch Logs** - Application and security logging


## Security Features

- **WAF Protection** - Blocks malicious IPs and attacks
- **HTTPS Enforcement** - All traffic encrypted
- **Secrets Management** - No hardcoded credentials
- **IAM Least Privilege** - Minimal required permissions
- **KMS Encryption** - All secrets encrypted at rest

## Monitoring

- **Application logs** - App Runner service logs
- **Performance metrics** - CPU, memory, request counts
- **Health checks** - Service availability monitoring

