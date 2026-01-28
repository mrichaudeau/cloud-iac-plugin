# Supported Input Formats

## Overview

| Format | Extension | Processing |
|--------|-----------|------------|
| Text | - | NLP extraction |
| Markdown | .md | Structure parsing |
| Draw.io | .drawio, .xml | XML parsing |
| Image | .png, .jpg | Visual analysis |
| YAML | .yaml, .yml | Config parsing |

## Markdown Structure

```markdown
# Architecture MyApp

## Components

### Networking
- VPC: 10.0.0.0/16
- 3 Availability Zones
- Public + Private + Database subnets

### Compute
- ECS Fargate cluster
- 2 services: api, worker
- Auto-scaling: 2-10 tasks

### Database
- RDS PostgreSQL 15
- db.r6g.large
- Multi-AZ
```

## YAML Structure

```yaml
architecture:
  provider: aws
  region: eu-west-1
  environment: prod

  components:
    - type: vpc
      config:
        cidr: "10.0.0.0/16"
        az_count: 3

    - type: ecs_service
      name: api
      config:
        cpu: 512
        memory: 1024
```

## Draw.io

The parser extracts:
- Shapes (rectangles, AWS icons)
- Connections (arrows)
- Labels and annotations

## Images

Uses vision to identify:
- Cloud service icons
- Connections between services
- Text annotations

## Provider Detection

| Indicators | Provider |
|------------|----------|
| aws, ec2, s3, rds, lambda, ecs | AWS |
| azure, vm, blob, cosmos, aks | Azure |
| gcp, gce, gcs, bigquery, gke | GCP |

## Environment Detection

| Keywords | Environment |
|----------|-------------|
| prod, production, live | prod |
| staging, stage, preprod | staging |
| dev, development, test | dev |
