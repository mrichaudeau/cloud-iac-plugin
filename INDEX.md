# Cloud IaC Plugin - Index

> Index complet de la documentation et des fichiers du plugin

---

## Structure du Projet

```
infra_as_code_pluggin/
├── plugin.yaml                    # Manifest du plugin
├── README.md                      # Documentation principale
├── CLAUDE.md                      # Instructions pour Claude Code
├── INDEX.md                       # Ce fichier
│
├── docs/                          # Documentation detaillee
│   ├── 00-VISION.md              # Vision et objectifs
│   ├── 01-ARCHITECTURE.md        # Architecture du systeme
│   ├── 02-WORKFLOW.md            # Workflow de generation
│   ├── 03-ENRICHMENT.md          # Logique d'enrichissement
│   ├── 04-FACTORY.md             # Integration factory GitHub
│   ├── 05-SECURITY.md            # Securite et guardrails
│   ├── 06-CONVENTIONS.md         # Conventions de nommage
│   ├── 07-GOVERNANCE.md          # Composants de gouvernance
│   └── 08-ROADMAP.md             # Roadmap d'implementation
│
├── skills/                        # Skills Claude Code
│   ├── generate-infra.md         # /generate-infra
│   ├── publish-module.md         # /publish-module
│   ├── import-module.md          # /import-module
│   ├── validate-infra.md         # /validate-infra
│   └── estimate-cost.md          # /estimate-cost
│
├── agents/                        # Agents specialises
│   ├── tf-generator.md           # Generation Terraform
│   ├── security-reviewer.md      # Review securite
│   ├── factory-sync.md           # Sync avec factory
│   └── schema-parser.md          # Parsing des schemas
│
├── config/                        # Configuration
│   ├── defaults.yaml             # Valeurs par defaut
│   ├── factory.yaml              # Config factory GitHub
│   ├── validation-schema.yaml    # Schema de validation
│   ├── anti-hallucination.yaml   # Regles anti-hallucination
│   └── providers/
│       ├── aws.yaml              # Config AWS
│       ├── azure.yaml            # Config Azure
│       └── gcp.yaml              # Config GCP
│
├── templates/                     # Templates Terraform
│   ├── _backend.tf.tmpl          # Backend configuration
│   ├── _providers.tf.tmpl        # Provider configuration
│   ├── _variables.tf.tmpl        # Variables communes
│   ├── _locals.tf.tmpl           # Locals et data sources
│   ├── _outputs.tf.tmpl          # Outputs
│   ├── module-call.tf.tmpl       # Appel de module
│   └── governance/
│       ├── _cloudtrail.tf.tmpl   # CloudTrail
│       ├── _guardduty.tf.tmpl    # GuardDuty
│       ├── _budgets.tf.tmpl      # AWS Budgets
│       └── _kms.tf.tmpl          # KMS Keys
│
└── examples/                      # Exemples d'architectures
    ├── architecture-simple.md    # API web simple
    ├── architecture-microservices.md  # Microservices
    └── architecture.yaml         # Format YAML structure
```

---

## Documentation par Theme

### Vision & Architecture
| Fichier | Description |
|---------|-------------|
| [00-VISION.md](docs/00-VISION.md) | Vision, objectifs, workflow global |
| [01-ARCHITECTURE.md](docs/01-ARCHITECTURE.md) | Architecture technique complete |
| [08-ROADMAP.md](docs/08-ROADMAP.md) | Plan d'implementation (12 semaines) |

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
| [publish-module.md](skills/publish-module.md) | Publication de modules |
| [import-module.md](skills/import-module.md) | Import de modules |

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
| Generate Infrastructure | `/generate-infra` | Generer Terraform depuis un schema |
| Publish Module | `/publish-module` | Publier un module vers la factory |
| Import Module | `/import-module` | Importer un module depuis la factory |
| Validate Infrastructure | `/validate-infra` | Valider une configuration |
| Estimate Cost | `/estimate-cost` | Estimer les couts mensuels |

---

## Agents Specialises

| Agent | Role |
|-------|------|
| schema-parser | Parser les schemas (MD, YAML, images) |
| tf-generator | Generer le code Terraform |
| security-reviewer | Valider la securite |
| factory-sync | Synchroniser avec GitHub |

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
/generate-infra examples/architecture-simple.md

# 2. Valider la configuration generee
/validate-infra ./output/

# 3. Estimer les couts
/estimate-cost ./output/

# 4. Publier un module vers la factory
/publish-module ./modules/my-module

# 5. Importer un module depuis la factory
/import-module aws/networking/vpc
```

---

## Prochaines Etapes

1. **Implementation des skills** - Creer les fichiers de code
2. **Integration factory** - Configurer le repository GitHub
3. **Tests** - Ecrire les tests unitaires et d'integration
4. **CI/CD** - Configurer les workflows GitHub Actions
5. **Documentation** - Completer les guides utilisateur

---

## Changelog

### v0.1.0 (2025-01-28)
- Structure initiale du plugin
- Documentation complete (8 fichiers)
- 5 skills definis
- 4 agents definis
- Configuration multi-provider (AWS, Azure, GCP)
- Templates Terraform de base
- Templates de gouvernance (CloudTrail, GuardDuty, Budgets, KMS)
- Exemples d'architectures
- Schema de validation
- Regles anti-hallucination
