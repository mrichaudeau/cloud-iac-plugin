---
name: import-module
description: Import a Terraform module from the cloud_iac_factory repository.
disable-model-invocation: true
allowed-tools: Read, Write, Bash, WebFetch, Glob
argument-hint: [module-path] [version?]
---

# /iac:import-module

Import a module from the Cloud IaC Factory into the current project.

## Usage

```
/iac:import-module <module_path> [version]
```

## Examples

```
/iac:import-module aws/networking/vpc
/iac:import-module aws/networking/vpc v1.2.0
/iac:import-module aws/compute/ecs_service latest
```

## Workflow

1. **Consult Catalog** - Retrieve catalog.json, find module
2. **Display Information** - Show versions, dependencies
3. **Generate Import Code** - Create module call with variables
4. **Provide Instructions** - Next steps for integration

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `version` | Specific version | latest |
| `--local` | Copy module locally | false |
| `--list` | List available modules | - |
| `--search <term>` | Search modules | - |

## List Mode

```
/iac:import-module --list
/iac:import-module --list aws
/iac:import-module --list aws/networking
```

## Search Mode

```
/iac:import-module --search database
```

## Generated Code

```hcl
module "vpc" {
  source = "git::https://github.com/mrichaudeau/cloud_iac_factory.git//modules/aws/networking/vpc/v1.2.0"

  project     = var.project
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"

  tags = local.mandatory_tags
}
```

## Agents Invoked

| Agent | Role |
|-------|------|
| `factory-sync` | Factory connection and reading |

## Output

- Module call code in appropriate infrastructure directory
- Dependency warnings if required modules are missing
- Instructions for `terraform init`
