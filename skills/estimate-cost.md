# Skill: /estimate-cost

> Estime les couts mensuels d'une infrastructure Terraform.

---

## Usage

```
/estimate-cost [chemin]
```

### Exemples

```
/estimate-cost
/estimate-cost ./infrastructure
/estimate-cost ./infrastructure --region us-east-1
```

---

## Methode d'Estimation

L'estimation est basee sur :
1. **MODULE_METADATA.yaml** : cost_factors de chaque module
2. **Pricing AWS** : Tarifs par region
3. **Configuration** : Instance types, quantites

---

## Workflow

### 1. Analyse de l'Infrastructure

```
Analyse de l'infrastructure...
  Detecte: 15 ressources facturables
  Region: eu-west-1
  Environnement: prod
```

### 2. Calcul par Categorie

```
Calcul des couts...
  Networking: $145/mois
  Compute: $280/mois
  Data: $120/mois
  Security: $25/mois
  Monitoring: $15/mois
```

### 3. Generation du Rapport

```
ESTIMATION DES COUTS MENSUELS
============================

Networking                              $145.00
├── NAT Gateway (x3)                    $100.80
│   └── $0.045/h × 24h × 31j × 3
├── VPC Endpoints (x5)                   $36.00
│   └── $0.01/h × 24h × 31j × 5
└── Data Transfer                         $8.20
    └── Estimation 100 GB

Compute                                 $280.00
├── ECS Fargate                         $180.00
│   └── 2 tasks × 1 vCPU × 2 GB
├── ALB                                  $25.00
│   └── $0.0225/h + LCU
└── Auto Scaling                         $75.00
    └── Variation estimee

Data                                    $120.00
├── RDS PostgreSQL (db.r6g.large)        $95.00
│   └── Multi-AZ: $0.266/h × 2
├── S3 Storage                           $10.00
│   └── 100 GB Standard
└── Backup Storage                       $15.00
    └── 30 jours retention

Security                                 $25.00
├── KMS Keys (x4)                         $4.00
│   └── $1/mois/cle
├── Secrets Manager (x8)                  $3.20
│   └── $0.40/mois/secret
└── GuardDuty                            $17.80
    └── Analyse logs/events

Monitoring                               $15.00
├── CloudWatch Logs                      $10.00
│   └── 50 GB ingestion
├── CloudWatch Alarms (x10)               $1.00
│   └── $0.10/alarm
└── CloudTrail                            $4.00
    └── Events management

────────────────────────────────────────────────
TOTAL ESTIME                           $585.00/mois
                                      ~$7,020/an

⚠️ Cette estimation n'inclut pas:
   - Data transfer sortant (variable)
   - Requetes API (variable)
   - Support AWS (si applicable)
   - Taxes
```

---

## Facteurs de Cout

### Networking

| Ressource | Cout Approximatif |
|-----------|-------------------|
| NAT Gateway | $0.045/h + $0.045/GB |
| VPC Endpoint | $0.01/h + $0.01/GB |
| ALB | $0.0225/h + LCU |
| NLB | $0.0225/h + LCU |
| Route 53 Zone | $0.50/mois |
| Route 53 Query | $0.40/M queries |

### Compute

| Ressource | Cout Approximatif |
|-----------|-------------------|
| ECS Fargate (vCPU) | $0.04048/h |
| ECS Fargate (GB RAM) | $0.004445/h |
| Lambda | $0.20/M requests |
| EC2 (t3.medium) | $0.0416/h |
| EC2 (m5.large) | $0.096/h |

### Data

| Ressource | Cout Approximatif |
|-----------|-------------------|
| RDS (db.t3.medium) | $0.068/h |
| RDS (db.r6g.large) | $0.133/h |
| RDS Multi-AZ | x2 |
| S3 Standard | $0.023/GB |
| DynamoDB (WCU) | $0.00065/WCU |
| ElastiCache (cache.t3.medium) | $0.068/h |

### Security

| Ressource | Cout Approximatif |
|-----------|-------------------|
| KMS Key | $1/mois |
| KMS Request | $0.03/10K |
| Secrets Manager | $0.40/secret/mois |
| GuardDuty | Variable |
| Security Hub | $0.0010/check |
| WAF | $5/ACL + $1/rule |

---

## Options

| Option | Description | Defaut |
|--------|-------------|--------|
| `--region <region>` | Region pour pricing | eu-west-1 |
| `--output <file>` | Generer fichier | - |
| `--format <fmt>` | Format (md, json, csv) | md |
| `--detailed` | Details par ressource | false |

---

## Comparaison par Environnement

```
/estimate-cost --compare
```

### Output

```
COMPARAISON PAR ENVIRONNEMENT
============================

                    dev         staging       prod
Networking         $35          $70          $145
Compute            $80          $120         $280
Data               $45          $60          $120
Security           $10          $15          $25
Monitoring         $5           $10          $15
────────────────────────────────────────────────
TOTAL             $175         $275         $585

Difference:
  staging vs dev: +$100 (+57%)
  prod vs staging: +$310 (+113%)
  prod vs dev: +$410 (+234%)

Principales differences prod:
  - NAT Gateway par AZ (+$68)
  - Multi-AZ RDS (+$95)
  - WAF (+$25)
  - GuardDuty/Security Hub (+$20)
```

---

## Export

### Markdown

```bash
/estimate-cost --output COST_ESTIMATE.md
```

### JSON

```bash
/estimate-cost --format json --output costs.json
```

```json
{
  "total_monthly": 585.00,
  "total_yearly": 7020.00,
  "currency": "USD",
  "region": "eu-west-1",
  "categories": {
    "networking": {
      "total": 145.00,
      "resources": [...]
    }
  }
}
```

---

## Agents Invoques

Aucun agent requis - calcul local base sur MODULE_METADATA.yaml.

---

## Limites

- Estimation basee sur utilisation moyenne
- Data transfer non inclus (variable)
- Prix peuvent varier selon la region
- Ne prend pas en compte les Reserved Instances
- Ne prend pas en compte les Savings Plans

---

## Exemple Complet

```bash
/estimate-cost ./infrastructure --detailed

# Output:
Analyse de l'infrastructure...
  Region: eu-west-1
  Environnement: prod
  Ressources: 23

ESTIMATION DETAILLEE
====================

00_governance/
├── cloudtrail.tf
│   └── aws_cloudtrail.main                    $4.00
│       └── Management events
├── guardduty.tf
│   └── aws_guardduty_detector.main           $17.80
│       └── ~500K events/mois
└── kms.tf
    └── aws_kms_key.general (x4)               $4.00
        └── $1/cle/mois

10_networking/
├── vpc.tf
│   └── aws_vpc.main                           $0.00
│       └── Pas de cout direct
├── nat.tf
│   └── aws_nat_gateway.main (x3)            $100.80
│       └── $0.045/h × 744h × 3
└── endpoints.tf
    └── aws_vpc_endpoint.s3 (x5)              $36.00
        └── $0.01/h × 744h × 5

[...]

TOTAL: $585.00/mois (~$7,020/an)
```
