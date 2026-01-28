# Architecture Simple - API Web

> Exemple d'architecture pour une API web simple

---

## Contexte

- **Provider**: AWS
- **Environment**: prod
- **Region**: eu-west-1
- **Project**: myapi

---

## Composants

### Networking
- VPC: 10.0.0.0/16
- 3 Availability Zones
- Public + Private + Database subnets
- NAT Gateway (1 par AZ en prod)

### Compute
- ECS Fargate cluster
- 1 service: api
- CPU: 512, Memory: 1024
- Desired count: 3
- Auto-scaling: 2-10 tasks

### Load Balancer
- Application Load Balancer
- HTTPS (443) avec certificat ACM
- Health check: /health

### Database
- RDS PostgreSQL 15
- Instance: db.r6g.large
- Multi-AZ: oui
- Storage: 100 GB, encrypted

### Cache
- ElastiCache Redis
- Instance: cache.r6g.medium
- Cluster mode: disabled

### Storage
- S3 bucket pour assets statiques
- Versioning active
- Lifecycle: transition vers Glacier apres 90 jours

---

## Connexions

```
Internet → ALB → ECS (api)
ECS (api) → RDS PostgreSQL
ECS (api) → ElastiCache Redis
ECS (api) → S3 (assets)
```

---

## Tags

- Project: myapi
- Environment: prod
- Owner: platform-team
- CostCenter: TECH-001
