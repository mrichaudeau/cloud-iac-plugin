# Cloud IaC Factory

> **Version** : 1.0.0
> **Date** : Janvier 2025

---

## Objectif

La **Cloud IaC Factory** est un repository GitHub centralise qui :
- Stocke les modules Terraform valides et testes
- Permet la reutilisation entre projets
- Gere le versioning semantique
- S'alimente automatiquement des projets deployes

---

## Structure du Repository

```
cloud_iac_factory/
├── .github/
│   └── workflows/
│       ├── validate-module.yml      # terraform fmt, validate, tflint
│       ├── test-module.yml          # terratest si present
│       ├── security-scan.yml        # checkov, tfsec
│       ├── update-catalog.yml       # MAJ catalog.json apres merge
│       └── release-module.yml       # Tag + release automatique
│
├── modules/
│   ├── aws/
│   │   ├── networking/
│   │   │   ├── vpc/
│   │   │   │   ├── v1.0.0/
│   │   │   │   │   ├── main.tf
│   │   │   │   │   ├── variables.tf
│   │   │   │   │   ├── outputs.tf
│   │   │   │   │   ├── versions.tf
│   │   │   │   │   ├── locals.tf
│   │   │   │   │   ├── MODULE_METADATA.yaml
│   │   │   │   │   ├── README.md
│   │   │   │   │   └── examples/
│   │   │   │   │       ├── minimal/
│   │   │   │   │       └── complete/
│   │   │   │   └── CHANGELOG.md
│   │   │   ├── security_group/
│   │   │   ├── alb/
│   │   │   └── route53/
│   │   ├── compute/
│   │   │   ├── ecs_cluster/
│   │   │   ├── ecs_service/
│   │   │   ├── lambda_function/
│   │   │   └── ec2_instance/
│   │   ├── data/
│   │   │   ├── rds_instance/
│   │   │   ├── rds_aurora/
│   │   │   ├── s3_bucket/
│   │   │   ├── dynamodb_table/
│   │   │   └── elasticache/
│   │   ├── security/
│   │   │   ├── kms_key/
│   │   │   ├── secrets_manager/
│   │   │   ├── iam_role/
│   │   │   └── iam_policy/
│   │   ├── messaging/
│   │   │   ├── sqs_queue/
│   │   │   ├── sns_topic/
│   │   │   └── eventbridge_rule/
│   │   ├── observability/
│   │   │   ├── cloudwatch_log_group/
│   │   │   ├── cloudwatch_alarm/
│   │   │   └── cloudwatch_dashboard/
│   │   └── governance/
│   │       ├── cloudtrail/
│   │       ├── guardduty/
│   │       ├── security_hub/
│   │       ├── config_recorder/
│   │       └── budgets/
│   │
│   ├── azure/
│   │   ├── networking/
│   │   ├── compute/
│   │   ├── data/
│   │   └── security/
│   │
│   └── gcp/
│       ├── networking/
│       ├── compute/
│       ├── data/
│       └── security/
│
├── patterns/                        # Architectures completes
│   ├── three-tier-webapp/
│   │   ├── PATTERN_METADATA.yaml
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── serverless-api/
│   └── data-platform/
│
├── policies/                        # Policy as Code
│   ├── security/
│   │   ├── no-public-s3.rego
│   │   ├── encryption-required.rego
│   │   └── no-open-security-groups.rego
│   ├── finops/
│   │   ├── mandatory-tags.rego
│   │   └── budget-required.rego
│   └── compliance/
│       ├── cis-aws.rego
│       └── gdpr.rego
│
├── catalog.json                     # Index auto-genere
├── CONTRIBUTING.md
└── README.md
```

---

## Catalog.json

Le fichier `catalog.json` est l'index central de tous les modules disponibles.

### Format

```json
{
  "version": "1.0.0",
  "last_updated": "2025-01-28T10:00:00Z",
  "modules": {
    "aws/networking/vpc": {
      "latest": "1.2.0",
      "versions": ["1.0.0", "1.1.0", "1.2.0"],
      "description": "VPC production-ready avec multi-AZ, NAT, endpoints",
      "category": "networking",
      "provider": "aws",
      "dependencies": [],
      "soft_dependencies": ["aws/networking/vpc_flow_logs", "aws/networking/vpc_endpoints"],
      "metadata_path": "modules/aws/networking/vpc/v1.2.0/MODULE_METADATA.yaml"
    },
    "aws/compute/ecs_service": {
      "latest": "1.0.0",
      "versions": ["1.0.0"],
      "description": "Service ECS Fargate avec auto-scaling",
      "category": "compute",
      "provider": "aws",
      "dependencies": ["aws/networking/vpc", "aws/security/iam_role"],
      "soft_dependencies": ["aws/networking/alb"],
      "metadata_path": "modules/aws/compute/ecs_service/v1.0.0/MODULE_METADATA.yaml"
    }
  },
  "patterns": {
    "three-tier-webapp": {
      "latest": "1.0.0",
      "providers": ["aws"],
      "description": "Architecture web 3-tiers classique",
      "modules_used": [
        "aws/networking/vpc",
        "aws/networking/alb",
        "aws/compute/ecs_service",
        "aws/data/rds_instance"
      ]
    }
  }
}
```

### Mise a Jour Automatique

Le workflow `update-catalog.yml` met a jour `catalog.json` automatiquement :
- Apres chaque merge sur main
- Scan tous les dossiers `modules/`
- Extrait les infos de `MODULE_METADATA.yaml`
- Genere le nouveau `catalog.json`

---

## MODULE_METADATA.yaml

Chaque module doit avoir un fichier `MODULE_METADATA.yaml` :

```yaml
schema_version: "2.0"

module:
  name: "vpc"
  version: "1.2.0"
  provider: "aws"
  category: "networking"
  sub_category: "foundation"

  description: |
    Module VPC production-ready avec support multi-AZ,
    NAT Gateway, VPC Endpoints, et Flow Logs.

  # Classification pour l'IA
  classification:
    tier: "foundation"           # foundation, application, utility
    criticality: "high"          # low, medium, high, critical
    data_sensitivity: "internal" # public, internal, confidential, restricted

  # Dependances OBLIGATOIRES
  hard_dependencies: []

  # Dependances RECOMMANDEES
  soft_dependencies:
    - module: "vpc_flow_logs"
      reason: "Audit et compliance networking"
      environments: ["staging", "prod"]

    - module: "vpc_endpoints"
      reason: "Reduction des couts et securite"
      condition: "if private_subnets exist"

  # Ce que ce module expose
  provides:
    - name: "vpc_id"
      type: "string"
      description: "ID du VPC cree"
      consumers: ["security_groups", "ec2", "eks", "rds"]

    - name: "private_subnet_ids"
      type: "list(string)"
      description: "IDs des subnets prives"
      consumers: ["ecs", "eks", "rds", "lambda"]

  # Valeurs par defaut par environnement
  defaults_by_environment:
    dev:
      nat_gateway_count: 1
      enable_flow_logs: false

    staging:
      nat_gateway_count: 1
      enable_flow_logs: true

    prod:
      nat_gateway_count: "per_az"
      enable_flow_logs: true

  # Estimation des couts
  cost_factors:
    - resource: "nat_gateway"
      unit: "per_gateway_per_hour"
      approximate_cost: "$0.045/hour + data transfer"

  # Exemples d'utilisation
  usage_examples:
    minimal: |
      module "vpc" {
        source = "git::https://github.com/org/cloud_iac_factory.git//modules/aws/networking/vpc/v1.2.0"

        project     = "myapp"
        environment = "dev"
        vpc_cidr    = "10.0.0.0/16"
      }
```

---

## Workflow de Publication

### Via le Skill /publish-module

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     WORKFLOW PUBLICATION MODULE                              │
└─────────────────────────────────────────────────────────────────────────────┘

 Utilisateur: /publish-module ./modules/my-custom-vpc

 1. VALIDATION LOCALE
    ├── Verifier structure (main.tf, variables.tf, outputs.tf, versions.tf)
    ├── Verifier MODULE_METADATA.yaml present
    ├── terraform fmt -check
    ├── terraform validate
    └── tflint

 2. COMPARAISON AVEC FACTORY
    ├── Telecharger catalog.json
    ├── Chercher si module existe
    │   ├── SI NOUVEAU: proposer v1.0.0
    │   └── SI EXISTE: calculer diff, proposer version bump
    └── Afficher le diff a l'utilisateur

 3. CREATION DE LA PR
    ├── Creer branche: feat/module-{name}-{version}
    ├── Copier fichiers du module
    ├── Generer/mettre a jour CHANGELOG.md
    └── Ouvrir PR avec description auto-generee

 4. NOTIFICATION
    └── Afficher lien de la PR

 [REVIEW HUMAINE REQUISE]

 5. APRES MERGE
    ├── CI/CD: validation + tests
    ├── update-catalog.yml: MAJ catalog.json
    └── release-module.yml: Tag git + release
```

### Versioning Semantique

| Type de changement | Version bump | Exemple |
|--------------------|--------------|---------|
| Breaking change | MAJOR | 1.0.0 → 2.0.0 |
| Nouvelle fonctionnalite | MINOR | 1.0.0 → 1.1.0 |
| Bug fix | PATCH | 1.0.0 → 1.0.1 |

### Detection Automatique du Bump

```
SI nouvelles variables REQUIRED ajoutees → MAJOR
SI variables OPTIONAL supprimees → MAJOR
SI outputs supprimes → MAJOR
SI nouvelles fonctionnalites → MINOR
SINON → PATCH
```

---

## CI/CD de la Factory

### validate-module.yml

```yaml
name: Validate Module

on:
  pull_request:
    paths:
      - 'modules/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Format Check
        run: terraform fmt -check -recursive modules/

      - name: Find Changed Modules
        id: changed
        run: |
          # Detecter les modules modifies

      - name: Validate Each Module
        run: |
          for module in ${{ steps.changed.outputs.modules }}; do
            cd $module
            terraform init -backend=false
            terraform validate
          done

      - name: TFLint
        uses: terraform-linters/setup-tflint@v4
        run: tflint --recursive

      - name: Checkov Security Scan
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: modules/
```

### update-catalog.yml

```yaml
name: Update Catalog

on:
  push:
    branches: [main]
    paths:
      - 'modules/**'

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate Catalog
        run: |
          python scripts/generate-catalog.py > catalog.json

      - name: Commit Catalog
        run: |
          git config user.name "github-actions"
          git config user.email "actions@github.com"
          git add catalog.json
          git commit -m "chore: update catalog.json" || exit 0
          git push
```

---

## Utilisation depuis le Plugin

### Import d'un Module

```hcl
# Dans le code genere
module "vpc" {
  source = "git::https://github.com/org/cloud_iac_factory.git//modules/aws/networking/vpc/v1.2.0"

  project     = var.project
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
  az_count    = local.is_production ? 3 : 2

  tags = local.mandatory_tags
}
```

### Consultation du Catalog

Le skill `/import-module` permet de :
1. Lister les modules disponibles
2. Afficher les versions
3. Voir les dependances
4. Generer le code d'import

---

## Liens

- [Architecture](01-ARCHITECTURE.md)
- [Workflow](02-WORKFLOW.md)
- [Conventions](06-CONVENTIONS.md)
