# Skill: /generate-infra

> Genere une infrastructure Terraform production-ready a partir d'une description ou schema.

---

## Usage

```
/generate-infra <description ou chemin vers schema>
```

### Exemples

```
/generate-infra "Application web Django avec PostgreSQL en production sur AWS"
/generate-infra ./schema.md
/generate-infra ./architecture.drawio
```

---

## Formats d'Input Supportes

| Format | Extension | Traitement |
|--------|-----------|------------|
| Texte | - | Extraction NLP |
| Markdown | .md | Parsing structure |
| Draw.io | .drawio, .xml | Parsing XML |
| Image | .png, .jpg | Analyse visuelle |
| YAML | .yaml, .yml | Parsing config |

---

## Workflow

### Phase 1 : Parsing

1. **Identifier le type d'input**
2. **Extraire les composants explicites**
   - Services mentionnes (ECS, RDS, S3...)
   - Configurations specifiees
   - Relations et connexions

3. **Detecter le contexte**
   ```yaml
   provider: aws | azure | gcp
   environment: dev | staging | prod
   region: eu-west-1, us-east-1...
   sector: standard | finance | healthcare
   criticality: low | medium | high | critical
   ```

### Phase 2 : Consultation Factory

1. Recuperer `catalog.json` de la factory
2. Identifier les modules disponibles
3. Verifier les versions

### Phase 3 : Enrichissement

Pour chaque composant detecte :
1. Consulter `docs/03-ENRICHMENT.md`
2. Ajouter **hard_dependencies** (obligatoires)
3. Evaluer **soft_dependencies** (selon contexte)
4. Injecter **gouvernance** selon environnement

### Phase 4 : Generation

Creer la structure :
```
./infrastructure/
├── _backend.tf
├── _providers.tf
├── _variables.tf
├── _locals.tf
├── _outputs.tf
├── 00_governance/
├── 10_networking/
├── 20_security/
├── 30_compute/
├── 40_data/
├── 50_loadbalancing/
├── 60_monitoring/
└── environments/
```

### Phase 5 : Validation

1. Verifier guardrails securite
2. Valider anti-hallucination (modules existent dans factory)
3. Generer rapport DECISIONS.md

---

## Templates Utilises

| Template | Usage |
|----------|-------|
| `templates/_backend.tf.tmpl` | Configuration backend S3 |
| `templates/_providers.tf.tmpl` | Provider AWS |
| `templates/_variables.tf.tmpl` | Variables globales |
| `templates/_locals.tf.tmpl` | Locals et tags |
| `templates/module-call.tf.tmpl` | Appel de module |

---

## Agents Invoques

| Agent | Role |
|-------|------|
| `schema-parser` | Si input complexe (draw.io, image) |
| `tf-generator` | Generation du code Terraform |
| `security-reviewer` | Validation securite |

---

## Output

### Fichiers Generes
- Structure `./infrastructure/` complete
- `README.md` avec instructions
- `DECISIONS.md` avec justifications
- `COST_ESTIMATE.md` avec estimation couts

### Rapport Console
```
Generation terminee !

Composants generes:
  - VPC avec 3 AZs
  - ECS Fargate avec auto-scaling
  - RDS PostgreSQL Multi-AZ
  - ALB avec HTTPS
  + 12 composants de gouvernance

Estimation: ~$525/mois

Prochaines etapes:
  1. Revoir ./infrastructure/DECISIONS.md
  2. Configurer les secrets
  3. terraform init && plan
```

---

## Exemples de Prompts

### Simple
```
/generate-infra "API REST avec DynamoDB"
```

### Detaille
```
/generate-infra "Application web Python/Django deployee sur ECS Fargate,
avec une base de donnees PostgreSQL RDS, un cache Redis ElastiCache,
et un bucket S3 pour les assets statiques.
Environnement de production en region eu-west-1.
Le projet s'appelle 'mywebapp' et appartient a l'equipe 'platform'."
```

### Avec Schema
```
/generate-infra ./docs/architecture.md
```

---

## Validation Checklist

Avant de presenter le code genere, verifier :

- [ ] Tous les modules existent dans la factory
- [ ] Pas de credentials en dur
- [ ] Pas de 0.0.0.0/0 sur ports sensibles
- [ ] Encryption activee partout
- [ ] Tags obligatoires presents
- [ ] Gouvernance injectee selon environnement
