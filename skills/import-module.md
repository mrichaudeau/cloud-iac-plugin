# Skill: /import-module

> Importe un module depuis la Cloud IaC Factory dans le projet courant.

---

## Usage

```
/import-module <module_path> [version]
```

### Exemples

```
/import-module aws/networking/vpc
/import-module aws/networking/vpc v1.2.0
/import-module aws/compute/ecs_service latest
```

---

## Workflow

### 1. Consultation du Catalog

```
1.1 Telecharger catalog.json de la factory

1.2 Chercher le module demande
    ├── SI TROUVE → afficher infos
    └── SI NON TROUVE → suggerer alternatives
```

### 2. Affichage des Informations

```
Module: aws/networking/vpc

Versions disponibles:
  - v1.2.0 (latest) ← recommande
  - v1.1.0
  - v1.0.0

Description:
  VPC production-ready avec multi-AZ, NAT Gateway, VPC Endpoints

Dependances:
  - Aucune (module fondation)

Soft Dependencies:
  - aws/networking/vpc_flow_logs
  - aws/networking/vpc_endpoints

Quelle version voulez-vous importer ? [v1.2.0]
```

### 3. Generation du Code d'Import

```hcl
# Module VPC
# Source: cloud_iac_factory/modules/aws/networking/vpc/v1.2.0
# Importe le: 2025-01-28

module "vpc" {
  source = "git::https://github.com/org/cloud_iac_factory.git//modules/aws/networking/vpc/v1.2.0"

  # Variables requises
  project     = var.project
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"

  # Variables optionnelles (valeurs par defaut)
  # az_count           = 2
  # enable_nat_gateway = true
  # enable_flow_logs   = false

  tags = local.mandatory_tags
}
```

### 4. Instructions d'Integration

```
Module importe !

Code genere dans: ./infrastructure/10_networking/vpc.tf

Prochaines etapes:
  1. Adapter les valeurs des variables
  2. Verifier les outputs requis par d'autres modules
  3. terraform init pour telecharger le module
```

---

## Options

| Option | Description | Defaut |
|--------|-------------|--------|
| `version` | Version specifique | latest |
| `--local` | Copier le module localement | false |
| `--minimal` | Exemple minimal | false |
| `--complete` | Exemple complet | true |

---

## Mode Liste

Pour voir tous les modules disponibles :

```
/import-module --list
/import-module --list aws
/import-module --list aws/networking
```

### Output

```
Modules disponibles dans la factory:

aws/networking/
  ├── vpc (v1.2.0)
  ├── security_group (v1.0.0)
  ├── alb (v1.1.0)
  └── route53 (v1.0.0)

aws/compute/
  ├── ecs_cluster (v1.0.0)
  ├── ecs_service (v1.0.0)
  └── lambda_function (v1.0.0)

aws/data/
  ├── rds_instance (v1.0.0)
  ├── s3_bucket (v1.0.0)
  └── dynamodb_table (v1.0.0)

aws/security/
  ├── kms_key (v1.0.0)
  ├── iam_role (v1.0.0)
  └── secrets_manager (v1.0.0)

Total: 12 modules
```

---

## Mode Recherche

```
/import-module --search database
```

### Output

```
Resultats pour "database":

aws/data/rds_instance (v1.0.0)
  RDS instance PostgreSQL/MySQL avec encryption

aws/data/rds_aurora (v1.0.0)
  Aurora cluster avec auto-scaling

aws/data/dynamodb_table (v1.0.0)
  DynamoDB table avec encryption et backup
```

---

## Import Local

Pour copier le module localement (au lieu de reference git) :

```
/import-module aws/networking/vpc --local
```

### Structure Creee

```
./modules/
└── aws/
    └── networking/
        └── vpc/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── versions.tf
            ├── locals.tf
            ├── MODULE_METADATA.yaml
            └── README.md
```

### Code Genere

```hcl
module "vpc" {
  source = "../../modules/aws/networking/vpc"

  project     = var.project
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"

  tags = local.mandatory_tags
}
```

---

## Agents Invoques

| Agent | Role |
|-------|------|
| `factory-sync` | Connexion et lecture de la factory |

---

## Erreurs Courantes

| Erreur | Cause | Solution |
|--------|-------|----------|
| `Module non trouve` | Nom incorrect ou module inexistant | Verifier avec --list |
| `Version non disponible` | Version demandee inexistante | Utiliser --list pour voir versions |
| `Factory inaccessible` | Probleme reseau ou permissions | Verifier config/factory.yaml |

---

## Exemple Complet

```bash
# Lister les modules disponibles
/import-module --list aws/compute

# Output:
aws/compute/
  ├── ecs_cluster (v1.0.0)
  ├── ecs_service (v1.0.0)
  └── lambda_function (v1.0.0)

# Importer un module
/import-module aws/compute/ecs_service

# Output:
Module: aws/compute/ecs_service
Version: v1.0.0

Dependances requises:
  - aws/networking/vpc (detecte: ✓)
  - aws/security/iam_role (detecte: ✗)

⚠️  Module aws/security/iam_role manquant
    Voulez-vous l'importer aussi ? [O/n]

# Apres confirmation:
Modules importes:
  ✓ aws/security/iam_role → ./infrastructure/00_governance/iam_ecs.tf
  ✓ aws/compute/ecs_service → ./infrastructure/30_compute/ecs.tf

Prochaines etapes:
  1. Adapter les variables dans les fichiers generes
  2. terraform init
```
