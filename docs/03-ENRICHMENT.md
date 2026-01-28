# Logique d'Enrichissement

> **Version** : 1.0.0
> **Date** : Janvier 2025

---

## Principe

L'enrichissement automatique transforme une demande minimale en infrastructure complete en ajoutant :
1. Les dependances techniques obligatoires
2. Les dependances recommandees selon le contexte
3. Les composants de gouvernance

---

## Pyramide d'Enrichissement

```
NIVEAU 4: OPTIMISATIONS (si budget/perf requis)
  CloudFront CDN, ElastiCache, Reserved Instances
           ↑
NIVEAU 3: GOUVERNANCE (toujours injecte)
  IAM, Budgets, CloudTrail, GuardDuty, KMS, CloudWatch, SNS
           ↑
NIVEAU 2: DEPENDANCES TECHNIQUES (auto-detectees)
  Security Groups, Subnets, NAT Gateway, VPC Endpoints
           ↑
NIVEAU 1: FONDATIONS (toujours presentes)
  VPC, Route Tables, Internet Gateway
```

---

## Types de Dependances

| Type | Description | Comportement IA |
|------|-------------|-----------------|
| **HARD** | Requis, bloquant | TOUJOURS creer |
| **SOFT** | Recommande, conditionnel | Creer SI condition remplie |
| **GOVERNANCE** | Regle de gouvernance | TOUJOURS injecter selon env |
| **OPTIONAL** | Optimisation | Proposer, ne pas creer par defaut |

---

## Dependances par Composant

### ECS Fargate

```yaml
HARD:
  - vpc
  - private_subnets
  - iam_task_role
  - iam_execution_role
  - security_group
  - cloudwatch_log_group

SOFT:
  - IF needs_internet: nat_gateway
  - IF is_web_app: alb, target_group, listener
  - IF env IN [staging, prod]: autoscaling
  - IF has_ecr: vpc_endpoint_ecr

GOVERNANCE:
  - kms_key
  - secrets_manager
  - cloudwatch_alarms
```

### RDS (PostgreSQL/MySQL)

```yaml
HARD:
  - vpc
  - database_subnets
  - db_subnet_group
  - security_group
  - kms_key
  - parameter_group

SOFT:
  - IF env == prod: multi_az, performance_insights, enhanced_monitoring
  - IF has_read_replicas: read_replica
  - IF criticality IN [high, critical]: cross_region_replica

GOVERNANCE:
  - secrets_manager (pour credentials)
  - backup_plan
  - cloudwatch_alarms
```

### Lambda

```yaml
HARD:
  - iam_execution_role
  - cloudwatch_log_group

SOFT:
  - IF needs_vpc: vpc, private_subnets, security_group, nat_gateway
  - IF has_api_trigger: api_gateway
  - IF has_schedule: eventbridge_rule
  - IF has_queue_trigger: sqs_queue

GOVERNANCE:
  - kms_key
  - dead_letter_queue
  - xray_tracing
```

### S3 Bucket

```yaml
HARD:
  - kms_key
  - bucket_policy

SOFT:
  - IF is_static_website: cloudfront, acm_certificate, route53
  - IF has_replication: replication_configuration
  - IF is_log_bucket: lifecycle_rules
  - IF has_events: s3_notification, lambda_or_sqs

GOVERNANCE:
  - public_access_block (TOUJOURS)
  - versioning
  - access_logging
```

### ALB (Application Load Balancer)

```yaml
HARD:
  - vpc
  - public_subnets
  - security_group
  - target_group
  - listener

SOFT:
  - IF protocol == HTTPS: acm_certificate
  - IF has_custom_domain: route53_record
  - IF env IN [staging, prod]: waf_web_acl
  - IF has_auth: cognito_or_oidc

GOVERNANCE:
  - access_logs (vers S3)
  - cloudwatch_alarms
  - ssl_policy (TLS 1.2+)
```

### EKS Cluster

```yaml
HARD:
  - vpc
  - private_subnets
  - eks_cluster_role
  - eks_node_role
  - security_group_cluster
  - security_group_nodes

SOFT:
  - IF needs_ingress: alb_ingress_controller
  - IF needs_storage: efs_csi_driver
  - IF needs_secrets: secrets_store_csi
  - IF env == prod: cluster_autoscaler

GOVERNANCE:
  - kms_key (encryption secrets)
  - cloudwatch_logs (control plane)
  - cloudwatch_alarms
```

---

## Detection du Contexte

### Detection de l'Environnement

```python
def detect_environment(input_text):
    input_lower = input_text.lower()

    if any(word in input_lower for word in ["prod", "production", "live"]):
        return "prod"
    elif any(word in input_lower for word in ["staging", "stage", "preprod"]):
        return "staging"
    elif any(word in input_lower for word in ["dev", "development", "test"]):
        return "dev"
    else:
        # Non specifie → prod par defaut (plus securise)
        return "prod"
```

### Detection de la Criticite

```python
def determine_criticality(context):
    score = 0

    # Facteurs de criticite
    if context.environment == "prod": score += 2
    if context.has_database: score += 1
    if context.has_user_data: score += 2
    if context.is_customer_facing: score += 1
    if context.sector in ["finance", "healthcare", "government"]: score += 3
    if context.has_pii: score += 2
    if context.has_payment: score += 3

    # Facteurs de reduction
    if context.environment in ["dev", "sandbox"]: score -= 3
    if context.is_ephemeral: score -= 2

    # Classification
    if score <= 0: return "low"
    elif score <= 3: return "medium"
    elif score <= 6: return "high"
    else: return "critical"
```

### Detection de l'Exposition Internet

```python
internet_indicators = ["web", "api", "public", "internet", "website", "app", "frontend"]
has_internet = any(kw in text.lower() for kw in internet_indicators)
```

---

## Matrice d'Injection Gouvernance

| Composant | dev | staging | prod | Condition |
|-----------|-----|---------|------|-----------|
| IAM Baseline | OUI | OUI | OUI | Toujours |
| KMS Keys | OUI | OUI | OUI | Toujours |
| CloudTrail | OUI | OUI | OUI | Toujours |
| GuardDuty | OUI | OUI | OUI | Toujours |
| Budgets | OUI | OUI | OUI | Toujours |
| CloudWatch Logs | OUI | OUI | OUI | Toujours |
| CloudWatch Alarms | NON | OUI | OUI | staging/prod |
| SNS Alerts | NON | OUI | OUI | staging/prod |
| VPC Flow Logs | NON | OUI | OUI | Si VPC present |
| Security Hub | NON | OUI | OUI | staging/prod |
| Config Recorder | NON | OUI | OUI | staging/prod |
| WAF | NON | OUI | OUI | Si Internet exposure |
| AWS Backup | NON | OUI | OUI | Si donnees persistantes |
| Multi-AZ | NON | NON | OUI | Si stateful |
| Cross-Region DR | NON | NON | OUI | Si criticite high/critical |

---

## Algorithme d'Enrichissement

```
1. PARSER les composants explicites de la demande utilisateur
2. DETECTER le contexte (env, criticite, secteur, internet, data)
3. POUR chaque composant:
   a. AJOUTER hard_dependencies (toujours)
   b. EVALUER soft_dependencies (si condition remplie)
   c. AJOUTER le composant lui-meme
4. INJECTER la gouvernance (basee sur le contexte)
5. VALIDER la coherence du plan
6. ORDONNER par dependances (00_ → 60_)
```

---

## Resolution des Conflits

| Conflit | Resolution |
|---------|------------|
| NAT vs VPC Endpoints | Les deux si budget permet, sinon VPC Endpoints |
| Public vs Private subnet | Private par defaut |
| Single-AZ vs Multi-AZ (cout) | Multi-AZ en prod, Single en dev |
| CMK vs AWS-managed key | CMK en prod, AWS-managed en dev |

---

## Exemple Complet

### Input
```
"Application web Python/Django avec PostgreSQL en production"
```

### Contexte Detecte
```yaml
environment: prod
criticality: high (web + database + prod)
has_internet: true
has_persistent_data: true
```

### Plan Enrichi

```
EXPLICITE:
  - ecs_service (Django)
  - rds_postgresql

HARD DEPENDENCIES:
  - vpc
  - public_subnets (pour ALB)
  - private_subnets (pour ECS)
  - database_subnets (pour RDS)
  - internet_gateway
  - nat_gateway (x3 car prod)
  - route_tables
  - sg_alb
  - sg_ecs
  - sg_rds
  - alb
  - target_group
  - https_listener
  - acm_certificate
  - iam_ecs_task_role
  - iam_ecs_execution_role
  - db_subnet_group
  - rds_parameter_group
  - kms_key_rds

SOFT DEPENDENCIES (conditions remplies):
  - autoscaling_ecs (env=prod)
  - vpc_endpoints (subnets prives)
  - waf_web_acl (env=prod + internet)
  - performance_insights (env=prod)
  - enhanced_monitoring (env=prod)
  - multi_az_rds (env=prod)

GOUVERNANCE:
  - iam_baseline
  - cloudtrail
  - guardduty
  - security_hub
  - config_recorder
  - budgets
  - cost_anomaly
  - cloudwatch_alarms
  - sns_alerts
  - vpc_flow_logs
  - backup_plan
  - secrets_manager
```

---

## Liens

- [Workflow de Generation](02-WORKFLOW.md)
- [Gouvernance](07-GOVERNANCE.md)
- [Securite](05-SECURITY.md)
