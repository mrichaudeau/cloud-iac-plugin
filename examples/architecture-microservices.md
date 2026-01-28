# Architecture Microservices - E-commerce Platform

> Exemple d'architecture microservices complete

---

## Contexte

- **Provider**: AWS
- **Environment**: prod
- **Region**: eu-west-1
- **Project**: ecommerce

---

## Composants

### Networking
- VPC: 10.0.0.0/16
- 3 Availability Zones
- Public subnets (ALB, NAT)
- Private subnets (ECS, Lambda)
- Database subnets (RDS, ElastiCache)
- VPC Endpoints: S3, ECR, Secrets Manager

### API Gateway
- API Gateway REST
- Custom domain: api.example.com
- WAF protection

### Compute - ECS Services

#### Service: users
- CPU: 512, Memory: 1024
- Replicas: 3
- Auto-scaling: 2-6
- Path: /users/*

#### Service: products
- CPU: 256, Memory: 512
- Replicas: 2
- Auto-scaling: 2-4
- Path: /products/*

#### Service: orders
- CPU: 512, Memory: 1024
- Replicas: 3
- Auto-scaling: 2-8
- Path: /orders/*

#### Service: payments
- CPU: 256, Memory: 512
- Replicas: 2
- Auto-scaling: 2-4
- Path: /payments/*

### Compute - Lambda Functions

#### Function: image-processor
- Runtime: python3.11
- Memory: 1024
- Timeout: 30s
- Trigger: S3 (product-images bucket)

#### Function: notification-sender
- Runtime: nodejs18.x
- Memory: 256
- Timeout: 10s
- Trigger: SQS (notifications queue)

### Databases

#### RDS - Users DB
- Engine: PostgreSQL 15
- Instance: db.r6g.large
- Multi-AZ: oui
- Read replicas: 1

#### RDS - Orders DB
- Engine: PostgreSQL 15
- Instance: db.r6g.xlarge
- Multi-AZ: oui
- Read replicas: 2

#### DynamoDB - Products Catalog
- Partition key: product_id
- Sort key: category
- GSI: category-price-index
- On-demand capacity

### Cache
- ElastiCache Redis Cluster
- Node type: cache.r6g.large
- Nodes: 3 (1 primary, 2 replicas)
- Cluster mode: enabled

### Storage

#### S3 - Product Images
- Versioning: enabled
- Lifecycle: Intelligent-Tiering
- CloudFront distribution

#### S3 - Order Documents
- Versioning: enabled
- Encryption: KMS
- Retention: 7 years

### Messaging

#### SQS - Order Queue
- FIFO: true
- DLQ: enabled
- Retention: 14 days

#### SQS - Notification Queue
- FIFO: false
- DLQ: enabled

#### SNS - Order Events
- Topics: order-created, order-completed, order-cancelled
- Subscriptions: Lambda, SQS

#### EventBridge
- Rule: daily-reports
- Schedule: cron(0 8 * * ? *)
- Target: Lambda (report-generator)

### CDN
- CloudFront distribution
- Origins: S3, ALB
- SSL: ACM certificate
- WAF: enabled

### DNS
- Route53 hosted zone: example.com
- Records:
  - api.example.com → API Gateway
  - www.example.com → CloudFront
  - admin.example.com → ALB

---

## Connexions

```
Internet → CloudFront → S3 (static)
Internet → CloudFront → ALB → ECS (services)
Internet → API Gateway → Lambda / ALB

ECS (users) → RDS (users-db)
ECS (orders) → RDS (orders-db)
ECS (products) → DynamoDB (products)
ECS (*) → ElastiCache Redis

Lambda (image-processor) → S3 (product-images)
Lambda (notification-sender) → SES

SNS (order-events) → SQS (order-queue)
SNS (order-events) → Lambda (analytics)
```

---

## Security Requirements

- WAF sur CloudFront et API Gateway
- Encryption at rest sur toutes les donnees
- TLS 1.3 minimum
- Secrets dans Secrets Manager
- IAM roles avec least privilege

---

## Criticality

- **Level**: High
- **RTO**: 1 heure
- **RPO**: 5 minutes
- Cross-region backup: oui (us-east-1)

---

## Tags

- Project: ecommerce
- Environment: prod
- Owner: ecommerce-team
- CostCenter: ECOM-001
- DataClassification: confidential
