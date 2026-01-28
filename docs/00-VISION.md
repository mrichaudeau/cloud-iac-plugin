# Vision du Projet IaC Factory

> **Version** : 1.0.0
> **Date** : Janvier 2025

---

## Problematique

### Constat Actuel

Quand on demande a une IA de generer du Terraform, elle produit typiquement :
- Uniquement les ressources explicitement demandees
- Pas de structure de state securisee
- IAM avec permissions trop larges ou manquantes
- Aucune gouvernance (budgets, logs, compliance)
- Security Groups "0.0.0.0/0" par defaut
- Pas de tagging coherent
- Code monolithique non modulaire
- Pas de gestion des secrets

### Vision Cible

Un ecosysteme ou :
- L'IA dispose d'une "conscience contextuelle" des dependances
- Les composants de gouvernance sont **automatiquement injectes**
- Le code respecte les bonnes pratiques CIS/Well-Architected
- La sortie est **immediatement deployable** sans modification
- La tracabilite des decisions IA est documentee
- Les modules valides sont **capitalises** dans une factory

---

## Objectifs du Projet

### Objectif 1 : Generation Production-Ready

Generer du code Terraform **deployable immediatement** (`terraform apply`) avec :
- Structure standardisee
- Best practices integrees
- Securite by design
- Gouvernance automatique

### Objectif 2 : Enrichissement Intelligent

A partir d'un schema minimal, enrichir automatiquement avec :
- Dependances techniques (VPC, subnets, security groups...)
- Gouvernance obligatoire (budgets, logs, IAM, KMS...)
- Optimisations selon contexte (multi-AZ en prod, WAF si internet...)

### Objectif 3 : Capitalisation via Factory

Creer un repo GitHub `cloud_iac_factory` qui :
- Centralise les modules Terraform valides
- S'alimente automatiquement des projets deployes
- Permet la reutilisation entre projets
- Gere le versioning semantique

### Objectif 4 : Distribution Entreprise

Encapsuler cette logique dans un **plugin Claude Code** distribuable :
- Skills pour les commandes utilisateur
- Agents specialises pour les taches complexes
- Configuration centralisee

---

## Scope Multi-Cloud

### Phase 1 : AWS (Prioritaire)
- Modules : VPC, ECS, RDS, S3, Lambda, ALB, KMS, IAM...
- Gouvernance : CloudTrail, GuardDuty, Security Hub, Budgets...

### Phase 2 : Azure
- Modules : VNET, AKS, Azure SQL, Storage, Functions, App Gateway...
- Gouvernance : Azure Monitor, Defender, Cost Management...

### Phase 3 : GCP
- Modules : VPC, GKE, Cloud SQL, GCS, Cloud Functions, Cloud Armor...
- Gouvernance : Cloud Audit Logs, Security Command Center...

---

## Workflow Utilisateur

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         WORKFLOW UTILISATEUR                                 │
└─────────────────────────────────────────────────────────────────────────────┘

 ETAPE 1: Generation
 ─────────────────────────────────────────────────────────────────────────────
 Utilisateur: /generate-infra "App web Django avec PostgreSQL en prod sur AWS"

 Claude Code:
   1. Parse la demande
   2. Consulte la factory (modules disponibles)
   3. Enrichit avec gouvernance + dependances
   4. Genere ./infrastructure/ complet
   5. Produit rapport avec decisions expliquees


 ETAPE 2: Developpement & Test
 ─────────────────────────────────────────────────────────────────────────────
 Utilisateur:
   - Personnalise le code si necessaire
   - terraform plan / apply en staging
   - Valide fonctionnellement


 ETAPE 3: Publication (si module reutilisable)
 ─────────────────────────────────────────────────────────────────────────────
 Utilisateur: /publish-module modules/my-custom-module

 Claude Code:
   1. Valide la structure
   2. Compare avec factory existante
   3. Cree PR vers cloud_iac_factory
   4. Attend validation humaine


 ETAPE 4: Reutilisation Future
 ─────────────────────────────────────────────────────────────────────────────
 Autre utilisateur: /generate-infra "App similaire"

 Claude Code:
   → Utilise automatiquement le module publie dans la factory
```

---

## Criteres de Succes

| Critere | Mesure |
|---------|--------|
| Code deployable | `terraform apply` sans erreur |
| Securite | 0 alerte critique Checkov/tfsec |
| Gouvernance | 100% des composants obligatoires presents |
| Documentation | README + DECISIONS.md generes |
| Reutilisation | Modules publies dans factory |
| Adoption | Utilisation par les equipes |

---

## Contraintes Non Negociables

1. **Terraform 1.5+** : Support moved blocks, import blocks, check blocks
2. **Providers officiels** uniquement
3. **State securise** : S3 + DynamoDB + KMS
4. **Secrets** : JAMAIS en dur, toujours Secrets Manager
5. **Idempotence** : Chaque apply doit etre repetable
6. **Tagging** : 100% des ressources taggees
7. **Least Privilege** : Permissions minimales documentees
8. **Documentation** : Chaque module auto-documente

---

## Liens

- [Architecture Technique](01-ARCHITECTURE.md)
- [Workflow de Generation](02-WORKFLOW.md)
- [Factory GitHub](04-FACTORY.md)
