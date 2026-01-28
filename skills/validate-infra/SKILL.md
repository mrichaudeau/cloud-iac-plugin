---
name: validate-infra
description: Validate Terraform infrastructure for security, compliance, and best practices. Use proactively after generating infrastructure.
disable-model-invocation: false
allowed-tools: Read, Bash, Glob, Grep
context: fork
agent: Explore
argument-hint: [terraform-directory]
---

# /iac:validate-infra

Validate security and compliance of Terraform infrastructure.

## Usage

```
/iac:validate-infra [path]
```

## Examples

```
/iac:validate-infra
/iac:validate-infra ./infrastructure
/iac:validate-infra ./modules/my-module
```

## Validations Performed

### 1. Syntactic Validation

| Check | Command | Required |
|-------|---------|----------|
| Format | `terraform fmt -check` | Yes |
| Syntax | `terraform validate` | Yes |
| Linting | `tflint` | Recommended |

### 2. Security Scan

| Check | Description | Severity |
|-------|-------------|----------|
| Hardcoded credentials | Secrets in code | CRITICAL |
| Open Security Groups | 0.0.0.0/0 on sensitive ports | CRITICAL |
| Overly permissive IAM | Actions or Resources with "*" | HIGH |
| Missing encryption | storage_encrypted = false | HIGH |
| Public access | publicly_accessible = true | HIGH |
| Weak TLS | Old ssl_policy | MEDIUM |
| Missing tags | Mandatory tags absent | LOW |

### 3. Compliance

| Standard | Checks |
|----------|--------|
| CIS AWS | Encryption, logging, IAM, networking |
| SOC2 | Access control, audit logging |
| PCI-DSS | Encryption, network segmentation |

### 4. Governance

| Check | Description |
|-------|-------------|
| IAM Baseline | Base roles present |
| Budgets | Alerts configured |
| CloudTrail | Audit enabled |
| GuardDuty | Threat detection enabled |
| Tags | Mandatory tags present |

## Severities

| Severity | Action |
|----------|--------|
| CRITICAL | BLOCK deployment |
| HIGH | Fix before prod |
| MEDIUM | Fix recommended |
| LOW | Optional |

## Agents Invoked

| Agent | Role |
|-------|------|
| `security-reviewer` | In-depth security scan |

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--strict` | Fail on any warning | false |
| `--output <file>` | Generate file report | - |
| `--fix` | Auto-fix if possible | false |

## Output

- Console report with issues and remediations
- Compliance score (e.g., CIS: 85/100)
- Recommendations for improvements
