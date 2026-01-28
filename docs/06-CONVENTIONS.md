# Conventions de Nommage

> **Version** : 1.0.0
> **Date** : Janvier 2025

---

## Pattern General

### Ressources AWS

```
{project}-{environment}-{component}-{resource_type}-{identifier}
```

| Segment | Description | Exemples |
|---------|-------------|----------|
| `project` | Nom du projet (court) | `myapp`, `platform`, `api` |
| `environment` | Environnement | `dev`, `staging`, `prod` |
| `component` | Composant fonctionnel | `web`, `api`, `worker`, `data` |
| `resource_type` | Type de ressource | `vpc`, `alb`, `rds`, `sg` |
| `identifier` | Identifiant unique | `main`, `primary`, `01` |

### Exemples

```
myapp-prod-web-alb-main
myapp-prod-api-ecs-service
myapp-prod-data-rds-primary
myapp-prod-web-sg-app
```

---

## Regles Generales

1. **Minuscules** uniquement
2. **Separateur** : tiret (`-`) uniquement
3. **Alphanumeriques** : lettres `a-z` et chiffres `0-9`
4. **Pas de caracteres speciaux** : pas de `_`, `.`, `/`
5. **Longueur** : max 63 caracteres (limite DNS)

---

## Abreviations Standard

| Service | Abreviation |
|---------|-------------|
| VPC | `vpc` |
| Subnet | `subnet` |
| Security Group | `sg` |
| Application Load Balancer | `alb` |
| Network Load Balancer | `nlb` |
| ECS Cluster | `ecs` |
| ECS Service | `svc` |
| ECS Task Definition | `task` |
| Lambda Function | `fn` |
| RDS Instance | `rds` |
| Aurora Cluster | `aurora` |
| S3 Bucket | `s3` |
| DynamoDB Table | `ddb` |
| ElastiCache | `cache` |
| KMS Key | `kms` |
| Secrets Manager | `secret` |
| IAM Role | `role` |
| IAM Policy | `policy` |
| CloudWatch Log Group | `log` |
| CloudWatch Alarm | `alarm` |
| SNS Topic | `sns` |
| SQS Queue | `sqs` |
| EventBridge Rule | `rule` |
| Route53 Zone | `zone` |
| ACM Certificate | `cert` |
| WAF Web ACL | `waf` |
| NAT Gateway | `nat` |
| Internet Gateway | `igw` |
| VPC Endpoint | `vpce` |

---

## Conventions Terraform

### Nommage des Ressources

```hcl
# Ressource unique dans un module: "this" ou "main"
resource "aws_vpc" "this" { }
resource "aws_vpc" "main" { }

# Groupe logique
resource "aws_subnet" "private" { }
resource "aws_subnet" "public" { }
resource "aws_subnet" "database" { }

# Multiples instances
resource "aws_nat_gateway" "this" {
  count = var.nat_gateway_count
  # ...
}

# Avec for_each
resource "aws_security_group_rule" "ingress" {
  for_each = var.ingress_rules
  # ...
}
```

### Nommage des Variables

```hcl
# Prefixe enable_ pour boolean
variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "enable_flow_logs" {
  type    = bool
  default = false
}

# Suffixe _config pour objets complexes
variable "database_config" {
  type = object({
    instance_class = string
    engine_version = string
    multi_az       = bool
  })
}

# Suffixe _list ou pluriel pour listes
variable "availability_zones" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

# Suffixe _map pour maps
variable "tags_map" {
  type = map(string)
}
```

### Nommage des Outputs

```hcl
# Type + _id
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

# Type + _arn
output "role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

# Pluriel pour listes
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "security_group_ids" {
  description = "List of security group IDs"
  value       = [aws_security_group.app.id, aws_security_group.db.id]
}
```

### Nommage des Modules

```hcl
# Nom descriptif du composant
module "vpc" {
  source = "../../modules/aws/networking/vpc"
}

module "app_security_group" {
  source = "../../modules/aws/networking/security_group"
}

module "database" {
  source = "../../modules/aws/data/rds_instance"
}
```

---

## Structure des Fichiers

### Fichiers Standard d'un Module

| Fichier | Contenu |
|---------|---------|
| `main.tf` | Ressources principales |
| `variables.tf` | Variables avec validation |
| `outputs.tf` | Outputs documentes |
| `versions.tf` | Contraintes de versions |
| `locals.tf` | Calculs locaux |
| `data.tf` | Data sources (optionnel) |
| `MODULE_METADATA.yaml` | Metadonnees pour l'IA |
| `README.md` | Documentation |

### Fichiers Prefixes (Infrastructure)

```
_backend.tf      # Configuration backend (commence par _)
_providers.tf    # Configuration providers
_variables.tf    # Variables globales
_locals.tf       # Locals globaux
_outputs.tf      # Outputs principaux
_data.tf         # Data sources globaux
```

### Dossiers Prefixes Numeriques

```
00_governance/   # 1er (fondation)
10_networking/   # 2eme
20_security/     # 3eme
30_compute/      # 4eme
40_data/         # 5eme
50_loadbalancing/# 6eme
60_monitoring/   # 7eme (dernier)
```

---

## Tags Obligatoires

### Tags Requis sur TOUTES les Ressources

```hcl
locals {
  mandatory_tags = {
    Project     = var.project          # Nom du projet
    Environment = var.environment      # dev, staging, prod
    Owner       = var.owner            # Equipe responsable
    CostCenter  = var.cost_center      # Centre de couts
    ManagedBy   = "terraform"          # Toujours "terraform"
  }
}
```

### Application des Tags

```hcl
resource "aws_instance" "this" {
  # ... configuration ...

  tags = merge(
    local.mandatory_tags,
    var.additional_tags,
    {
      Name      = "${local.name_prefix}-instance"
      Component = "web"
    }
  )
}
```

### Tags Recommandes

```hcl
{
  DataClassification = "internal"      # public, internal, confidential, restricted
  Compliance         = "pci-dss"       # Si applicable
  BackupPolicy       = "daily"         # daily, weekly, none
  Criticality        = "high"          # low, medium, high, critical
}
```

---

## Locals Standards

```hcl
locals {
  # Prefixe de nommage
  name_prefix = "${var.project}-${var.environment}"

  # Detection environnement
  is_production = var.environment == "prod"
  is_staging    = var.environment == "staging"
  is_dev        = var.environment == "dev"

  # Availability Zones
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Tags communs
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "terraform"
  }
}
```

---

## Exemples Complets

### Nommage VPC

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet-private-${local.azs[count.index]}"
    Tier = "private"
  })
}
```

### Nommage Security Group

```hcl
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-sg-app"
  description = "Security group for application layer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-sg-app"
    Component = "application"
  })
}
```

### Nommage RDS

```hcl
resource "aws_db_instance" "this" {
  identifier = "${local.name_prefix}-rds-primary"

  # ... configuration ...

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-rds-primary"
    Component   = "database"
    Engine      = "postgresql"
  })
}
```

---

## Liens

- [Securite](05-SECURITY.md)
- [Gouvernance](07-GOVERNANCE.md)
- [Architecture](01-ARCHITECTURE.md)
