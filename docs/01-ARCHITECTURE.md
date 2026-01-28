# Architecture Technique

> **Version** : 1.0.0
> **Date** : Janvier 2025

---

## Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            ECOSYSTEME IaC FACTORY                                    │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│   DEVELOPPEURS                                                                       │
│   ┌─────────────────────────────────────────────────────────────────────────────┐   │
│   │                      PLUGIN CLAUDE CODE                                     │   │
│   │                  (infra_as_code_pluggin)                                    │   │
│   │                                                                             │   │
│   │  SKILLS (Commandes utilisateur)                                            │   │
│   │  ┌────────────────┐ ┌────────────────┐ ┌─────────────────┐                │   │
│   │  │/generate-infra │ │/publish-module │ │/import-module   │                │   │
│   │  │                │ │                │ │                 │                │   │
│   │  │ Parse schema   │ │ Validate local │ │ Search factory  │                │   │
│   │  │ Enrich         │ │ Compare factory│ │ Import + adapt  │                │   │
│   │  │ Generate TF    │ │ Create PR      │ │                 │                │   │
│   │  └────────────────┘ └────────────────┘ └─────────────────┘                │   │
│   │                                                                             │   │
│   │  ┌────────────────┐ ┌────────────────┐                                    │   │
│   │  │/validate-infra │ │/estimate-cost  │                                    │   │
│   │  │                │ │                │                                    │   │
│   │  │ Security scan  │ │ Infracost      │                                    │   │
│   │  │ Compliance     │ │ estimation     │                                    │   │
│   │  └────────────────┘ └────────────────┘                                    │   │
│   │                                                                             │   │
│   │  AGENTS (Specialistes appeles par les skills)                             │   │
│   │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │   │
│   │  │tf-generator │ │security-    │ │factory-sync │ │schema-parser│        │   │
│   │  │             │ │reviewer     │ │             │ │             │        │   │
│   │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘        │   │
│   │                                                                             │   │
│   └─────────────────────────────────────────────────────────────────────────────┘   │
│                              │                                                      │
│                              │ Utilise / Contribue                                  │
│                              ▼                                                      │
│   ┌─────────────────────────────────────────────────────────────────────────────┐   │
│   │                      CLOUD IAC FACTORY                                      │   │
│   │                   (cloud_iac_factory - GitHub)                              │   │
│   │                                                                             │   │
│   │  modules/                    │  patterns/           │  policies/            │   │
│   │  ├── aws/                    │  ├── three-tier/     │  ├── security/        │   │
│   │  │   ├── networking/         │  ├── serverless/     │  ├── finops/          │   │
│   │  │   │   └── vpc/v1.2.0     │  └── data-platform/  │  └── compliance/      │   │
│   │  │   ├── compute/           │                      │                       │   │
│   │  │   └── ...                │                      │                       │   │
│   │  ├── azure/                  │                      │                       │   │
│   │  └── gcp/                    │  catalog.json        │                       │   │
│   │                                                                             │   │
│   │  CI/CD: validation, tests, publication automatique                         │   │
│   └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Composants du Plugin

### Skills (Commandes Utilisateur)

| Skill | Description | Fichier |
|-------|-------------|---------|
| `/generate-infra` | Genere infrastructure complete | `skills/generate-infra.md` |
| `/publish-module` | Publie module vers factory | `skills/publish-module.md` |
| `/import-module` | Importe module depuis factory | `skills/import-module.md` |
| `/validate-infra` | Valide securite et compliance | `skills/validate-infra.md` |
| `/estimate-cost` | Estime les couts | `skills/estimate-cost.md` |

### Agents (Specialistes)

| Agent | Role | Fichier |
|-------|------|---------|
| `tf-generator` | Generation code Terraform | `agents/tf-generator.md` |
| `security-reviewer` | Review securite | `agents/security-reviewer.md` |
| `factory-sync` | Synchronisation factory | `agents/factory-sync.md` |
| `schema-parser` | Parsing schemas d'architecture | `agents/schema-parser.md` |

---

## Structure du Plugin

```
infra_as_code_pluggin/
│
├── README.md                    # Documentation principale
├── CLAUDE.md                    # Instructions Claude Code
│
├── docs/                        # Documentation segmentee
│   ├── 00-VISION.md            # Vision et objectifs
│   ├── 01-ARCHITECTURE.md      # Ce fichier
│   ├── 02-WORKFLOW.md          # Workflow de generation
│   ├── 03-ENRICHMENT.md        # Logique d'enrichissement
│   ├── 04-FACTORY.md           # Specification factory
│   ├── 05-SECURITY.md          # Guardrails securite
│   ├── 06-CONVENTIONS.md       # Conventions nommage
│   ├── 07-GOVERNANCE.md        # Regles gouvernance
│   └── 08-ROADMAP.md           # Plan implementation
│
├── skills/                      # Skills Claude Code
│   ├── generate-infra.md
│   ├── publish-module.md
│   ├── import-module.md
│   ├── validate-infra.md
│   └── estimate-cost.md
│
├── agents/                      # Agents specialises
│   ├── tf-generator.md
│   ├── security-reviewer.md
│   ├── factory-sync.md
│   └── schema-parser.md
│
├── templates/                   # Templates Terraform
│   ├── _backend.tf.tmpl
│   ├── _providers.tf.tmpl
│   ├── _variables.tf.tmpl
│   ├── _locals.tf.tmpl
│   └── module-call.tf.tmpl
│
└── config/                      # Configuration
    ├── factory.yaml             # URL et acces factory
    ├── defaults.yaml            # Valeurs par defaut
    └── providers/
        ├── aws.yaml
        ├── azure.yaml
        └── gcp.yaml
```

---

## Structure de la Factory

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
│   │   │   └── vpc/
│   │   │       ├── v1.0.0/          # Version taggee
│   │   │       │   ├── main.tf
│   │   │       │   ├── variables.tf
│   │   │       │   ├── outputs.tf
│   │   │       │   ├── versions.tf
│   │   │       │   ├── MODULE_METADATA.yaml
│   │   │       │   ├── README.md
│   │   │       │   └── examples/
│   │   │       └── CHANGELOG.md
│   │   ├── compute/
│   │   ├── data/
│   │   └── security/
│   ├── azure/
│   └── gcp/
│
├── patterns/                        # Architectures completes
│   ├── three-tier-webapp/
│   ├── serverless-api/
│   └── data-platform/
│
├── policies/
│   ├── security/
│   ├── finops/
│   └── compliance/
│
├── catalog.json                     # Index auto-genere
└── README.md
```

---

## Structure de Sortie (Infrastructure Generee)

```
./infrastructure/
│
├── _backend.tf                 # Configuration state Terraform
├── _providers.tf               # Providers et versions
├── _variables.tf               # Variables globales
├── _locals.tf                  # Locals, conventions, tags
├── _outputs.tf                 # Outputs principaux
├── _data.tf                    # Data sources
│
├── 00_governance/              # Gouvernance (PREMIER)
│   ├── iam_foundation.tf
│   ├── budgets.tf
│   ├── cloudtrail.tf
│   ├── guardduty.tf
│   └── kms.tf
│
├── 10_networking/              # Couche reseau
│   ├── vpc.tf
│   ├── subnets.tf
│   ├── nat.tf
│   └── flow_logs.tf
│
├── 20_security/                # Couche securite
│   ├── security_groups.tf
│   ├── waf.tf
│   └── secrets.tf
│
├── 30_compute/                 # Couche compute
│   └── [ecs.tf | eks.tf | lambda.tf]
│
├── 40_data/                    # Couche donnees
│   ├── rds.tf
│   ├── s3.tf
│   └── backup.tf
│
├── 50_loadbalancing/           # Load balancing
│   ├── alb.tf
│   └── target_groups.tf
│
├── 60_monitoring/              # Monitoring (DERNIER)
│   ├── cloudwatch_alarms.tf
│   ├── dashboards.tf
│   └── sns.tf
│
├── environments/               # Variables par environnement
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
│
├── README.md                   # Documentation auto-generee
├── ARCHITECTURE.md             # Diagramme + explications
├── DECISIONS.md                # Log des decisions IA
└── COST_ESTIMATE.md            # Estimation des couts
```

### Ordre de Deploiement

| Prefixe | Categorie | Ordre |
|---------|-----------|-------|
| `00_` | Gouvernance | 1er (fondation) |
| `10_` | Networking | 2eme |
| `20_` | Security | 3eme |
| `30_` | Compute | 4eme |
| `40_` | Data | 5eme |
| `50_` | Load Balancing | 6eme |
| `60_` | Monitoring | 7eme (dernier) |

---

## Integration avec cloud_iac

Ce plugin s'appuie sur le framework existant dans `cloud_iac/` :

| Composant cloud_iac | Utilisation dans le plugin |
|---------------------|----------------------------|
| `modules/` | Source des modules Terraform |
| `.ai/` | Regles de generation |
| `plan/*.md` | Documentation des standards |
| `CLAUDE.md` | Instructions de base |

---

## Liens

- [Workflow de Generation](02-WORKFLOW.md)
- [Factory GitHub](04-FACTORY.md)
- [Conventions](06-CONVENTIONS.md)
