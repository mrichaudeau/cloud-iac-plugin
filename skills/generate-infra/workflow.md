# Generate Infrastructure Workflow

## Phase 1: Parsing

1. **Identify input type**
2. **Extract explicit components**
   - Services mentioned (ECS, RDS, S3...)
   - Specified configurations
   - Relations and connections

3. **Detect context**
   ```yaml
   provider: aws | azure | gcp
   environment: dev | staging | prod
   region: eu-west-1, us-east-1...
   sector: standard | finance | healthcare
   criticality: low | medium | high | critical
   ```

## Phase 2: Factory Consultation

1. Retrieve `catalog.json` from factory
2. Identify available modules
3. Verify versions

## Phase 3: Enrichment

For each detected component:
1. Consult `docs/03-ENRICHMENT.md`
2. Add **hard_dependencies** (mandatory)
3. Evaluate **soft_dependencies** (context-based)
4. Inject **governance** per environment

## Phase 4: Generation

Create structure:
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

## Phase 5: Validation

1. Check security guardrails
2. Validate anti-hallucination (modules exist in factory)
3. Generate DECISIONS.md report

## Templates Used

| Template | Usage |
|----------|-------|
| `templates/_backend.tf.tmpl` | S3 backend configuration |
| `templates/_providers.tf.tmpl` | AWS provider |
| `templates/_variables.tf.tmpl` | Global variables |
| `templates/_locals.tf.tmpl` | Locals and tags |
| `templates/module-call.tf.tmpl` | Module calls |

## Validation Checklist

Before presenting generated code, verify:

- [ ] All modules exist in factory
- [ ] No hardcoded credentials
- [ ] No 0.0.0.0/0 on sensitive ports
- [ ] Encryption enabled everywhere
- [ ] Mandatory tags present
- [ ] Governance injected per environment
