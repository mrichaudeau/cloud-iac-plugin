# IaC Factory Plugin - Claude Code

> **Plugin Claude Code pour la génération automatique d'infrastructure Terraform production-ready**

---

## Vision du Projet

Ce plugin permet de :
1. **Générer** une infrastructure Terraform complète à partir d'un schéma ou description
2. **Enrichir automatiquement** avec les best practices (sécurité, logs, finops, compliance)
3. **Capitaliser** sur les modules générés via une factory GitHub centralisée
4. **Réutiliser** les modules validés pour les futures générations

---

## Quick Start

### 1. Installation via Marketplace

```bash
# Démarrer Claude Code
claude

# Ajouter le marketplace et installer le plugin
/plugin marketplace add mrichaudeau/cloud-iac-plugin
/plugin install iac@mrichaudeau-cloud-iac-plugin
```

**Alternative : Installation locale (développement)**
```bash
git clone https://github.com/mrichaudeau/cloud-iac-plugin.git ~/plugins/iac-plugin
claude --plugin-dir ~/plugins/iac-plugin
```

### 2. Configuration (optionnel)

```bash
# Token GitHub pour accéder à la factory
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
```

### 3. Générer une infrastructure

```bash
# Description textuelle
/iac:generate-infra "Application web Django avec PostgreSQL en production sur AWS"

# Depuis un fichier
/iac:generate-infra ./architecture.md
```

### 4. Valider et déployer

```bash
# Valider la sécurité
/iac:validate-infra ./infrastructure

# Estimer les coûts
/iac:estimate-cost ./infrastructure

# Déployer
cd infrastructure
terraform init
terraform plan -var-file=environments/prod.tfvars
terraform apply
```

---

## Skills Disponibles

| Skill | Description |
|-------|-------------|
| `/iac:generate-infra` | Génère une infrastructure Terraform complète |
| `/iac:validate-infra` | Valide sécurité et compliance |
| `/iac:estimate-cost` | Estime les coûts mensuels |
| `/iac:publish-module` | Publie un module vers la factory |
| `/iac:import-module` | Importe un module depuis la factory |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PLUGIN CLAUDE CODE                                   │
│                                                                             │
│  SKILLS (Commandes utilisateur)                                             │
│  /iac:generate-infra  → Génère infrastructure complète                      │
│  /iac:publish-module  → Publie module vers factory                          │
│  /iac:import-module   → Importe module depuis factory                       │
│  /iac:validate-infra  → Valide sécurité et compliance                       │
│  /iac:estimate-cost   → Estime les coûts                                    │
│                                                                             │
│  AGENTS (Spécialistes)                                                      │
│  tf-generator        → Génération code Terraform                            │
│  security-reviewer   → Review sécurité                                      │
│  factory-sync        → Synchronisation factory                              │
│  schema-parser       → Parsing schémas d'architecture                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CLOUD IAC FACTORY (GitHub)                              │
│                                                                             │
│  modules/aws/       modules/azure/       modules/gcp/                       │
│  patterns/          policies/            catalog.json                       │
│                                                                             │
│  https://github.com/mrichaudeau/cloud_iac_factory                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Structure du Plugin

```
infra_as_code_pluggin/
├── .claude-plugin/
│   └── plugin.json               # Manifest (namespace: "iac")
│
├── skills/                       # Skills avec frontmatter YAML
│   ├── generate-infra/
│   │   ├── SKILL.md
│   │   ├── workflow.md
│   │   └── formats.md
│   ├── publish-module/
│   ├── import-module/
│   ├── validate-infra/
│   └── estimate-cost/
│
├── agents/                       # Agents spécialisés
│   ├── tf-generator.md
│   ├── security-reviewer.md
│   ├── factory-sync.md
│   └── schema-parser.md
│
├── hooks/
│   └── hooks.json               # Configuration des hooks
│
├── scripts/                     # Scripts pour les hooks
│   ├── validate-bash-command.sh
│   ├── post-edit-validation.sh
│   └── post-generation-check.sh
│
├── config/                      # Configuration
│   ├── factory.yaml             # Connexion à la factory
│   ├── defaults.yaml            # Valeurs par défaut
│   └── providers/               # Config par provider
│
├── templates/                   # Templates Terraform
│   ├── _backend.tf.tmpl
│   ├── _providers.tf.tmpl
│   └── governance/
│
├── examples/                    # Exemples d'architectures
│
├── docs/                        # Documentation
│   ├── INSTALLATION.md          # Guide d'installation
│   ├── 00-VISION.md
│   ├── 01-ARCHITECTURE.md
│   └── ...
│
├── CLAUDE.md                    # Instructions pour Claude
├── INDEX.md                     # Index de la documentation
└── README.md                    # Ce fichier
```

---

## Documentation

| Document | Description |
|----------|-------------|
| **[INSTALLATION.md](docs/INSTALLATION.md)** | **Guide d'installation et d'utilisation** |
| [CLAUDE.md](CLAUDE.md) | Instructions pour Claude Code |
| [INDEX.md](INDEX.md) | Index complet du projet |
| [00-VISION.md](docs/00-VISION.md) | Vision et objectifs |
| [01-ARCHITECTURE.md](docs/01-ARCHITECTURE.md) | Architecture technique |
| [02-WORKFLOW.md](docs/02-WORKFLOW.md) | Workflow de génération |
| [03-ENRICHMENT.md](docs/03-ENRICHMENT.md) | Logique d'enrichissement |
| [04-FACTORY.md](docs/04-FACTORY.md) | Factory GitHub |
| [05-SECURITY.md](docs/05-SECURITY.md) | Sécurité et guardrails |
| [06-CONVENTIONS.md](docs/06-CONVENTIONS.md) | Conventions de nommage |
| [07-GOVERNANCE.md](docs/07-GOVERNANCE.md) | Règles de gouvernance |

---

## Prérequis

- **Claude Code CLI** >= 1.0.0
- **Terraform** >= 1.5.0
- **Git** >= 2.0
- **GITHUB_TOKEN** (optionnel, pour la factory)

---

## Liens

- **Plugin**: [github.com/mrichaudeau/cloud-iac-plugin](https://github.com/mrichaudeau/cloud-iac-plugin)
- **Factory**: [github.com/mrichaudeau/cloud_iac_factory](https://github.com/mrichaudeau/cloud_iac_factory)

---

## Licence

MIT
