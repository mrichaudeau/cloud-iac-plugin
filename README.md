# IaC Factory Plugin - Claude Code

> **Plugin Claude Code pour la generation automatique d'infrastructure Terraform production-ready**

## Vision du Projet

Ce plugin permet de :
1. **Generer** une infrastructure Terraform complete a partir d'un schema ou description
2. **Enrichir automatiquement** avec les best practices (securite, logs, finops, compliance)
3. **Capitaliser** sur les modules generes via une factory GitHub centralisee
4. **Reutiliser** les modules valides pour les futures generations

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PLUGIN CLAUDE CODE                                   │
│                                                                             │
│  SKILLS (Commandes utilisateur)                                             │
│  /generate-infra    → Genere infrastructure complete                        │
│  /publish-module    → Publie module vers factory                            │
│  /import-module     → Importe module depuis factory                         │
│  /validate-infra    → Valide securite et compliance                         │
│  /estimate-cost     → Estime les couts                                      │
│                                                                             │
│  AGENTS (Specialistes)                                                       │
│  tf-generator       → Generation code Terraform                             │
│  security-reviewer  → Review securite                                       │
│  factory-sync       → Synchronisation factory                               │
│  schema-parser      → Parsing schemas d'architecture                        │
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
└─────────────────────────────────────────────────────────────────────────────┘
```

## Structure du Plugin

```
infra_as_code_pluggin/
├── README.md                    # Ce fichier
├── CLAUDE.md                    # Instructions principales pour Claude Code
│
├── docs/                        # Documentation complete
│   ├── 00-VISION.md            # Vision et objectifs du projet
│   ├── 01-ARCHITECTURE.md      # Architecture technique
│   ├── 02-WORKFLOW.md          # Workflow de generation
│   ├── 03-ENRICHMENT.md        # Logique d'enrichissement
│   ├── 04-FACTORY.md           # Specification de la factory
│   ├── 05-SECURITY.md          # Guardrails securite
│   ├── 06-CONVENTIONS.md       # Conventions de nommage
│   ├── 07-GOVERNANCE.md        # Regles de gouvernance
│   └── 08-ROADMAP.md           # Plan d'implementation
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
    ├── factory.yaml
    ├── defaults.yaml
    └── providers/
        ├── aws.yaml
        ├── azure.yaml
        └── gcp.yaml
```

## Liens avec le Projet Existant

Ce plugin s'appuie sur le framework Terraform existant dans `cloud_iac/` :
- Reutilise les modules Terraform developpes
- Applique les memes conventions et standards
- Integre les regles de gouvernance definies

## Quick Start

```bash
# Dans un projet client
claude

# Generer une infrastructure
/generate-infra "Application web Django avec PostgreSQL en production sur AWS"

# Apres validation et deploiement, publier vers la factory
/publish-module ./modules/custom-module

# Importer un module existant
/import-module aws/networking/vpc
```

## Documentation

Voir le dossier `docs/` pour la documentation complete :
- [Vision du Projet](docs/00-VISION.md)
- [Architecture Technique](docs/01-ARCHITECTURE.md)
- [Workflow de Generation](docs/02-WORKFLOW.md)
- [Logique d'Enrichissement](docs/03-ENRICHMENT.md)
- [Factory GitHub](docs/04-FACTORY.md)
- [Securite](docs/05-SECURITY.md)
- [Conventions](docs/06-CONVENTIONS.md)
- [Gouvernance](docs/07-GOVERNANCE.md)
- [Roadmap](docs/08-ROADMAP.md)
