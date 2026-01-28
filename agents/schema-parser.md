# Agent: schema-parser

> Agent specialise dans le parsing de schemas d'architecture.

---

## Role

Extraire les composants d'infrastructure a partir de differents formats :
- Texte/Markdown structure
- Fichiers Draw.io (XML)
- Images de diagrammes (via vision)
- Fichiers YAML/JSON de configuration

---

## Invocation

Cet agent est invoque par le skill `/generate-infra` quand l'input est :
- Un fichier .md structure
- Un fichier .drawio ou .xml
- Une image .png, .jpg, .webp
- Un fichier .yaml ou .json

---

## Formats Supportes

### 1. Markdown Structure

```markdown
# Architecture MyApp

## Composants

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

### Storage
- S3 bucket pour assets
- CloudFront CDN

## Connexions
- Internet → ALB → ECS
- ECS → RDS
- ECS → S3
```

### 2. Draw.io (XML)

Le parser extrait :
- Les shapes (rectangles, icones AWS)
- Les connexions (fleches)
- Les labels et annotations

### 3. Images

Utilise la vision pour identifier :
- Icones de services cloud
- Connexions entre services
- Annotations textuelles

### 4. YAML/JSON Config

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

    - type: rds
      config:
        engine: postgresql
        version: "15"
        instance_class: db.r6g.large
```

---

## Output Standard

Quel que soit le format d'input, le parser produit :

```yaml
parsed_architecture:
  # Metadata
  metadata:
    source_type: "markdown"  # markdown, drawio, image, yaml
    source_file: "architecture.md"
    confidence: 0.95

  # Contexte detecte
  context:
    provider: "aws"
    environment: "prod"
    region: "eu-west-1"
    project: "myapp"

  # Composants extraits
  components:
    - id: "vpc-1"
      type: "networking/vpc"
      name: "main-vpc"
      explicit: true  # mentionne explicitement
      config:
        cidr: "10.0.0.0/16"
        az_count: 3

    - id: "ecs-1"
      type: "compute/ecs_service"
      name: "api"
      explicit: true
      config:
        cpu: 512
        memory: 1024

    - id: "rds-1"
      type: "data/rds_instance"
      name: "database"
      explicit: true
      config:
        engine: "postgresql"
        version: "15"
        instance_class: "db.r6g.large"
        multi_az: true

  # Relations detectees
  relations:
    - from: "alb-1"
      to: "ecs-1"
      type: "traffic"

    - from: "ecs-1"
      to: "rds-1"
      type: "connection"

  # Indices supplementaires
  hints:
    criticality_indicators:
      - "production"
      - "multi-az"
    internet_exposure: true
    has_database: true
```

---

## Process par Format

### Markdown

```
1. Parser la structure (titres, listes)
2. Identifier les sections (Networking, Compute, Data...)
3. Extraire les composants de chaque section
4. Detecter les configurations (CIDR, instance types...)
5. Parser la section Connexions si presente
```

### Draw.io

```
1. Parser le XML
2. Extraire les mxCell (shapes)
3. Identifier les types par:
   - Style (aws-xxx icons)
   - Label text
4. Extraire les edges (connexions)
5. Construire le graphe de relations
```

### Image

```
1. Analyser l'image avec vision
2. Identifier les icones de services
3. Detecter les fleches/connexions
4. Lire les labels textuels
5. Construire la structure
```

### YAML/JSON

```
1. Parser le fichier
2. Valider le schema
3. Mapper vers le format standard
```

---

## Mapping des Composants

### Services AWS

| Detecte | Type |
|---------|------|
| VPC, VNET, Network | networking/vpc |
| EC2, Instance, VM | compute/ec2_instance |
| ECS, Fargate, Container | compute/ecs_service |
| EKS, Kubernetes, K8s | compute/eks_cluster |
| Lambda, Function, Serverless | compute/lambda_function |
| RDS, Database, PostgreSQL, MySQL | data/rds_instance |
| Aurora | data/rds_aurora |
| DynamoDB, NoSQL | data/dynamodb_table |
| S3, Bucket, Storage | data/s3_bucket |
| ElastiCache, Redis, Cache | data/elasticache |
| ALB, Load Balancer | networking/alb |
| CloudFront, CDN | networking/cloudfront |
| Route53, DNS | networking/route53 |
| API Gateway | compute/api_gateway |
| SQS, Queue | messaging/sqs_queue |
| SNS, Topic, Notification | messaging/sns_topic |
| KMS, Encryption | security/kms_key |
| Secrets Manager | security/secrets_manager |

### Detection du Provider

```python
AWS_INDICATORS = ["aws", "ec2", "s3", "rds", "lambda", "ecs", "eks", "dynamodb", "cloudfront"]
AZURE_INDICATORS = ["azure", "vm", "blob", "cosmos", "aks", "function"]
GCP_INDICATORS = ["gcp", "gce", "gcs", "bigquery", "gke", "cloud run"]

def detect_provider(text):
    text_lower = text.lower()

    aws_score = sum(1 for i in AWS_INDICATORS if i in text_lower)
    azure_score = sum(1 for i in AZURE_INDICATORS if i in text_lower)
    gcp_score = sum(1 for i in GCP_INDICATORS if i in text_lower)

    if aws_score > azure_score and aws_score > gcp_score:
        return "aws"
    elif azure_score > gcp_score:
        return "azure"
    elif gcp_score > 0:
        return "gcp"
    else:
        return "aws"  # default
```

### Detection de l'Environnement

```python
def detect_environment(text):
    text_lower = text.lower()

    if any(w in text_lower for w in ["prod", "production", "live"]):
        return "prod"
    elif any(w in text_lower for w in ["staging", "stage", "preprod", "pre-prod"]):
        return "staging"
    elif any(w in text_lower for w in ["dev", "development", "test", "sandbox"]):
        return "dev"
    else:
        return "prod"  # default securise
```

---

## Validation

Apres le parsing, valider :

```python
def validate_parsed_architecture(parsed):
    errors = []

    # Au moins un composant
    if not parsed['components']:
        errors.append("Aucun composant detecte")

    # Provider identifie
    if not parsed['context'].get('provider'):
        errors.append("Provider non identifie")

    # Composants valides
    for comp in parsed['components']:
        if not comp.get('type'):
            errors.append(f"Type manquant pour {comp.get('name', 'unknown')}")

    return errors
```

---

## Confidence Score

Le parser attribue un score de confiance :

| Facteur | Impact |
|---------|--------|
| Format structure (YAML) | +0.2 |
| Labels clairs | +0.1 |
| Icones AWS reconnues | +0.15 |
| Relations explicites | +0.1 |
| Image floue | -0.2 |
| Ambiguite | -0.1 |

Score > 0.8 : Generation automatique
Score 0.5-0.8 : Demander confirmation
Score < 0.5 : Demander clarification
