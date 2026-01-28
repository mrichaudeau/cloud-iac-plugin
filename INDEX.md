# Cloud IaC Plugin - Index

> Index complet de la documentation et des fichiers du plugin

---

## Structure du Projet

```
infra_as_code_pluggin/
├── .claude-plugin/
│   └── plugin.json               # Manifest du plugin (name: "iac")
│
├── skills/                       # Skills Claude Code
│   ├── generate-infra/
│   │   ├── SKILL.md             # Instructions principales
│   │   ├── workflow.md          # Workflow detaille
│   │   └── formats.md           # Formats supportes
│   ├── publish-module/
│   │   └── SKILL.md
│   ├── import-module/
│   │   └── SKILL.md
│   ├── validate-infra/
│   │   └── SKILL.md
│   └── estimate-cost/
│       └── SKILL.md
│
├── agents/                       # Agents specialises (avec frontmatter YAML)
│   ├── tf-generator.md          # Generation Terraform
│   ├── security-reviewer.md     # Review securite
│   ├── factory-sync.md          # Sync avec factory
│   └── schema-parser.md         # Parsing des schemas
│
├── hooks/
│   └── hooks.json               # Configuration hooks (PreToolUse, PostToolUse, SubagentStop)
│
├── scripts/                     # Scripts pour hooks
│   ├── validate-bash-command.sh
│   ├── post-edit-validation.sh
│   └── post-generation-check.sh
│
├── config/                      # Configuration
│   ├── defaults.yaml            # Valeurs par defaut
│   ├── factory.yaml             # Config factory GitHub
│   ├── validation-schema.yaml   # Schema de validation
│   ├── anti-hallucination.yaml  # Regles anti-hallucination
│   └── providers/
│       ├── aws.yaml             # Config AWS
│       ├── azure.yaml           # Config Azure
│       └── gcp.yaml             # Config GCP
│
├── templates/                   # Templates Terraform
│   ├── _backend.tf.tmpl
│   ├── _providers.tf.tmpl
│   ├── _variables.tf.tmpl
│   ├── _locals.tf.tmpl
│   ├── _outputs.tf.tmpl
│   ├── module-call.tf.tmpl
│   └── governance/
│       ├── _cloudtrail.tf.tmpl
│       ├── _guardduty.tf.tmpl
│       ├── _budgets.tf.tmpl
│       └── _kms.tf.tmpl
│
├── examples/                    # Exemples d'architectures
│   ├── architecture-simple.md
│   ├── architecture-microservices.md
│   └── architecture.yaml
│
├── docs/                        # Documentation
│   ├── 00-VISION.md
│   ├── 01-ARCHITECTURE.md
│   ├── 02-WORKFLOW.md
│   ├── 03-ENRICHMENT.md
│   ├── 04-FACTORY.md
│   ├── 05-SECURITY.md
│   ├── 06-CONVENTIONS.md
│   ├── 07-GOVERNANCE.md
│   ├── 08-ROADMAP.md
│   └── reference/               # Documentation de reference Claude Code
│
├── README.md                    # Documentation principale
├── CLAUDE.md                    # Instructions pour Claude Code
└── INDEX.md                     # Ce fichier
```

---

## Documentation par Theme

### Vision & Architecture
| Fichier | Description |
|---------|-------------|
| [00-VISION.md](docs/00-VISION.md) | Vision, objectifs, workflow global |
| [01-ARCHITECTURE.md](docs/01-ARCHITECTURE.md) | Architecture technique complete |
| [08-ROADMAP.md](docs/08-ROADMAP.md) | Plan d'implementation |

### Workflow & Generation
| Fichier | Description |
|---------|-------------|
| [02-WORKFLOW.md](docs/02-WORKFLOW.md) | 5 phases de generation |
| [03-ENRICHMENT.md](docs/03-ENRICHMENT.md) | Logique d'enrichissement automatique |
| [schema-parser.md](agents/schema-parser.md) | Parsing multi-format |
| [tf-generator.md](agents/tf-generator.md) | Generation du code Terraform |

### Factory & Publication
| Fichier | Description |
|---------|-------------|
| [04-FACTORY.md](docs/04-FACTORY.md) | Structure et workflow factory |
| [factory-sync.md](agents/factory-sync.md) | Synchronisation GitHub |
| [publish-module/SKILL.md](skills/publish-module/SKILL.md) | Publication de modules |
| [import-module/SKILL.md](skills/import-module/SKILL.md) | Import de modules |

### Securite & Gouvernance
| Fichier | Description |
|---------|-------------|
| [05-SECURITY.md](docs/05-SECURITY.md) | Guardrails et patterns interdits |
| [07-GOVERNANCE.md](docs/07-GOVERNANCE.md) | Composants de gouvernance |
| [security-reviewer.md](agents/security-reviewer.md) | Agent de review securite |
| [anti-hallucination.yaml](config/anti-hallucination.yaml) | Validation anti-hallucination |

### Conventions & Standards
| Fichier | Description |
|---------|-------------|
| [06-CONVENTIONS.md](docs/06-CONVENTIONS.md) | Nommage, tags, structure |
| [defaults.yaml](config/defaults.yaml) | Valeurs par defaut |
| [validation-schema.yaml](config/validation-schema.yaml) | Schema de validation |

---

## Skills Disponibles

| Skill | Trigger | Description |
|-------|---------|-------------|
| Generate Infrastructure | `/iac:generate-infra` | Generer Terraform depuis un schema |
| Publish Module | `/iac:publish-module` | Publier un module vers la factory |
| Import Module | `/iac:import-module` | Importer un module depuis la factory |
| Validate Infrastructure | `/iac:validate-infra` | Valider une configuration |
| Estimate Cost | `/iac:estimate-cost` | Estimer les couts mensuels |

> **Note:** Les skills utilisent le namespace `iac:` defini dans `.claude-plugin/plugin.json`

---

## Agents Specialises

| Agent | Role | Model |
|-------|------|-------|
| schema-parser | Parser les schemas (MD, YAML, images) | sonnet |
| tf-generator | Generer le code Terraform | sonnet |
| security-reviewer | Valider la securite | haiku |
| factory-sync | Synchroniser avec GitHub | haiku |

---

## Hooks Configures

| Hook | Trigger | Script |
|------|---------|--------|
| PreToolUse | Bash | `scripts/validate-bash-command.sh` |
| PostToolUse | Write\|Edit | `scripts/post-edit-validation.sh` |
| SubagentStop | tf-generator | `scripts/post-generation-check.sh` |

---

## Configuration Providers

| Provider | Status | Fichier |
|----------|--------|---------|
| AWS | Stable | [aws.yaml](config/providers/aws.yaml) |
| Azure | Beta | [azure.yaml](config/providers/azure.yaml) |
| GCP | Beta | [gcp.yaml](config/providers/gcp.yaml) |

---

## Exemples

| Exemple | Description | Complexite |
|---------|-------------|------------|
| [architecture-simple.md](examples/architecture-simple.md) | API web simple | Faible |
| [architecture-microservices.md](examples/architecture-microservices.md) | Plateforme e-commerce | Elevee |
| [architecture.yaml](examples/architecture.yaml) | Data platform (YAML) | Moyenne |

---

## Quick Start

```bash
# 1. Generer une infrastructure depuis un schema
/iac:generate-infra examples/architecture-simple.md

# 2. Valider la configuration generee
/iac:validate-infra ./output/

# 3. Estimer les couts
/iac:estimate-cost ./output/

# 4. Publier un module vers la factory
/iac:publish-module ./modules/my-module

# 5. Importer un module depuis la factory
/iac:import-module aws/networking/vpc
```

---

## Changelog

### v0.1.0 (2025-01-28)
- Structure initiale du plugin
- Migration vers Claude Code Best Practices
  - Skills en dossiers avec SKILL.md + frontmatter YAML
  - Agents avec frontmatter YAML
  - Hooks/scripts pour validation
  - Namespace `iac:` pour les skills
- 5 skills definis
- 4 agents definis
- Configuration multi-provider (AWS, Azure, GCP)
- Templates Terraform de base
- Templates de gouvernance (CloudTrail, GuardDuty, Budgets, KMS)
- Exemples d'architectures
- Schema de validation
- Regles anti-hallucination
