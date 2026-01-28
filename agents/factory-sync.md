# Agent: factory-sync

> Agent specialise dans la synchronisation avec la Cloud IaC Factory.

---

## Role

Gerer les interactions avec le repository GitHub `cloud_iac_factory` :
- Lire le catalog des modules
- Verifier l'existence des modules
- Comparer les versions
- Creer des PR pour publication

---

## Invocation

Cet agent est invoque par :
- Skill `/generate-infra` (consultation catalog)
- Skill `/publish-module` (publication)
- Skill `/import-module` (import)

---

## Configuration

Fichier `config/factory.yaml` :

```yaml
factory:
  # Repository GitHub
  repository: "org/cloud_iac_factory"
  branch: "main"

  # Authentification
  # Token stocke dans variable d'environnement GITHUB_TOKEN
  auth_method: "token"

  # URLs
  base_url: "https://github.com"
  api_url: "https://api.github.com"
  raw_url: "https://raw.githubusercontent.com"

  # Fichiers cles
  catalog_path: "catalog.json"
  modules_path: "modules"
  patterns_path: "patterns"

  # Cache
  cache_ttl: 300  # secondes
```

---

## Operations

### 1. Get Catalog

Recuperer le catalog des modules disponibles.

```yaml
operation: get_catalog

input: {}

output:
  catalog:
    version: "1.0.0"
    last_updated: "2025-01-28T10:00:00Z"
    modules:
      "aws/networking/vpc":
        latest: "1.2.0"
        versions: ["1.0.0", "1.1.0", "1.2.0"]
        description: "VPC production-ready"
      # ...
```

### 2. Check Module Exists

Verifier si un module existe dans la factory.

```yaml
operation: check_module_exists

input:
  module_path: "aws/networking/vpc"
  version: "1.2.0"  # optionnel, defaut = latest

output:
  exists: true
  version: "1.2.0"
  metadata_url: "https://..."
```

### 3. Get Module Metadata

Recuperer les metadonnees d'un module.

```yaml
operation: get_module_metadata

input:
  module_path: "aws/networking/vpc"
  version: "1.2.0"

output:
  metadata:
    schema_version: "2.0"
    module:
      name: "vpc"
      version: "1.2.0"
      provider: "aws"
      category: "networking"
      # ... contenu complet de MODULE_METADATA.yaml
```

### 4. Compare Module

Comparer un module local avec la version factory.

```yaml
operation: compare_module

input:
  local_path: "./modules/my-vpc"
  factory_path: "aws/networking/vpc"

output:
  comparison:
    status: "different"  # same, different, new
    local_version: "1.2.1"
    factory_version: "1.2.0"
    suggested_bump: "patch"
    differences:
      - file: "main.tf"
        type: "modified"
        additions: 15
        deletions: 3
      - file: "variables.tf"
        type: "modified"
        additions: 5
        deletions: 0
```

### 5. Create PR

Creer une Pull Request pour publier un module.

```yaml
operation: create_pr

input:
  module_path: "aws/networking/my-vpc"
  version: "1.0.0"
  local_path: "./modules/my-vpc"
  description: "Initial release of custom VPC module"

output:
  pr:
    number: 123
    url: "https://github.com/org/cloud_iac_factory/pull/123"
    branch: "feat/module-aws-networking-my-vpc-v1.0.0"
    status: "open"
```

---

## Process Details

### Get Catalog

```
1. Verifier le cache local
   IF cache valide (< ttl)
     RETURN cached catalog
   ENDIF

2. Requete GitHub API
   GET /repos/{repo}/contents/catalog.json

3. Parser le JSON

4. Mettre en cache

5. Retourner le catalog
```

### Create PR

```
1. Authentification
   - Verifier GITHUB_TOKEN

2. Creer la branche
   - Base: main
   - Nom: feat/module-{path}-v{version}

3. Copier les fichiers
   - Creer le dossier modules/{path}/v{version}/
   - Upload chaque fichier

4. Generer CHANGELOG.md (si absent)

5. Creer la PR
   - Titre: "feat(module): Add {path} v{version}"
   - Body: Template avec description, checklist

6. Retourner les infos de la PR
```

---

## GitHub API Calls

### Lire un fichier

```bash
GET /repos/{owner}/{repo}/contents/{path}
Accept: application/vnd.github.v3+json
Authorization: token {GITHUB_TOKEN}
```

### Creer une branche

```bash
POST /repos/{owner}/{repo}/git/refs
{
  "ref": "refs/heads/feat/module-xxx",
  "sha": "{base_sha}"
}
```

### Creer/Mettre a jour un fichier

```bash
PUT /repos/{owner}/{repo}/contents/{path}
{
  "message": "Add module file",
  "content": "{base64_content}",
  "branch": "feat/module-xxx"
}
```

### Creer une PR

```bash
POST /repos/{owner}/{repo}/pulls
{
  "title": "feat(module): Add xxx v1.0.0",
  "body": "...",
  "head": "feat/module-xxx",
  "base": "main"
}
```

---

## Cache

Le cache local evite les requetes repetees :

```
~/.iac-factory-cache/
├── catalog.json           # Cache du catalog
├── catalog.json.meta      # Metadata (timestamp)
└── modules/
    └── aws/
        └── networking/
            └── vpc/
                └── v1.2.0/
                    └── MODULE_METADATA.yaml
```

### Invalidation

Le cache est invalide :
- Apres TTL (default: 5 minutes)
- Apres une publication reussie
- Manuellement via option `--no-cache`

---

## Gestion des Erreurs

| Erreur | Cause | Action |
|--------|-------|--------|
| 401 Unauthorized | Token invalide | Verifier GITHUB_TOKEN |
| 403 Forbidden | Permissions insuffisantes | Verifier acces repo |
| 404 Not Found | Module/fichier inexistant | Verifier le chemin |
| 409 Conflict | Branche existe deja | Incrementer version ou supprimer branche |
| 422 Unprocessable | PR existe deja | Mettre a jour la PR existante |
| Rate Limit | Trop de requetes | Attendre ou utiliser cache |

---

## Validation Anti-Hallucination

Avant de generer du code utilisant un module :

```python
def validate_module_reference(module_path, version=None):
    """
    Valide qu'un module existe dans la factory.
    """
    catalog = get_catalog()

    if module_path not in catalog['modules']:
        raise HallucinationError(f"Module {module_path} not found in factory")

    module_info = catalog['modules'][module_path]

    if version and version not in module_info['versions']:
        raise HallucinationError(f"Version {version} not found for {module_path}")

    return True
```
