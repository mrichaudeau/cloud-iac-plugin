---
name: generate-infra
description: Generate Terraform infrastructure from architecture schemas. Use when the user provides an architecture diagram, markdown description, YAML config, or asks to create infrastructure.
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch
argument-hint: [schema-file-or-description]
---

# /iac:generate-infra

Generate production-ready Terraform infrastructure from architecture schemas.

## Usage

```
/iac:generate-infra <description or path to schema>
```

## Examples

```
/iac:generate-infra "Web app Django with PostgreSQL on AWS prod"
/iac:generate-infra ./schema.md
/iac:generate-infra ./architecture.drawio
```

## Workflow

1. **Parse Input** - Identify format (text, markdown, draw.io, image, YAML)
2. **Consult Factory** - Check available modules in catalog.json
3. **Enrich** - Add dependencies and governance per `docs/03-ENRICHMENT.md`
4. **Generate** - Create infrastructure structure per `docs/06-CONVENTIONS.md`
5. **Validate** - Check security guardrails and anti-hallucination

## Agents Invoked

| Agent | Role |
|-------|------|
| `schema-parser` | Complex input parsing (draw.io, images) |
| `tf-generator` | Terraform code generation |
| `security-reviewer` | Security validation |

## Output

- `./infrastructure/` directory with complete Terraform code
- `README.md` with setup instructions
- `DECISIONS.md` with justifications
- `COST_ESTIMATE.md` with cost estimation

## Critical Rules

- NEVER hardcode credentials
- NEVER open 0.0.0.0/0 on sensitive ports (22, 3389, 3306, 5432)
- ALWAYS encrypt data at rest
- ALWAYS add mandatory tags
- ONLY use modules that exist in factory catalog

See `workflow.md` and `formats.md` for detailed documentation.
