# Skill: /publish-module

> Publie un module Terraform valide vers la Cloud IaC Factory.

---

## Usage

```
/publish-module <chemin_module>
```

### Exemples

```
/publish-module ./modules/my-custom-vpc
/publish-module ./infrastructure/modules/app-security-group
```

---

## Prerequis

Avant de publier un module :

1. **Le module doit avoir ete deploye et valide manuellement**
2. **Structure conforme** avec les fichiers requis
3. **MODULE_METADATA.yaml present** et complet
4. **Tests passants** (si presents)

### Structure Requise

```
modules/my-module/
├── main.tf              # Obligatoire
├── variables.tf         # Obligatoire
├── outputs.tf           # Obligatoire
├── versions.tf          # Obligatoire
├── locals.tf            # Optionnel
├── MODULE_METADATA.yaml # Obligatoire
├── README.md            # Obligatoire
└── examples/            # Recommande
    ├── minimal/
    └── complete/
```

---

## Workflow

### 1. Validation Locale

```
1.1 Verifier structure du module
    ├── main.tf present ?
    ├── variables.tf present ?
    ├── outputs.tf present ?
    ├── versions.tf present ?
    └── MODULE_METADATA.yaml present ?

1.2 Valider MODULE_METADATA.yaml
    ├── Schema version correct ?
    ├── Champs obligatoires remplis ?
    └── Version semantique valide ?

1.3 Validation Terraform
    ├── terraform fmt -check
    └── terraform validate

1.4 Scan securite (optionnel)
    └── tflint
```

### 2. Comparaison avec Factory

```
2.1 Telecharger catalog.json de la factory

2.2 Chercher si le module existe
    ├── SI NOUVEAU → proposer v1.0.0
    └── SI EXISTE → calculer diff et proposer version bump

2.3 Determiner le type de changement
    ├── MAJOR: breaking changes (variables required ajoutees/supprimees)
    ├── MINOR: nouvelles fonctionnalites
    └── PATCH: bug fixes
```

### 3. Affichage pour Validation Humaine

```
Module: my-custom-vpc
Status: NOUVEAU (v1.0.0)

Fichiers a publier:
  - main.tf (245 lignes)
  - variables.tf (89 lignes)
  - outputs.tf (34 lignes)
  - versions.tf (12 lignes)
  - MODULE_METADATA.yaml
  - README.md

Voulez-vous creer la PR ? [O/n]
```

### 4. Creation de la PR

```
4.1 Creer branche
    └── feat/module-{provider}-{category}-{name}-v{version}

4.2 Copier fichiers du module
    └── modules/{provider}/{category}/{name}/v{version}/

4.3 Generer/mettre a jour CHANGELOG.md

4.4 Ouvrir PR avec description auto-generee
```

### 5. Notification

```
PR creee avec succes !

URL: https://github.com/org/cloud_iac_factory/pull/123
Branche: feat/module-aws-networking-my-custom-vpc-v1.0.0

Prochaines etapes:
  1. Reviewer le code
  2. Approuver et merger la PR
  3. Le module sera automatiquement disponible dans catalog.json
```

---

## Detection Version Bump

| Type de Changement | Version Bump |
|--------------------|--------------|
| Nouvelles variables REQUIRED | MAJOR |
| Variables OPTIONAL supprimees | MAJOR |
| Outputs supprimes | MAJOR |
| Nouvelles fonctionnalites | MINOR |
| Bug fixes | PATCH |
| Documentation uniquement | PATCH |

---

## Format PR Auto-Generee

```markdown
## Module: aws/networking/my-custom-vpc

### Version: 1.0.0

### Description
[Copie de la description de MODULE_METADATA.yaml]

### Changements
- Initial release

### Checklist
- [ ] terraform fmt OK
- [ ] terraform validate OK
- [ ] MODULE_METADATA.yaml complet
- [ ] README.md present
- [ ] Exemples fournis

### Tests
- [ ] Deploiement test effectue
- [ ] Validation manuelle OK

---
Genere automatiquement par IaC Factory Plugin
```

---

## Agents Invoques

| Agent | Role |
|-------|------|
| `factory-sync` | Connexion et comparaison avec factory |

---

## Erreurs Courantes

| Erreur | Cause | Solution |
|--------|-------|----------|
| `MODULE_METADATA.yaml manquant` | Fichier absent | Creer le fichier avec le schema requis |
| `Version invalide` | Format non semver | Utiliser format X.Y.Z |
| `Module deja existant` | Meme version deja publiee | Incrementer la version |
| `Validation echouee` | Erreur terraform validate | Corriger le code |

---

## Exemple Complet

```bash
# Structure du module a publier
./modules/my-custom-vpc/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── locals.tf
├── MODULE_METADATA.yaml
├── README.md
└── examples/
    └── complete/
        └── main.tf

# Commande
/publish-module ./modules/my-custom-vpc

# Output
Validation locale...
  ✓ Structure conforme
  ✓ MODULE_METADATA.yaml valide
  ✓ terraform fmt OK
  ✓ terraform validate OK

Comparaison avec factory...
  → Module NOUVEAU

Proposition:
  Module: aws/networking/my-custom-vpc
  Version: 1.0.0

Creation de la PR...
  ✓ Branche creee: feat/module-aws-networking-my-custom-vpc-v1.0.0
  ✓ Fichiers copies
  ✓ PR ouverte: https://github.com/org/cloud_iac_factory/pull/123

La PR attend votre review et approbation.
```
