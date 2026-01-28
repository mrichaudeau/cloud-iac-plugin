# Skill: /validate-infra

> Valide la securite et la compliance d'une infrastructure Terraform.

---

## Usage

```
/validate-infra [chemin]
```

### Exemples

```
/validate-infra
/validate-infra ./infrastructure
/validate-infra ./modules/my-module
```

---

## Validations Effectuees

### 1. Validation Syntaxique

| Check | Commande | Obligatoire |
|-------|----------|-------------|
| Format | `terraform fmt -check` | Oui |
| Syntaxe | `terraform validate` | Oui |
| Linting | `tflint` | Recommande |

### 2. Scan Securite

| Check | Description | Severite |
|-------|-------------|----------|
| Credentials en dur | Detection de secrets dans le code | CRITICAL |
| Security Groups ouverts | 0.0.0.0/0 sur ports sensibles | CRITICAL |
| IAM trop permissif | Actions ou Resources avec "*" | HIGH |
| Encryption manquante | storage_encrypted = false | HIGH |
| Acces public | publicly_accessible = true | HIGH |
| TLS faible | ssl_policy ancien | MEDIUM |
| Tags manquants | Tags obligatoires absents | LOW |

### 3. Compliance

| Standard | Checks |
|----------|--------|
| CIS AWS | Encryption, logging, IAM, networking |
| SOC2 | Access control, audit logging |
| PCI-DSS | Encryption, network segmentation |
| HIPAA | PHI protection, audit trails |
| GDPR | Data residency, encryption |

### 4. Gouvernance

| Check | Description |
|-------|-------------|
| IAM Baseline | Roles de base presents |
| Budgets | Alertes configurees |
| CloudTrail | Audit active |
| GuardDuty | Detection menaces active |
| Tags | Tags obligatoires presents |

---

## Workflow

### Phase 1 : Validation Syntaxique

```
Validation syntaxique...
  ✓ terraform fmt
  ✓ terraform validate
  ✓ tflint (0 warnings, 0 errors)
```

### Phase 2 : Scan Securite

```
Scan securite...
  ✓ Pas de credentials detectes
  ✓ Security Groups conformes
  ✗ IAM Policy trop permissive (HIGH)
    → ./infrastructure/00_governance/iam.tf:45
    → Action "*" detecte
  ✓ Encryption activee partout
  ✓ Pas d'acces public non controle
```

### Phase 3 : Compliance Check

```
Verification compliance...
  CIS AWS Benchmark:
    ✓ 2.1.1 Encryption at rest
    ✓ 2.1.2 Encryption in transit
    ✗ 3.1 CloudTrail multi-region
    ✓ 4.1 Security Groups restrictifs

  Score: 85/100
```

### Phase 4 : Gouvernance Check

```
Verification gouvernance...
  ✓ IAM Baseline present
  ✓ Budgets configures
  ✗ CloudTrail manquant
  ✓ GuardDuty active
  ✓ Tags obligatoires (5/5)
```

---

## Output

### Rapport Console

```
Validation Infrastructure
========================

Syntaxe:      ✓ OK
Securite:     ✗ 1 HIGH, 0 CRITICAL
Compliance:   85/100
Gouvernance:  4/5 checks OK

Problemes detectes:
------------------

[HIGH] IAM Policy trop permissive
  Fichier: ./infrastructure/00_governance/iam.tf:45
  Description: Action "*" detecte sur la policy
  Remediation: Specifier les actions explicitement

  # Actuel
  actions = ["*"]

  # Recommande
  actions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]

[MEDIUM] CloudTrail non multi-region
  Fichier: ./infrastructure/00_governance/cloudtrail.tf:12
  Description: is_multi_region_trail = false
  Remediation: Activer multi-region pour audit complet

Recommandations:
---------------
1. Corriger les problemes HIGH avant deploiement
2. Ajouter CloudTrail multi-region
3. Revalider apres corrections
```

### Rapport Fichier (optionnel)

```
/validate-infra --output report.md
```

Genere un fichier `VALIDATION_REPORT.md` detaille.

---

## Options

| Option | Description | Defaut |
|--------|-------------|--------|
| `--strict` | Echouer sur tout warning | false |
| `--output <file>` | Generer rapport fichier | - |
| `--fix` | Corriger auto si possible | false |
| `--compliance <std>` | Standard specifique | all |

---

## Severites

| Severite | Description | Action |
|----------|-------------|--------|
| CRITICAL | Faille de securite majeure | BLOQUER le deploiement |
| HIGH | Probleme de securite important | Corriger avant prod |
| MEDIUM | Best practice non respectee | Corriger recommande |
| LOW | Amelioration possible | Optionnel |
| INFO | Information | Aucune action requise |

---

## Agents Invoques

| Agent | Role |
|-------|------|
| `security-reviewer` | Scan securite approfondi |

---

## Patterns Detectes

### CRITICAL

```hcl
# Credentials en dur
access_key = "AKIA..."
password = "secret123"
api_key = "sk-..."

# Security Group ouvert sur SSH
cidr_blocks = ["0.0.0.0/0"]  # sur port 22
```

### HIGH

```hcl
# IAM trop permissif
actions   = ["*"]
resources = ["*"]

# Donnees non chiffrees
storage_encrypted = false
publicly_accessible = true
```

### MEDIUM

```hcl
# TLS faible
ssl_policy = "ELBSecurityPolicy-2016-08"

# IMDSv1 autorise
http_tokens = "optional"
```

### LOW

```hcl
# Tags manquants
tags = {}  # Tags obligatoires absents
```

---

## Exemple Complet

```bash
/validate-infra ./infrastructure

# Output:
Validation Infrastructure
========================

Phase 1: Syntaxe
  ✓ terraform fmt (0 fichiers a formater)
  ✓ terraform validate (configuration valide)
  ✓ tflint (0 issues)

Phase 2: Securite
  Scanning 45 ressources...
  ✓ Credentials: aucun detecte
  ✓ Security Groups: 8/8 conformes
  ✓ IAM Policies: 5/5 conformes
  ✓ Encryption: 12/12 ressources chiffrees
  ✓ Acces public: aucun non controle

Phase 3: Compliance
  CIS AWS: 95/100
  SOC2: 90/100
  PCI-DSS: N/A (non applicable)

Phase 4: Gouvernance
  ✓ IAM Baseline
  ✓ Budgets
  ✓ CloudTrail
  ✓ GuardDuty
  ✓ KMS Keys
  ✓ Tags (100%)

Resultat: VALIDE
================
Aucun probleme bloquant detecte.
L'infrastructure est prete pour deploiement.

Recommandations mineures:
- Considerer l'ajout de WAF pour l'ALB
- Augmenter la retention des logs a 90 jours
```
