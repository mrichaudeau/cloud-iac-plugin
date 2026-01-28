# Plan d'Adaptation aux Best Practices Claude Code

> Analyse des ecarts et plan de migration vers la structure officielle des plugins Claude Code.

---

## Resume Executif

L'analyse de la documentation officielle Claude Code revele des differences significatives entre notre structure actuelle et les best practices. Ce document presente un plan de migration en 4 phases.

---

## Ecarts Identifies

### 1. Structure du Plugin

| Aspect | Actuel | Best Practice |
|--------|--------|---------------|
| Manifest | `plugin.yaml` | `.claude-plugin/plugin.json` |
| Format | YAML | JSON |
| Emplacement | Racine | Sous-dossier `.claude-plugin/` |

### 2. Structure des Skills

| Aspect | Actuel | Best Practice |
|--------|--------|---------------|
| Emplacement | `skills/skill-name.md` | `skills/skill-name/SKILL.md` |
| Frontmatter | Absent | YAML avec champs specifiques |
| Arguments | Non supportes | `$ARGUMENTS`, `$0`, `$1`... |
| Contexte dynamique | Non supporte | `!`command`` syntax |

**Champs frontmatter requis:**
```yaml
---
name: skill-name
description: Quand utiliser ce skill
disable-model-invocation: true/false
allowed-tools: Read, Grep, Bash
context: fork  # Pour execution en subagent
agent: Explore  # Type de subagent
model: sonnet/opus/haiku
---
```

### 3. Structure des Agents

| Aspect | Actuel | Best Practice |
|--------|--------|---------------|
| Format | Documentation MD | MD avec frontmatter YAML |
| Emplacement | `agents/` | `agents/` (correct) |
| Configuration | Non structuree | Frontmatter standardise |

**Champs frontmatter agents:**
```yaml
---
name: agent-name
description: Quand deleguer a cet agent
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
model: sonnet/haiku/opus/inherit
permissionMode: default/acceptEdits/dontAsk/bypassPermissions/plan
skills:
  - preloaded-skill-1
  - preloaded-skill-2
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---
```

### 4. Hooks

| Aspect | Actuel | Best Practice |
|--------|--------|---------------|
| Implementation | Non implemente | `hooks/hooks.json` |
| Events | N/A | PreToolUse, PostToolUse, SubagentStart, SubagentStop |

### 5. Fichiers Additionnels

| Fichier | Actuel | Best Practice |
|---------|--------|---------------|
| `.mcp.json` | Absent | Configuration MCP servers |
| `.lsp.json` | Absent | Configuration LSP servers |
| `README.md` | Present | Requis pour distribution |

---

## Plan de Migration

### Phase 1: Restructuration du Manifest (Priorite Haute)

**Objectif:** Convertir `plugin.yaml` en `.claude-plugin/plugin.json`

**Actions:**
1. Creer le dossier `.claude-plugin/`
2. Convertir le manifest en JSON
3. Adapter les champs au schema officiel
4. Supprimer `plugin.yaml`

**Structure cible:**
```
.claude-plugin/
└── plugin.json
```

**Schema plugin.json:**
```json
{
  "name": "cloud-iac-generator",
  "description": "Generate production-ready Terraform infrastructure from architecture schemas",
  "version": "0.1.0",
  "author": {
    "name": "Silamir"
  },
  "homepage": "https://github.com/silamir/cloud-iac-plugin",
  "repository": {
    "type": "git",
    "url": "https://github.com/silamir/cloud-iac-plugin"
  },
  "license": "MIT"
}
```

---

### Phase 2: Migration des Skills (Priorite Haute)

**Objectif:** Convertir les skills au format officiel avec SKILL.md

**Actions pour chaque skill:**

#### 2.1 generate-infra

**Structure actuelle:**
```
skills/generate-infra.md
```

**Structure cible:**
```
skills/generate-infra/
├── SKILL.md
├── templates/
│   └── (liens vers templates/)
└── examples/
    └── (liens vers examples/)
```

**Contenu SKILL.md:**
```yaml
---
name: generate-infra
description: Generate Terraform infrastructure from architecture schemas. Use when the user provides an architecture diagram, markdown description, YAML config, or asks to create infrastructure.
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
argument-hint: [schema-file-or-description]
---

# Generate Infrastructure

Generate production-ready Terraform code from architecture schemas.

## Input

$ARGUMENTS

## Process

1. Parse the input schema (supports: .md, .yaml, .json, .drawio, images)
2. Detect provider, environment, and components
3. Enrich with governance, security, and best practices
4. Generate Terraform code structure
5. Validate against anti-hallucination rules

## Supporting Files

- For templates, see [templates/](../../templates/)
- For examples, see [examples/](../../examples/)
- For provider configs, see [config/providers/](../../config/providers/)
```

#### 2.2 publish-module

```yaml
---
name: publish-module
description: Publish a Terraform module to the cloud_iac_factory repository. Use after validating a module is ready for sharing.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep
context: fork
agent: general-purpose
argument-hint: [module-path]
---
```

#### 2.3 import-module

```yaml
---
name: import-module
description: Import a Terraform module from the cloud_iac_factory repository. Use when user wants to use an existing module.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, WebFetch
argument-hint: [module-path] [version?]
---
```

#### 2.4 validate-infra

```yaml
---
name: validate-infra
description: Validate Terraform infrastructure configuration for security, compliance, and best practices. Use proactively after generating or modifying infrastructure code.
disable-model-invocation: false
allowed-tools: Read, Bash, Glob, Grep
context: fork
agent: Explore
argument-hint: [terraform-directory]
---
```

#### 2.5 estimate-cost

```yaml
---
name: estimate-cost
description: Estimate monthly costs for Terraform infrastructure. Use when user asks about pricing or costs.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, WebFetch
argument-hint: [terraform-directory]
---
```

---

### Phase 3: Migration des Agents (Priorite Moyenne)

**Objectif:** Convertir les agents au format officiel avec frontmatter

#### 3.1 tf-generator

```yaml
---
name: tf-generator
description: Terraform code generation specialist. Generates HCL code following best practices, naming conventions, and security standards. Use when infrastructure code needs to be written.
tools: Read, Write, Edit, Glob, Grep
model: sonnet
skills:
  - validate-infra
---

You are a Terraform code generation specialist.

## Capabilities

- Generate HCL code following HashiCorp best practices
- Apply consistent naming conventions
- Implement security defaults (encryption, least privilege)
- Create modular, reusable code

## Process

1. Read the parsed architecture requirements
2. Load provider configuration from config/providers/
3. Generate _providers.tf, _variables.tf, _locals.tf
4. Generate module calls or resources
5. Generate _outputs.tf
6. Run terraform fmt

## Rules

- NEVER hardcode credentials
- ALWAYS use variables for configurable values
- ALWAYS add appropriate tags
- ALWAYS encrypt data at rest and in transit
```

#### 3.2 security-reviewer

```yaml
---
name: security-reviewer
description: Security validation specialist. Reviews infrastructure code for vulnerabilities, compliance issues, and security best practices. Use proactively after code generation.
tools: Read, Grep, Glob
disallowedTools: Write, Edit
model: haiku
---

You are a security review specialist for Terraform infrastructure.

## Checks

- No hardcoded credentials or secrets
- No overly permissive IAM policies
- No public access to databases
- No sensitive ports exposed to 0.0.0.0/0
- Encryption enabled for all data stores
- TLS 1.2+ for all connections
- Logging and monitoring configured

## Output

Provide findings organized by severity:
- CRITICAL: Must fix before deployment
- HIGH: Should fix soon
- MEDIUM: Recommended improvement
- LOW: Nice to have
```

#### 3.3 factory-sync

```yaml
---
name: factory-sync
description: GitHub factory synchronization agent. Manages module catalog, creates PRs, and syncs with cloud_iac_factory repository.
tools: Read, Bash, WebFetch
model: haiku
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "scripts/validate-git-command.sh"
---

You are a GitHub synchronization agent for the cloud_iac_factory.

## Operations

- Get catalog: fetch and cache catalog.json
- Check module exists: verify module in factory
- Compare versions: diff local vs factory
- Create PR: branch, commit, push, create PR

## GitHub CLI Commands

Use `gh` CLI for all GitHub operations:
- `gh api repos/{repo}/contents/{path}` - Read files
- `gh pr create` - Create pull requests
- `gh pr view` - Check PR status
```

#### 3.4 schema-parser

```yaml
---
name: schema-parser
description: Architecture schema parsing specialist. Extracts infrastructure components from markdown, YAML, draw.io, and images. Use when processing user-provided architecture descriptions.
tools: Read, Glob, Grep
disallowedTools: Write, Edit, Bash
model: sonnet
---

You are an architecture schema parser.

## Supported Formats

- Markdown (.md): Parse headings, lists, code blocks
- YAML/JSON (.yaml, .yml, .json): Parse structured config
- Draw.io (.drawio, .xml): Extract shapes and connections
- Images (.png, .jpg, .webp): Use vision to identify components

## Output Format

Always output a standardized YAML structure:
- metadata (source, confidence)
- context (provider, environment, region)
- components (type, name, config)
- relations (from, to, type)
```

---

### Phase 4: Implementation des Hooks (Priorite Moyenne)

**Objectif:** Creer `hooks/hooks.json` pour automatiser les workflows

**Structure:**
```
hooks/
└── hooks.json
```

**Contenu hooks.json:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "scripts/post-edit-validation.sh $FILE"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "tf-generator",
        "hooks": [
          {
            "type": "command",
            "command": "scripts/post-generation-check.sh"
          }
        ]
      }
    ]
  }
}
```

**Scripts a creer:**

```bash
# scripts/post-edit-validation.sh
#!/bin/bash
FILE="$1"
if [[ "$FILE" == *.tf ]]; then
  terraform fmt -check "$FILE" || exit 1
  echo "Terraform file formatted correctly"
fi
exit 0
```

```bash
# scripts/post-generation-check.sh
#!/bin/bash
if [ -d "output" ]; then
  cd output
  terraform fmt -recursive
  terraform validate
fi
exit 0
```

---

## Structure Finale

```
cloud-iac-generator/
├── .claude-plugin/
│   └── plugin.json                    # Manifest officiel
│
├── skills/
│   ├── generate-infra/
│   │   ├── SKILL.md
│   │   └── reference.md               # Documentation detaillee
│   ├── publish-module/
│   │   └── SKILL.md
│   ├── import-module/
│   │   └── SKILL.md
│   ├── validate-infra/
│   │   └── SKILL.md
│   └── estimate-cost/
│       └── SKILL.md
│
├── agents/
│   ├── tf-generator.md
│   ├── security-reviewer.md
│   ├── factory-sync.md
│   └── schema-parser.md
│
├── hooks/
│   └── hooks.json
│
├── scripts/
│   ├── post-edit-validation.sh
│   ├── post-generation-check.sh
│   └── validate-git-command.sh
│
├── config/                            # Unchanged
│   ├── defaults.yaml
│   ├── factory.yaml
│   ├── validation-schema.yaml
│   ├── anti-hallucination.yaml
│   └── providers/
│       ├── aws.yaml
│       ├── azure.yaml
│       └── gcp.yaml
│
├── templates/                         # Unchanged
│   ├── _backend.tf.tmpl
│   ├── _providers.tf.tmpl
│   └── ...
│
├── examples/                          # Unchanged
│   ├── architecture-simple.md
│   └── ...
│
├── docs/                              # Unchanged
│   ├── 00-VISION.md
│   └── ...
│
├── README.md
├── CLAUDE.md
└── INDEX.md
```

---

## Checklist de Migration

### Phase 1 - Manifest
- [ ] Creer `.claude-plugin/plugin.json`
- [ ] Supprimer `plugin.yaml`
- [ ] Mettre a jour CLAUDE.md

### Phase 2 - Skills
- [ ] Creer `skills/generate-infra/SKILL.md`
- [ ] Creer `skills/publish-module/SKILL.md`
- [ ] Creer `skills/import-module/SKILL.md`
- [ ] Creer `skills/validate-infra/SKILL.md`
- [ ] Creer `skills/estimate-cost/SKILL.md`
- [ ] Supprimer anciens fichiers `skills/*.md`

### Phase 3 - Agents
- [ ] Migrer `agents/tf-generator.md` avec frontmatter
- [ ] Migrer `agents/security-reviewer.md` avec frontmatter
- [ ] Migrer `agents/factory-sync.md` avec frontmatter
- [ ] Migrer `agents/schema-parser.md` avec frontmatter

### Phase 4 - Hooks
- [ ] Creer `hooks/hooks.json`
- [ ] Creer `scripts/post-edit-validation.sh`
- [ ] Creer `scripts/post-generation-check.sh`
- [ ] Creer `scripts/validate-git-command.sh`

### Validation
- [ ] Tester avec `claude --plugin-dir ./cloud-iac-generator`
- [ ] Verifier `/cloud-iac-generator:generate-infra`
- [ ] Verifier agents dans `/agents`
- [ ] Verifier hooks fonctionnent

---

## Benefices Attendus

1. **Compatibilite officielle** - Le plugin fonctionnera avec les futures versions de Claude Code
2. **Namespacing** - Skills prefixes avec le nom du plugin (`/cloud-iac-generator:generate-infra`)
3. **Distribution** - Peut etre publie sur un marketplace
4. **Auto-invocation** - Claude peut invoquer les skills automatiquement selon le contexte
5. **Subagents** - Execution isolee avec `context: fork`
6. **Hooks** - Automatisation des validations post-generation
7. **Preloaded skills** - Agents peuvent charger des skills au demarrage

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Perte de fonctionnalites | Moyen | Tester incrementalement |
| Breaking changes | Eleve | Garder backup de l'ancien format |
| Complexite accrue | Faible | Documentation detaillee |

---

## Prochaines Etapes

1. **Valider ce plan** avec l'utilisateur
2. **Executer Phase 1** - Migration du manifest
3. **Executer Phase 2** - Migration des skills
4. **Tester** avec `--plugin-dir`
5. **Executer Phase 3** - Migration des agents
6. **Executer Phase 4** - Implementation des hooks
7. **Documentation finale** et publication
