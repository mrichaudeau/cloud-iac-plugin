# Guide d'Installation et d'Utilisation du Plugin IaC

> Ce guide explique comment installer et utiliser le plugin Cloud IaC Generator pour générer des infrastructures Terraform production-ready.

---

## Prérequis

### Outils requis

| Outil | Version | Installation |
|-------|---------|--------------|
| Claude Code CLI | >= 1.0.0 | `npm install -g @anthropic-ai/claude-code` |
| Terraform | >= 1.5.0 | [terraform.io/downloads](https://terraform.io/downloads) |
| Git | >= 2.0 | [git-scm.com](https://git-scm.com) |
| jq | >= 1.6 | `apt install jq` / `brew install jq` |

### Variables d'environnement

```bash
# Token GitHub pour accéder à la factory (optionnel mais recommandé)
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"

# Région AWS par défaut (optionnel)
export AWS_REGION="eu-west-1"
```

---

## Installation du Plugin

### Option 1 : Via Marketplace GitHub (recommandé pour les utilisateurs)

```bash
# Démarrer Claude Code
claude

# Ajouter le repository comme marketplace
/plugin marketplace add mrichaudeau/cloud-iac-plugin

# Installer le plugin
/plugin install iac@mrichaudeau-cloud-iac-plugin
```

Vous pouvez aussi utiliser le gestionnaire interactif :
```bash
/plugin
# Puis naviguer vers l'onglet "Discover" et sélectionner le plugin
```

### Option 2 : Clone local (recommandé pour le développement)

```bash
# Cloner le repository du plugin
git clone https://github.com/mrichaudeau/cloud-iac-plugin.git ~/plugins/iac-plugin

# Lancer Claude Code avec le plugin local
claude --plugin-dir ~/plugins/iac-plugin
```

Vous pouvez charger plusieurs plugins :
```bash
claude --plugin-dir ~/plugins/iac-plugin --plugin-dir ~/plugins/autre-plugin
```

### Option 3 : Installation locale permanente

```bash
# Démarrer Claude Code
claude

# Ajouter un marketplace local
/plugin marketplace add ~/plugins/iac-plugin
```

---

## Gestion du Plugin

### Commandes de gestion

```bash
/plugin                           # Ouvrir le gestionnaire de plugins (interface interactive)
/plugin marketplace list          # Lister les marketplaces configurés
/plugin marketplace update        # Rafraîchir les listings
/plugin disable iac               # Désactiver le plugin sans le désinstaller
/plugin enable iac                # Réactiver le plugin
/plugin uninstall iac             # Supprimer le plugin
```

### Scopes d'installation

Lors de l'installation via `/plugin`, vous pouvez choisir :
- **User scope** : Installé pour vous sur tous les projets
- **Project scope** : Installé pour tous les collaborateurs du repo (ajouté à `.claude/settings.json`)
- **Local scope** : Installé uniquement pour vous sur ce repo

---

## Utilisation du Plugin

### Démarrer Claude Code

```bash
# Si installé via marketplace, démarrer normalement
cd /chemin/vers/mon-projet
claude

# Si installation locale (développement)
cd /chemin/vers/mon-projet
claude --plugin-dir ~/plugins/iac-plugin
```

### Vérifier que le plugin est chargé

Une fois dans Claude Code, tapez `/help` pour voir les skills disponibles :

```
/iac:generate-infra    - Générer une infrastructure Terraform
/iac:validate-infra    - Valider la sécurité et compliance
/iac:estimate-cost     - Estimer les coûts mensuels
/iac:publish-module    - Publier un module vers la factory
/iac:import-module     - Importer un module depuis la factory
```

---

## Générer une Infrastructure

### Méthode 1 : Description textuelle

```bash
/iac:generate-infra "Application web Django avec PostgreSQL en production sur AWS"
```

### Méthode 2 : Depuis un fichier Markdown

Créez un fichier `architecture.md` :

```markdown
# Architecture MyApp

## Contexte
- Provider: AWS
- Environnement: prod
- Région: eu-west-1

## Composants

### Networking
- VPC: 10.0.0.0/16
- 3 Availability Zones
- Subnets: public, private, database

### Compute
- ECS Fargate cluster
- Service API: 2 tasks min, 10 max
- CPU: 512, Memory: 1024

### Database
- RDS PostgreSQL 15
- Instance: db.r6g.large
- Multi-AZ: oui
- Storage: 100 GB

### Cache
- ElastiCache Redis
- Node type: cache.t3.medium
```

Puis lancez :

```bash
/iac:generate-infra ./architecture.md
```

### Méthode 3 : Depuis un fichier YAML

Créez un fichier `architecture.yaml` :

```yaml
architecture:
  provider: aws
  region: eu-west-1
  environment: prod
  project: myapp
  owner: platform-team
  cost_center: IT-001

  components:
    - type: vpc
      config:
        cidr: "10.0.0.0/16"
        az_count: 3

    - type: ecs_service
      name: api
      config:
        cpu: 512
        memory: 1024
        min_capacity: 2
        max_capacity: 10

    - type: rds
      config:
        engine: postgresql
        version: "15"
        instance_class: db.r6g.large
        multi_az: true
        allocated_storage: 100

    - type: elasticache
      config:
        engine: redis
        node_type: cache.t3.medium
```

Puis lancez :

```bash
/iac:generate-infra ./architecture.yaml
```

---

## Structure Générée

Après génération, vous obtiendrez :

```
./infrastructure/
├── _backend.tf           # Backend S3 + DynamoDB
├── _providers.tf         # Provider AWS
├── _variables.tf         # Variables globales
├── _locals.tf            # Naming, tags
├── _outputs.tf           # Outputs principaux
│
├── 00_governance/        # Gouvernance (toujours généré)
│   ├── iam_foundation.tf
│   ├── budgets.tf
│   ├── cloudtrail.tf
│   ├── guardduty.tf
│   └── kms.tf
│
├── 10_networking/        # Réseau
│   ├── vpc.tf
│   ├── subnets.tf
│   └── nat.tf
│
├── 20_security/          # Sécurité
│   ├── security_groups.tf
│   └── secrets.tf
│
├── 30_compute/           # Compute
│   └── ecs.tf
│
├── 40_data/              # Données
│   ├── rds.tf
│   └── elasticache.tf
│
├── 50_loadbalancing/     # Load balancing
│   └── alb.tf
│
├── 60_monitoring/        # Monitoring
│   ├── cloudwatch.tf
│   └── sns.tf
│
├── environments/         # Variables par environnement
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
│
├── README.md             # Instructions
├── DECISIONS.md          # Justifications des choix
└── COST_ESTIMATE.md      # Estimation des coûts
```

---

## Valider l'Infrastructure

Après génération, validez la sécurité :

```bash
/iac:validate-infra ./infrastructure
```

Le rapport inclut :
- Validation syntaxique (terraform fmt, validate)
- Scan sécurité (credentials, security groups, IAM)
- Compliance (CIS AWS, SOC2)
- Gouvernance (tags, logging, encryption)

---

## Estimer les Coûts

```bash
/iac:estimate-cost ./infrastructure
```

Exemple de sortie :

```
ESTIMATION DES COÛTS MENSUELS
============================

Networking                              $145.00
├── NAT Gateway (x3)                    $100.80
├── VPC Endpoints (x5)                   $36.00
└── Data Transfer                         $8.20

Compute                                 $280.00
├── ECS Fargate                         $180.00
├── ALB                                  $25.00
└── Auto Scaling                         $75.00

Data                                    $120.00
├── RDS PostgreSQL                       $95.00
├── ElastiCache                          $15.00
└── Backup Storage                       $10.00

────────────────────────────────────────────────
TOTAL ESTIMÉ                           $545.00/mois
```

---

## Déployer l'Infrastructure

```bash
cd infrastructure

# Initialiser Terraform
terraform init

# Planifier (environnement prod)
terraform plan -var-file=environments/prod.tfvars -out=tfplan

# Appliquer (après review)
terraform apply tfplan
```

---

## Commandes Utiles

### Lister les modules disponibles dans la factory

```bash
/iac:import-module --list
/iac:import-module --list aws/networking
```

### Importer un module spécifique

```bash
/iac:import-module aws/networking/vpc
/iac:import-module aws/compute/ecs_service v1.2.0
```

### Publier un module vers la factory

```bash
/iac:publish-module ./modules/my-custom-module
```

---

## Exemples de Prompts

### Application web simple

```
/iac:generate-infra "API REST Node.js avec DynamoDB sur AWS, environnement dev"
```

### Microservices

```
/iac:generate-infra "Plateforme e-commerce avec:
- 3 microservices (catalog, orders, payments) sur ECS Fargate
- PostgreSQL RDS pour les commandes
- DynamoDB pour le catalogue
- Redis pour le cache des sessions
- API Gateway + ALB
- Environnement production, région eu-west-1"
```

### Data platform

```
/iac:generate-infra "Data platform avec:
- S3 pour le data lake (raw, processed, curated)
- Glue pour les ETL
- Athena pour les requêtes
- Redshift Serverless pour le DWH
- Environnement staging"
```

### Serverless

```
/iac:generate-infra "Application serverless avec:
- API Gateway REST
- 5 fonctions Lambda (Python)
- DynamoDB
- S3 pour les fichiers
- CloudFront CDN
- Environnement prod"
```

---

## Résolution de Problèmes

### Le plugin n'est pas détecté

```bash
# Vérifier que le dossier contient plugin.json
ls ~/plugins/iac-plugin/.claude-plugin/
# plugin.json

# Vérifier la syntaxe du manifest
cat ~/plugins/iac-plugin/.claude-plugin/plugin.json
```

### Erreur d'accès à la factory

```bash
# Vérifier le token GitHub
echo $GITHUB_TOKEN

# Tester l'accès
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/mrichaudeau/cloud_iac_factory
```

### Terraform validate échoue

```bash
# Formater le code
cd infrastructure
terraform fmt -recursive

# Initialiser avec les providers
terraform init

# Valider
terraform validate
```

---

## Distribution du Plugin

### Structure Marketplace

Le plugin inclut un fichier `.claude-plugin/marketplace.json` qui permet sa découverte :

```json
{
  "name": "mrichaudeau-cloud-iac-plugin",
  "plugins": [
    {
      "name": "iac",
      "description": "Generate production-ready Terraform infrastructure",
      "version": "0.1.0",
      "path": "."
    }
  ]
}
```

### Partager avec votre équipe

1. **Via GitHub** : Les membres ajoutent le marketplace
   ```bash
   /plugin marketplace add mrichaudeau/cloud-iac-plugin
   /plugin install iac@mrichaudeau-cloud-iac-plugin
   ```

2. **Via repo privé** : Même procédure avec un repo privé (nécessite GITHUB_TOKEN)

3. **Via chemin local** : Pour un réseau partagé
   ```bash
   /plugin marketplace add /chemin/reseau/iac-plugin
   ```

---

## Support

- **Issues**: [github.com/mrichaudeau/cloud-iac-plugin/issues](https://github.com/mrichaudeau/cloud-iac-plugin/issues)
- **Documentation**: Voir le dossier `docs/` du plugin
- **Factory**: [github.com/mrichaudeau/cloud_iac_factory](https://github.com/mrichaudeau/cloud_iac_factory)
