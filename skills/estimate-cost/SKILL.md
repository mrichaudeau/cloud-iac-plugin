---
name: estimate-cost
description: Estimate monthly costs for Terraform infrastructure.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
argument-hint: [terraform-directory]
---

# /iac:estimate-cost

Estimate monthly costs for Terraform infrastructure.

## Usage

```
/iac:estimate-cost [path]
```

## Examples

```
/iac:estimate-cost
/iac:estimate-cost ./infrastructure
/iac:estimate-cost ./infrastructure --region us-east-1
```

## Estimation Method

Based on:
1. **MODULE_METADATA.yaml** - cost_factors from each module
2. **AWS Pricing** - Rates by region
3. **Configuration** - Instance types, quantities

## Cost Factors

### Networking

| Resource | Approximate Cost |
|----------|------------------|
| NAT Gateway | $0.045/h + $0.045/GB |
| VPC Endpoint | $0.01/h + $0.01/GB |
| ALB | $0.0225/h + LCU |
| Route 53 Zone | $0.50/month |

### Compute

| Resource | Approximate Cost |
|----------|------------------|
| ECS Fargate (vCPU) | $0.04048/h |
| ECS Fargate (GB RAM) | $0.004445/h |
| Lambda | $0.20/M requests |
| EC2 (t3.medium) | $0.0416/h |

### Data

| Resource | Approximate Cost |
|----------|------------------|
| RDS (db.t3.medium) | $0.068/h |
| RDS Multi-AZ | x2 |
| S3 Standard | $0.023/GB |
| DynamoDB (WCU) | $0.00065/WCU |

### Security

| Resource | Approximate Cost |
|----------|------------------|
| KMS Key | $1/month |
| Secrets Manager | $0.40/secret/month |
| GuardDuty | Variable |
| WAF | $5/ACL + $1/rule |

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--region <region>` | Region for pricing | eu-west-1 |
| `--output <file>` | Generate file | - |
| `--format <fmt>` | Format (md, json, csv) | md |
| `--compare` | Compare environments | false |

## Agents Invoked

None - local calculation based on MODULE_METADATA.yaml.

## Limitations

- Estimation based on average usage
- Data transfer not included (variable)
- Prices may vary by region
- Does not account for Reserved Instances
- Does not account for Savings Plans

## Output

- Detailed cost breakdown by category
- Monthly and yearly totals
- Environment comparison (with --compare)
- Warnings about excluded costs
