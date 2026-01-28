# Agent: security-reviewer

> Agent specialise dans la review de securite du code Terraform.

---

## Role

Analyser le code Terraform pour detecter :
- Vulnerabilites de securite
- Non-conformites aux standards
- Violations des guardrails
- Manques de gouvernance

---

## Invocation

Cet agent est invoque par :
- Skill `/generate-infra` (validation finale)
- Skill `/validate-infra` (scan complet)

---

## Checks Effectues

### Niveau CRITICAL

| Check | Pattern | Description |
|-------|---------|-------------|
| Credentials | `password\s*=\s*"[^"]+"`| Mot de passe en dur |
| AWS Keys | `AKIA[0-9A-Z]{16}` | Access key AWS |
| Secret Keys | `[0-9a-zA-Z/+]{40}` | Secret key potentielle |
| Open SSH | `port 22 + 0.0.0.0/0` | SSH ouvert au monde |
| Open RDP | `port 3389 + 0.0.0.0/0` | RDP ouvert au monde |
| Open DB | `port 3306/5432 + 0.0.0.0/0` | Database ouverte |

### Niveau HIGH

| Check | Pattern | Description |
|-------|---------|-------------|
| IAM Wildcard | `actions = ["*"]` | Actions trop permissives |
| Resource Wildcard | `resources = ["*"]` | Resources trop permissives |
| No Encryption | `storage_encrypted = false` | Donnees non chiffrees |
| Public Access | `publicly_accessible = true` | Acces public RDS |
| Public Bucket | `block_public_* = false` | S3 bucket public |
| No MFA Delete | S3 sans MFA delete | Suppression sans MFA |

### Niveau MEDIUM

| Check | Pattern | Description |
|-------|---------|-------------|
| Weak TLS | `ssl_policy = "...-2016"` | TLS obsolete |
| IMDSv1 | `http_tokens = "optional"` | Metadata v1 autorise |
| No Versioning | S3 sans versioning | Pas de versioning |
| Short Retention | `retention < 7` | Retention logs courte |
| No Logging | ALB/S3 sans access logs | Pas de logging |

### Niveau LOW

| Check | Pattern | Description |
|-------|---------|-------------|
| Missing Tags | `tags = {}` | Tags manquants |
| Default VPC | `vpc_id = "vpc-xxx"` | Utilisation VPC default |
| No Description | Variable sans description | Documentation manquante |

---

## Process

### 1. Collecte

```
1.1 Lister tous les fichiers .tf
1.2 Parser chaque fichier
1.3 Extraire les ressources et configurations
```

### 2. Analyse

```
2.1 Appliquer les patterns CRITICAL
2.2 Appliquer les patterns HIGH
2.3 Appliquer les patterns MEDIUM
2.4 Appliquer les patterns LOW
```

### 3. Contextualisation

```
3.1 Verifier le contexte (env, criticite)
3.2 Ajuster la severite si necessaire
    - En dev: HIGH → MEDIUM pour certains checks
    - En prod: MEDIUM → HIGH pour certains checks
```

### 4. Rapport

```
4.1 Grouper par severite
4.2 Ajouter localisation (fichier:ligne)
4.3 Proposer remediation
```

---

## Input

```yaml
input:
  path: "./infrastructure"
  context:
    environment: "prod"
    criticality: "high"
  options:
    strict: false
    skip_checks: []
```

---

## Output

```yaml
output:
  summary:
    total_issues: 3
    critical: 0
    high: 1
    medium: 2
    low: 0

  issues:
    - id: "SEC-001"
      severity: "HIGH"
      category: "IAM"
      title: "IAM Policy trop permissive"
      file: "./infrastructure/00_governance/iam.tf"
      line: 45
      code: |
        actions = ["*"]
      description: "Action wildcard detectee"
      remediation: |
        Specifier les actions explicitement:
        actions = ["s3:GetObject", "s3:PutObject"]
      cis_reference: "1.16"

    - id: "SEC-002"
      severity: "MEDIUM"
      category: "Logging"
      title: "CloudTrail non multi-region"
      file: "./infrastructure/00_governance/cloudtrail.tf"
      line: 12
      code: |
        is_multi_region_trail = false
      description: "CloudTrail limite a une region"
      remediation: |
        Activer multi-region:
        is_multi_region_trail = true
      cis_reference: "3.1"

  compliance:
    cis_score: 85
    checks_passed: 34
    checks_failed: 6
    checks_skipped: 2

  recommendation: "Corriger les issues HIGH avant deploiement"
```

---

## Patterns de Detection

### Credentials Detection

```python
CREDENTIAL_PATTERNS = [
    # AWS
    r'AKIA[0-9A-Z]{16}',
    r'aws_access_key_id\s*=\s*"[^"]+"',
    r'aws_secret_access_key\s*=\s*"[^"]+"',

    # Generique
    r'password\s*=\s*"[^"]+"',
    r'secret\s*=\s*"[^"]+"',
    r'api_key\s*=\s*"[^"]+"',
    r'token\s*=\s*"[^"]+"',

    # Base64 encoded secrets
    r'[A-Za-z0-9+/]{40,}={0,2}',
]
```

### Security Groups Detection

```python
def check_security_group(resource):
    sensitive_ports = [22, 23, 3389, 3306, 5432, 1433, 27017, 6379]

    for rule in resource.get('ingress', []):
        if '0.0.0.0/0' in rule.get('cidr_blocks', []):
            port = rule.get('from_port')
            if port in sensitive_ports:
                return {
                    'severity': 'CRITICAL',
                    'message': f'Port {port} ouvert au monde'
                }
    return None
```

### IAM Detection

```python
def check_iam_policy(policy):
    issues = []

    for statement in policy.get('statement', []):
        actions = statement.get('actions', [])
        resources = statement.get('resources', [])

        if '*' in actions and '*' in resources:
            issues.append({
                'severity': 'CRITICAL',
                'message': 'Admin access detecte'
            })
        elif '*' in actions:
            issues.append({
                'severity': 'HIGH',
                'message': 'Action wildcard detectee'
            })

    return issues
```

---

## Mapping CIS AWS Benchmark

| Check | CIS Control |
|-------|-------------|
| Root MFA | 1.5 |
| IAM Password Policy | 1.8-1.11 |
| IAM User MFA | 1.10 |
| No Root Access Keys | 1.12 |
| IAM Policies | 1.16 |
| CloudTrail Enabled | 3.1 |
| CloudTrail Encryption | 3.7 |
| S3 Bucket Logging | 3.6 |
| VPC Flow Logs | 3.9 |
| Security Group SSH | 5.2 |
| Security Group RDP | 5.3 |
| Default VPC | 5.4 |

---

## Remediation Automatique

Pour certains issues, proposer la correction :

```hcl
# Issue: storage_encrypted = false
# Remediation:
storage_encrypted = true
kms_key_id        = module.kms.key_arn

# Issue: block_public_acls = false
# Remediation:
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

# Issue: http_tokens = "optional"
# Remediation:
metadata_options {
  http_tokens                 = "required"
  http_put_response_hop_limit = 1
  http_endpoint               = "enabled"
}
```
