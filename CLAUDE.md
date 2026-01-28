# CLAUDE.md - IaC Factory Plugin

> **Plugin Claude Code pour la generation automatique d'infrastructure Terraform production-ready**

---

## Contexte du Plugin

Ce plugin permet de generer des infrastructures Terraform **completes et production-ready** a partir d'une description ou d'un schema d'architecture.

### Fonctionnalites

1. **Generation** : Creer une infrastructure complete a partir d'un input minimal
2. **Enrichissement** : Ajouter automatiquement securite, logs, gouvernance
3. **Capitalisation** : Publier les modules valides vers une factory GitHub
4. **Reutilisation** : Importer des modules existants de la factory

---

## Skills Disponibles

| Skill | Description | Usage |
|-------|-------------|-------|
| `/iac:generate-infra` | Genere infrastructure Terraform | `/iac:generate-infra "App web Django avec PostgreSQL"` |
| `/iac:publish-module` | Publie module vers factory | `/iac:publish-module ./modules/my-module` |
| `/iac:import-module` | Importe module depuis factory | `/iac:import-module aws/networking/vpc` |
| `/iac:validate-infra` | Valide securite et compliance | `/iac:validate-infra ./infrastructure` |
| `/iac:estimate-cost` | Estime les couts mensuels | `/iac:estimate-cost ./infrastructure` |

> **Note:** Les skills utilisent le namespace `iac:` defini dans `.claude-plugin/plugin.json`

---

## Workflow de Generation

Quand un utilisateur demande de generer une infrastructure :

### 1. Parsing de l'Input

1. Identifier le type d'input (texte, schema, draw.io, image)
2. Extraire les composants explicitement mentionnes
3. Detecter le contexte :
   - Provider (AWS, Azure, GCP)
   - Environnement (dev, staging, prod)
   - Region
   - Secteur d'activite
   - Criticite

### 2. Enrichissement Automatique

Consulter dans l'ordre :
1. `docs/03-ENRICHMENT.md` - Logique d'enrichissement
2. `docs/07-GOVERNANCE.md` - Regles de gouvernance
3. `config/defaults.yaml` - Valeurs par defaut

Pour chaque composant :
- Ajouter les **hard_dependencies** (obligatoires)
- Evaluer les **soft_dependencies** (selon contexte)
- Injecter la **gouvernance** selon l'environnement

### 3. Generation du Code

Creer la structure :
```
./infrastructure/
├── _backend.tf
├── _providers.tf
├── _variables.tf
├── _locals.tf
├── _outputs.tf
├── 00_governance/
├── 10_networking/
├── 20_security/
├── 30_compute/
├── 40_data/
├── 50_loadbalancing/
├── 60_monitoring/
└── environments/
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

### 4. Validation

- Verifier les guardrails de securite
- Valider contre la factory (anti-hallucination)
- Generer le rapport de generation

---

## Regles de Securite Absolues

### JAMAIS generer :

1. **Credentials en dur**
   ```hcl
   # INTERDIT
   password = "mysecret"

   # CORRECT
   password = data.aws_secretsmanager_secret_version.db.secret_string
   ```

2. **Security Groups ouverts sur ports sensibles**
   ```hcl
   # INTERDIT sur ports 22, 3389, 3306, 5432, etc.
   cidr_blocks = ["0.0.0.0/0"]

   # CORRECT
   source_security_group_id = aws_security_group.bastion.id
   ```

3. **IAM trop permissif**
   ```hcl
   # INTERDIT
   actions   = ["*"]
   resources = ["*"]

   # CORRECT
   actions   = ["s3:GetObject", "s3:ListBucket"]
   resources = [aws_s3_bucket.data.arn]
   ```

4. **Donnees non chiffrees**
   ```hcl
   # OBLIGATOIRE
   storage_encrypted = true
   kms_key_id        = module.kms.key_arn
   ```

---

## Conventions de Nommage

### Pattern
```
{project}-{environment}-{component}-{resource_type}-{identifier}
```

### Exemples
```
myapp-prod-web-alb-main
myapp-prod-api-ecs-service
myapp-prod-data-rds-primary
```

### Regles
- Minuscules uniquement
- Separateur: tiret (`-`)
- Pas de caracteres speciaux

---

## Tags Obligatoires

```hcl
locals {
  mandatory_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCenter  = var.cost_center
    ManagedBy   = "terraform"
  }
}
```

---

## Gouvernance par Environnement

### TOUJOURS (tous environnements)
- IAM Baseline
- Budgets avec alertes
- CloudTrail
- GuardDuty
- KMS Keys
- CloudWatch Logs

### SI STAGING ou PROD
- VPC Flow Logs
- Security Hub
- AWS Config
- CloudWatch Alarms
- AWS Backup

### SI PROD
- Multi-AZ pour stateful
- WAF si Internet
- Deletion Protection

---

## Structure de Sortie Standard

```
./infrastructure/
├── _backend.tf           # Backend S3 + DynamoDB + KMS
├── _providers.tf         # AWS provider + versions
├── _variables.tf         # Variables globales
├── _locals.tf            # Naming, tags
├── _outputs.tf           # Outputs principaux
│
├── 00_governance/        # 1er - Fondation
│   ├── iam_foundation.tf
│   ├── budgets.tf
│   ├── cloudtrail.tf
│   ├── guardduty.tf
│   └── kms.tf
│
├── 10_networking/        # 2eme
│   ├── vpc.tf
│   ├── subnets.tf
│   └── nat.tf
│
├── 20_security/          # 3eme
│   ├── security_groups.tf
│   └── secrets.tf
│
├── 30_compute/           # 4eme
│   └── [ecs.tf | lambda.tf]
│
├── 40_data/              # 5eme
│   ├── rds.tf
│   └── s3.tf
│
├── 50_loadbalancing/     # 6eme
│   └── alb.tf
│
├── 60_monitoring/        # 7eme - Dernier
│   ├── cloudwatch.tf
│   └── sns.tf
│
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
│
├── README.md
├── DECISIONS.md          # Justifications des choix
└── COST_ESTIMATE.md      # Estimation des couts
```

---

## Cloud IaC Factory

La factory est un repo GitHub centralise : `cloud_iac_factory`

### Consulter le Catalog
Avant de generer, verifier les modules disponibles dans `catalog.json` de la factory.

### Utiliser un Module de la Factory
```hcl
module "vpc" {
  source = "git::https://github.com/mrichaudeau/cloud_iac_factory.git//modules/aws/networking/vpc/v1.2.0"

  project     = var.project
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
}
```

### Publier vers la Factory
Apres validation manuelle, utiliser `/iac:publish-module` pour creer une PR vers la factory.

---

## Rapport de Generation

Apres chaque generation, produire :

```markdown
# Rapport de Generation

## Resume
| Attribut | Valeur |
|----------|--------|
| Date | {date} |
| Provider | AWS |
| Environnement | prod |
| Criticite | high |

## Composants Generes

### Explicites (demandes)
- ECS Fargate
- RDS PostgreSQL

### Ajoutes Automatiquement
| Composant | Justification |
|-----------|---------------|
| NAT Gateway | Acces Internet subnets prives |
| VPC Flow Logs | Obligatoire en prod |
| GuardDuty | Gouvernance obligatoire |

## Hypotheses
1. Region: eu-west-1 (defaut)
2. CIDR VPC: 10.0.0.0/16

## Estimation Couts
~$525/mois

## Prochaines Etapes
1. [ ] Revoir les Security Groups
2. [ ] Configurer les secrets
3. [ ] terraform init && plan
```

---

## Documentation de Reference

| Document | Description |
|----------|-------------|
| `docs/00-VISION.md` | Vision et objectifs |
| `docs/01-ARCHITECTURE.md` | Architecture technique |
| `docs/02-WORKFLOW.md` | Workflow de generation |
| `docs/03-ENRICHMENT.md` | Logique d'enrichissement |
| `docs/04-FACTORY.md` | Specification factory |
| `docs/05-SECURITY.md` | Guardrails securite |
| `docs/06-CONVENTIONS.md` | Conventions nommage |
| `docs/07-GOVERNANCE.md` | Regles gouvernance |
| `docs/08-ROADMAP.md` | Plan implementation |

---

## Commandes Terraform

```bash
# Initialisation
terraform init
terraform init -backend-config=backend.hcl

# Validation
terraform validate
terraform fmt -check -recursive

# Planification
terraform plan -var-file=environments/prod.tfvars
terraform plan -out=tfplan

# Application
terraform apply tfplan
# JAMAIS: terraform apply -auto-approve en prod
```
