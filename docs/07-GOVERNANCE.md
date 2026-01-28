# Regles de Gouvernance

> **Version** : 1.0.0
> **Date** : Janvier 2025

---

## Principe

La gouvernance cloud est **automatiquement injectee** dans chaque infrastructure generee. Elle garantit :
- La tracabilite des actions (audit)
- Le controle des couts (finops)
- La securite de base (detection des menaces)
- La conformite (compliance)

---

## Composants de Gouvernance

### TOUJOURS Inclus (100% des generations)

| Categorie | Composant AWS | Description |
|-----------|---------------|-------------|
| **Identite** | IAM Roles, Policies | Roles admin, developer, readonly |
| **Couts** | Budgets | Alertes a 50%, 80%, 100% |
| **Couts** | Cost Anomaly Detection | Detection automatique d'anomalies |
| **Audit** | CloudTrail | Audit trail multi-region |
| **Logs** | CloudWatch Logs | Log groups pour chaque service |
| **Securite** | GuardDuty | Detection des menaces |
| **Chiffrement** | KMS Keys | Cles avec rotation automatique |
| **Secrets** | Secrets Manager | Gestion securisee des secrets |
| **Alertes** | SNS Topics | Notification des alertes |

### Conditionnels

| Composant | Condition |
|-----------|-----------|
| VPC Flow Logs | Si VPC present |
| Security Hub | Si staging ou prod |
| AWS Config | Si staging ou prod |
| Config Rules | Si staging ou prod |
| WAF | Si exposition Internet |
| AWS Backup | Si donnees persistantes |
| Multi-AZ | Si prod ET stateful |
| Cross-Region DR | Si criticite high/critical |
| Shield Advanced | Si criticite critical |

---

## Matrice par Environnement

### Securite

| Composant | dev | staging | prod |
|-----------|-----|---------|------|
| IAM Baseline | OUI | OUI | OUI |
| KMS Keys | OUI | OUI | OUI |
| KMS CMK (vs AWS managed) | NON | OUI | OUI |
| GuardDuty | OUI | OUI | OUI |
| Security Hub | NON | OUI | OUI |
| Config Recorder | NON | OUI | OUI |
| WAF (si Internet) | NON | OUI | OUI |
| Shield (si critical) | NON | NON | OUI |

### Logging & Audit

| Composant | dev | staging | prod |
|-----------|-----|---------|------|
| CloudTrail | OUI | OUI | OUI |
| CloudWatch Logs | OUI | OUI | OUI |
| VPC Flow Logs | NON | OUI | OUI |
| Access Logging (ALB/S3) | NON | OUI | OUI |
| Log retention | 7j | 30j | 90j |

### Couts

| Composant | dev | staging | prod |
|-----------|-----|---------|------|
| Budget alerts | OUI | OUI | OUI |
| Cost Anomaly Detection | NON | OUI | OUI |
| FinOps tags | OUI | OUI | OUI |

### Resilience

| Composant | dev | staging | prod |
|-----------|-----|---------|------|
| Multi-AZ | NON | NON | OUI |
| Automated Backup | NON | OUI | OUI |
| Backup retention | - | 14j | 30j |
| Deletion protection | NON | NON | OUI |
| Cross-region DR | NON | NON | Si critical |

---

## Implementation par Composant

### IAM Baseline

```hcl
# Roles de base a creer
module "iam_baseline" {
  source = "../../modules/aws/governance/iam_baseline"

  project     = var.project
  environment = var.environment

  # Roles crees automatiquement
  create_admin_role     = true
  create_developer_role = true
  create_readonly_role  = true

  # MFA obligatoire pour admin
  require_mfa_for_admin = true

  tags = local.common_tags
}
```

### Budgets

```hcl
module "budgets" {
  source = "../../modules/aws/governance/budgets"

  project     = var.project
  environment = var.environment

  # Budget mensuel
  monthly_budget_amount = var.monthly_budget
  currency              = "USD"

  # Alertes par defaut
  alert_thresholds = [50, 80, 100]

  # Destinataires
  notification_emails = var.budget_notification_emails

  tags = local.common_tags
}
```

### CloudTrail

```hcl
module "cloudtrail" {
  source = "../../modules/aws/governance/cloudtrail"

  project     = var.project
  environment = var.environment

  # Multi-region obligatoire
  is_multi_region_trail = true

  # Chiffrement
  kms_key_id = module.kms.key_arn

  # Stockage
  s3_bucket_name = module.logging_bucket.bucket_id

  # Validation
  enable_log_file_validation = true

  # CloudWatch integration
  cloud_watch_logs_group_arn = module.cloudwatch_logs.log_group_arn

  tags = local.common_tags
}
```

### GuardDuty

```hcl
module "guardduty" {
  source = "../../modules/aws/governance/guardduty"

  project     = var.project
  environment = var.environment

  # Activer GuardDuty
  enable = true

  # Frequence des findings
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  # S3 protection (si buckets presents)
  enable_s3_protection = true

  # EKS protection (si EKS present)
  enable_eks_protection = var.has_eks

  tags = local.common_tags
}
```

### Security Hub

```hcl
module "security_hub" {
  source = "../../modules/aws/governance/security_hub"

  project     = var.project
  environment = var.environment

  # Standards a activer
  enable_cis_standard     = true
  enable_aws_foundational = true
  enable_pci_dss          = var.sector == "finance"

  # Aggregation
  enable_finding_aggregator = true

  tags = local.common_tags
}
```

### AWS Config

```hcl
module "config" {
  source = "../../modules/aws/governance/config_recorder"

  project     = var.project
  environment = var.environment

  # Enregistrer toutes les ressources
  all_supported_types = true

  # Stockage
  s3_bucket_name = module.config_bucket.bucket_id

  # SNS pour notifications
  sns_topic_arn = module.alerts_topic.topic_arn

  tags = local.common_tags
}

module "config_rules" {
  source = "../../modules/aws/governance/config_rules"

  # Regles obligatoires
  rules = [
    "encrypted-volumes",
    "rds-storage-encrypted",
    "s3-bucket-ssl-requests-only",
    "iam-password-policy",
    "root-account-mfa-enabled",
    "vpc-flow-logs-enabled"
  ]
}
```

### KMS

```hcl
module "kms" {
  source = "../../modules/aws/security/kms_key"

  project     = var.project
  environment = var.environment

  # Cles a creer
  keys = {
    "general" = {
      description         = "General encryption key"
      enable_key_rotation = true
    }
    "rds" = {
      description         = "RDS encryption key"
      enable_key_rotation = true
    }
    "s3" = {
      description         = "S3 encryption key"
      enable_key_rotation = true
    }
  }

  tags = local.common_tags
}
```

---

## Checklist Gouvernance

### Obligatoire (Tous Environnements)

```markdown
## Foundation
- [ ] VPC dedie (pas le default)
- [ ] Minimum 2 AZs
- [ ] Subnets segmentes (public/private/database)

## IAM
- [ ] Roles avec least privilege
- [ ] MFA pour admin
- [ ] Pas de credentials en dur

## Couts
- [ ] Budget configure
- [ ] Alertes a 50%, 80%, 100%
- [ ] Tags de cost allocation

## Logging
- [ ] CloudTrail active
- [ ] Log retention definie
- [ ] Chiffrement des logs

## Securite
- [ ] GuardDuty active
- [ ] KMS keys avec rotation
- [ ] Security Groups restrictifs
```

### Conditionnel (Staging/Prod)

```markdown
## Si Staging ou Prod
- [ ] VPC Flow Logs actives
- [ ] Security Hub active
- [ ] AWS Config active
- [ ] Config Rules deployees
- [ ] Backup automatise
- [ ] CloudWatch Alarms configurees

## Si Prod
- [ ] Multi-AZ pour stateful
- [ ] Deletion protection activee
- [ ] WAF si exposition Internet
```

### Conditionnel (Compliance)

```markdown
## Si Finance (PCI-DSS)
- [ ] PCI-DSS Config Pack
- [ ] Chiffrement obligatoire
- [ ] Audit logs 1 an

## Si Sante (HIPAA)
- [ ] HIPAA Config Pack
- [ ] PHI encryption
- [ ] Access logging

## Si Europe (GDPR)
- [ ] Region EU uniquement
- [ ] Data residency tags
- [ ] Retention policies
```

---

## Alertes et Notifications

### Configuration SNS

```hcl
module "alerts" {
  source = "../../modules/aws/messaging/sns_topic"

  name = "${local.name_prefix}-alerts"

  # Souscriptions
  subscriptions = [
    {
      protocol = "email"
      endpoint = var.alert_email
    },
    {
      protocol = "https"
      endpoint = var.slack_webhook_url
    }
  ]

  tags = local.common_tags
}
```

### Alertes Budget

- **50%** : Information
- **80%** : Warning
- **100%** : Critical + notification ops

### Alertes Securite

- **GuardDuty High Severity** : Immediate notification
- **Security Hub Critical** : Immediate notification
- **Unauthorized API Call** : Warning

---

## Liens

- [Securite](05-SECURITY.md)
- [Enrichissement](03-ENRICHMENT.md)
- [Workflow](02-WORKFLOW.md)
