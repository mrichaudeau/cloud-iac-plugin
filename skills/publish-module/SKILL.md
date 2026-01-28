---
name: publish-module
description: Publish a Terraform module to the cloud_iac_factory repository.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep
argument-hint: [module-path]
---

# /iac:publish-module

Publish a validated Terraform module to the Cloud IaC Factory.

## Usage

```
/iac:publish-module <module_path>
```

## Examples

```
/iac:publish-module ./modules/my-custom-vpc
/iac:publish-module ./infrastructure/modules/app-security-group
```

## Prerequisites

Before publishing:

1. **Module has been deployed and manually validated**
2. **Structure conforms** to required files
3. **MODULE_METADATA.yaml present** and complete
4. **Tests passing** (if present)

## Required Structure

```
modules/my-module/
├── main.tf              # Required
├── variables.tf         # Required
├── outputs.tf           # Required
├── versions.tf          # Required
├── locals.tf            # Optional
├── MODULE_METADATA.yaml # Required
├── README.md            # Required
└── examples/            # Recommended
    ├── minimal/
    └── complete/
```

## Workflow

1. **Local Validation** - Check structure, validate Terraform
2. **Factory Comparison** - Check if module exists, calculate version bump
3. **User Confirmation** - Display changes for approval
4. **Create PR** - Create branch and pull request

## Version Bump Detection

| Change Type | Version Bump |
|-------------|--------------|
| New REQUIRED variables | MAJOR |
| Removed OPTIONAL variables | MAJOR |
| Removed outputs | MAJOR |
| New features | MINOR |
| Bug fixes | PATCH |
| Documentation only | PATCH |

## Agents Invoked

| Agent | Role |
|-------|------|
| `factory-sync` | Factory connection and comparison |

## Output

- PR created in cloud_iac_factory repository
- Branch: `feat/module-{provider}-{category}-{name}-v{version}`
- URL returned for review
