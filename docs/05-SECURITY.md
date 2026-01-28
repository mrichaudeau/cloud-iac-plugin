# Securite - Guardrails

> **Version** : 1.0.0
> **Date** : Janvier 2025

---

## Principe

Le plugin applique des **guardrails de securite** stricts pour garantir que le code genere respecte les best practices et ne contient pas de vulnerabilites.

---

## Interdictions Absolues

L'IA ne doit **JAMAIS** generer :

### 1. Credentials en Dur

```hcl
# INTERDIT
access_key = "AKIAXXXXXXXXXXXXXXXX"
secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
password   = "mysecretpassword"
api_key    = "sk-xxxxxxxxxxxxx"

# CORRECT - Utiliser Secrets Manager ou variables
password = data.aws_secretsmanager_secret_version.db.secret_string
```

### 2. Security Groups Ouverts sur Ports Sensibles

```hcl
# INTERDIT - SSH ouvert au monde
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# CORRECT - Restreindre aux sources necessaires
ingress {
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_groups = [aws_security_group.bastion.id]
}
```

#### Ports Sensibles (JAMAIS ouverts a 0.0.0.0/0)

| Port | Service |
|------|---------|
| 22 | SSH |
| 23 | Telnet |
| 3389 | RDP |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 1433 | MSSQL |
| 27017 | MongoDB |
| 6379 | Redis |
| 9200 | Elasticsearch |
| 11211 | Memcached |

### 3. IAM Trop Permissif

```hcl
# INTERDIT
statement {
  actions   = ["*"]
  resources = ["*"]
}

# CORRECT - Least privilege
statement {
  actions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]
  resources = [
    aws_s3_bucket.data.arn,
    "${aws_s3_bucket.data.arn}/*"
  ]
}
```

### 4. Donnees Non Chiffrees

```hcl
# INTERDIT en production
resource "aws_db_instance" "this" {
  storage_encrypted = false
}

resource "aws_s3_bucket" "this" {
  # Pas de server_side_encryption
}

# CORRECT - Toujours chiffrer
resource "aws_db_instance" "this" {
  storage_encrypted = true
  kms_key_id        = module.kms.key_arn
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms.key_arn
    }
  }
}
```

### 5. Acces Public Non Controle

```hcl
# INTERDIT - S3 bucket public sans protection
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false  # INTERDIT
  block_public_policy     = false  # INTERDIT
  ignore_public_acls      = false  # INTERDIT
  restrict_public_buckets = false  # INTERDIT
}

# INTERDIT - RDS accessible publiquement
resource "aws_db_instance" "this" {
  publicly_accessible = true  # INTERDIT
}
```

### 6. TLS < 1.2

```hcl
# INTERDIT - Anciennes versions TLS
ssl_policy = "ELBSecurityPolicy-2016-08"

# CORRECT - TLS 1.2 minimum
ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
```

---

## Valeurs par Defaut Securisees

Ces valeurs doivent **TOUJOURS** etre appliquees :

### S3

```hcl
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms.key_arn
    }
  }
}

versioning {
  enabled = true
}
```

### RDS

```hcl
storage_encrypted       = true
publicly_accessible     = false
deletion_protection     = true  # en prod
skip_final_snapshot     = false # en prod
backup_retention_period = 7     # minimum
```

### EC2/ECS

```hcl
ebs_optimized = true
monitoring    = true

metadata_options {
  http_tokens                 = "required"  # IMDSv2 obligatoire
  http_put_response_hop_limit = 1
  http_endpoint               = "enabled"
}
```

### KMS

```hcl
enable_key_rotation = true
deletion_window_in_days = 30
```

### CloudWatch Logs

```hcl
retention_in_days = 30  # minimum, 90 recommande en prod
kms_key_id        = module.kms.key_arn
```

---

## Matrice de Securite par Environnement

| Controle | dev | staging | prod |
|----------|-----|---------|------|
| Encryption at rest | OUI | OUI | OUI |
| Encryption in transit | OUI | OUI | OUI |
| VPC Flow Logs | NON | OUI | OUI |
| GuardDuty | OUI | OUI | OUI |
| Security Hub | NON | OUI | OUI |
| WAF (si Internet) | NON | OUI | OUI |
| Multi-AZ | NON | NON | OUI |
| Backup automatise | NON | OUI | OUI |
| Deletion protection | NON | NON | OUI |
| IMDSv2 obligatoire | OUI | OUI | OUI |
| KMS CMK (vs AWS managed) | NON | OUI | OUI |

---

## Validation Pre-Generation

Avant de generer le code, verifier :

```markdown
## Checklist Securite

### Infrastructure
- [ ] VPC dedie (pas le default)
- [ ] Minimum 2 AZs utilisees
- [ ] Subnets correctement segmentes (public/private/database)

### Securite
- [ ] Security Groups restrictifs
- [ ] Pas de 0.0.0.0/0 sur ports sensibles
- [ ] KMS keys avec rotation activee
- [ ] IAM roles avec least privilege
- [ ] Pas de credentials en dur
- [ ] Encryption at-rest activee

### Gouvernance
- [ ] CloudTrail active
- [ ] GuardDuty active
- [ ] Budget configure avec alertes
- [ ] Tags obligatoires sur toutes les ressources

### Monitoring
- [ ] CloudWatch Log Groups crees
- [ ] Alarms configurees
- [ ] SNS topic pour alertes
```

---

## Detection et Prevention

### Patterns Dangereux a Detecter

```python
DANGEROUS_PATTERNS = [
    # Credentials
    r'(access_key|secret_key|password|api_key)\s*=\s*"[^"]+"',
    r'AKIA[0-9A-Z]{16}',  # AWS Access Key ID
    r'[0-9a-zA-Z/+]{40}',  # Potential secret key

    # Open Security Groups
    r'cidr_blocks\s*=\s*\["0\.0\.0\.0/0"\]',

    # IAM Wildcards
    r'actions\s*=\s*\["\*"\]',
    r'resources\s*=\s*\["\*"\]',

    # Unencrypted
    r'storage_encrypted\s*=\s*false',
    r'publicly_accessible\s*=\s*true',

    # Weak TLS
    r'ssl_policy\s*=\s*"ELBSecurityPolicy-(2015|2016)',
]
```

### Actions si Detection

1. **BLOQUER** la generation
2. **ALERTER** l'utilisateur
3. **SUGGERER** la correction appropriee

---

## Compliance Mapping

| Control | CIS AWS | SOC2 | PCI-DSS | HIPAA | GDPR |
|---------|---------|------|---------|-------|------|
| Encryption at rest | 2.1.1 | CC6.1 | 3.4 | 164.312(a)(2)(iv) | Art.32 |
| Encryption in transit | 2.1.2 | CC6.1 | 4.1 | 164.312(e)(1) | Art.32 |
| Access logging | 3.x | CC7.2 | 10.x | 164.312(b) | Art.30 |
| IAM least privilege | 1.x | CC6.3 | 7.x | 164.312(a)(1) | Art.25 |
| MFA | 1.10 | CC6.1 | 8.3 | 164.312(d) | - |
| Audit trail | 3.x | CC7.2 | 10.x | 164.312(b) | Art.30 |

---

## Liens

- [Gouvernance](07-GOVERNANCE.md)
- [Conventions](06-CONVENTIONS.md)
- [Workflow](02-WORKFLOW.md)
