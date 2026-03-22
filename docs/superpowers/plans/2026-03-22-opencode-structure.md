# Complétion structure .opencode/ + Publication GitHub

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Créer les fichiers `.opencode/commands/`, `.opencode/agents/`, `.opencode/skills/` manquants, corriger le README, et publier sur GitHub.

**Architecture:** Fichiers markdown avec frontmatter YAML selon le format officiel OpenCode. Pas de code — uniquement des fichiers de configuration et d'instruction pour les agents OpenCode.

**Tech Stack:** OpenCode CLI, markdown + YAML frontmatter, git.

---

## Fichiers concernés

**À créer :**
- `.opencode/commands/onboard.md`
- `.opencode/commands/map.md`
- `.opencode/commands/compact.md`
- `.opencode/commands/review.md`
- `.opencode/commands/test.md`
- `.opencode/agents/reviewer.md`
- `.opencode/agents/tester.md`
- `.opencode/agents/explorer.md`
- `.opencode/skills/azure/SKILL.md`
- `.opencode/skills/openshift/SKILL.md`
- `.opencode/skills/terraform/SKILL.md`

**À modifier :**
- `README.md` — correction des noms de dossiers (singulier → pluriel) + structure skill

---

## Task 1 : Créer les commandes `.opencode/commands/`

**Files:**
- Create: `.opencode/commands/onboard.md`
- Create: `.opencode/commands/map.md`
- Create: `.opencode/commands/compact.md`
- Create: `.opencode/commands/review.md`
- Create: `.opencode/commands/test.md`

- [ ] **Step 1 : Créer le dossier et le fichier `onboard.md`**

```bash
mkdir -p .opencode/commands
```

Créer `.opencode/commands/onboard.md` :

```markdown
---
description: Setup initial du profil développeur
agent: build
---
Vérifie si `DEVELOPER-PROFILE.md` existe dans `~/.config/opencode/` ou à la racine du projet.

**Si existant** → charger le profil, confirmer à l'humain et démarrer la session.

**Si absent** → poser les questions suivantes une par une, de manière conversationnelle :

1. Langue préférée pour nos échanges ? (Français / English / Les deux)
2. Ton stack principale ? (ex: C#, Java, Python, TypeScript, Go, DevOps, Fullstack)
3. Ton contexte de travail ? (Backend / Frontend / DevOps / Architecte / Fullstack)
4. Patterns que tu connais bien ? (ex: injection de dépendances, CI/CD, microservices, IaC)
5. Niveau de détail souhaité dans mes réponses ? (Court et direct / Développé avec contexte)
6. Personnalité souhaitée pour l'agent ? (Pragmatique / Pédagogue / Challenger / Créatif / Mixte)
7. As-tu des conventions de nommage ou standards à respecter ? (Si oui, décris les règles principales)
8. Environnements cloud utilisés ? (Azure / OpenShift / AWS / GCP / On-premise / Mixte)

Après les réponses, créer `DEVELOPER-PROFILE.md` avec ce format :

```markdown
# Developer Profile

## Langue d'échange / Exchange Language
- [réponse]

## Stack principale / Main Stack
- Langage : [réponse]
- Contexte : [réponse]

## Patterns familiers / Familiar Patterns
- [liste]

## Niveau de détail / Detail Level
- [réponse]

## Personnalité agent / Agent Personality
- [réponse]

## Conventions & Standards
- [réponse ou "Aucune spécifiée"]

## Environnements cloud / Cloud Environments
- [liste]
```

Sauvegarder dans `~/.config/opencode/DEVELOPER-PROFILE.md` pour réutilisation globale.
Confirmer à l'humain que le profil est créé et que la session peut démarrer.
```

- [ ] **Step 2 : Créer `map.md`**

Créer `.opencode/commands/map.md` :

```markdown
---
description: Cartographier le projet selon le scope de PLAN.md
agent: explorer
---
Lis `PLAN.md` pour identifier le scope de la mission.

Explore la structure du projet en te limitant au scope défini dans PLAN.md :
- Répertoires et fichiers principaux
- Points d'entrée (main, index, entrypoints)
- Modules et dépendances clés
- Fichiers de configuration importants

Génère ou met à jour `PROJECT-MAP.md` avec ce format :

```markdown
# PROJECT-MAP.md
> Généré le [date]. Scope : [scope extrait de PLAN.md]

## Structure principale
[tree des dossiers et fichiers clés]

## Points d'entrée
[liste des entrypoints]

## Modules clés
[liste avec rôle de chaque module]

## Dépendances externes
[liste des dépendances importantes]

## Notes
[observations pertinentes pour la mission]
```

Si un argument est fourni (`$ARGUMENTS`), limiter le scan à ce sous-répertoire.
```

- [ ] **Step 3 : Créer `compact.md`**

Créer `.opencode/commands/compact.md` :

```markdown
---
description: Résumer et archiver la mémoire de session
agent: build
---
Lis tous les fichiers dans `memory/` (sauf `archive/`).

Compte le nombre total de lignes. Si supérieur à 500, proposer la compaction.

**Processus de compaction :**

1. Résume le contenu de `MEMORY.md` en conservant uniquement :
   - Les décisions architecturales importantes
   - Les patterns validés
   - Les erreurs rencontrées et résolues
   - Les instructions permanentes de l'humain

2. Crée une archive datée dans `memory/archive/` :
   - Nom : `YYYY-MM-DD_summary.md`
   - Contenu : résumé complet de la session avec contexte

3. Met à jour `MEMORY.md` avec le résumé condensé (cible : < 120 lignes)

4. Indique à l'humain :
   - Archive créée : `memory/archive/[nom]`
   - Lignes avant → après
   - MEMORY.md mis à jour

Ne pas toucher aux fichiers dans `memory/archive/`.
```

- [ ] **Step 4 : Créer `review.md`**

Créer `.opencode/commands/review.md` :

```markdown
---
description: Déclencher la revue de code sur les fichiers modifiés
agent: reviewer
---
Identifie les fichiers modifiés depuis le dernier commit :

```bash
git diff --name-only HEAD
```

Si aucun fichier modifié, chercher les fichiers stagés :

```bash
git diff --name-only --cached
```

Pour chaque fichier modifié (hors fichiers markdown de config) :
- Lis le fichier complet
- Analyse le diff (`git diff HEAD -- [fichier]`)
- Produis une revue structurée

Format de revue pour chaque fichier :

```
## [nom du fichier]

### Problèmes critiques
- [liste ou "Aucun"]

### Problèmes mineurs
- [liste ou "Aucun"]

### Suggestions
- [liste ou "Aucune"]

### Verdict
✅ Approuvé | ⚠️ Approuvé avec réserves | ❌ À corriger
```

Résume à la fin le verdict global et les actions prioritaires pour l'humain.
```

- [ ] **Step 5 : Créer `test.md`**

Créer `.opencode/commands/test.md` :

```markdown
---
description: Déclencher les tests et produire un rapport
agent: tester
---
Identifie le framework de test utilisé dans le projet :
- `package.json` → Jest, Vitest, Mocha
- `pyproject.toml` / `setup.py` → pytest
- `*.csproj` → xUnit, NUnit, MSTest
- `go.mod` → go test
- `Cargo.toml` → cargo test

Si `$ARGUMENTS` est fourni, limiter les tests à ce scope.

**Processus :**

1. Lance les tests avec la commande appropriée
2. Capture la sortie complète
3. Produis un rapport :

```
## Rapport de tests — [date]

### Résumé
- Total : [N]
- Passés : [N] ✅
- Échoués : [N] ❌
- Ignorés : [N] ⚠️

### Tests échoués
Pour chaque test échoué :
- Nom du test
- Erreur exacte
- Cause probable (sans modifier le test)

### Verdict
[Passer / Des corrections sont nécessaires]
```

**Règle absolue :** Ne jamais modifier un test pour le faire passer. Si un test échoue, reporter la cause à l'humain.
```

- [ ] **Step 6 : Vérifier les 5 fichiers**

```bash
ls -la .opencode/commands/
```

Résultat attendu : 5 fichiers `.md` (onboard, map, compact, review, test).

```bash
head -5 .opencode/commands/onboard.md
head -5 .opencode/commands/map.md
head -5 .opencode/commands/compact.md
head -5 .opencode/commands/review.md
head -5 .opencode/commands/test.md
```

Chaque fichier doit commencer par `---` (frontmatter YAML).

- [ ] **Step 7 : Commit**

```bash
git add .opencode/commands/
git commit -m "feat: add .opencode/commands/ — onboard, map, compact, review, test"
```

---

## Task 2 : Créer les agents `.opencode/agents/`

**Files:**
- Create: `.opencode/agents/reviewer.md`
- Create: `.opencode/agents/tester.md`
- Create: `.opencode/agents/explorer.md`

- [ ] **Step 1 : Créer le dossier et `reviewer.md`**

```bash
mkdir -p .opencode/agents
```

Créer `.opencode/agents/reviewer.md` :

```markdown
---
description: Revieweur de code — read-only, jamais de modifications directes
mode: subagent
model: anthropic/claude-sonnet-4-6
permission:
  edit: deny
  bash:
    "git diff*": allow
    "git log*": allow
    "grep *": allow
---
Tu es un revieweur de code senior. Ton rôle est exclusivement la revue — tu ne modifies jamais de fichiers.

## Règles absolues
- Tu ne modifies aucun fichier. Jamais.
- Tu ne proposes pas de corrections directes. Tu signales les problèmes.
- Si tu détectes un problème de sécurité critique, tu l'indiques en premier.

## Ce que tu vérifies
- Correctness : le code fait-il ce qu'il prétend faire ?
- Sécurité : injection, XSS, credentials en dur, permissions excessives
- Maintenabilité : lisibilité, nommage, responsabilités claires
- Cohérence : respect des patterns existants dans le projet
- Tests : les cas limites sont-ils couverts ?

## Format de sortie
Pour chaque fichier reviewé :

### [nom du fichier] — [verdict : ✅ / ⚠️ / ❌]

**Problèmes critiques** (bloquants)
- [ligne N] : [description précise]

**Problèmes mineurs** (non bloquants)
- [ligne N] : [description]

**Suggestions** (optionnelles)
- [observation]

## Ton style
- Direct et factuel
- Jamais condescendant
- Toujours citer la ligne concernée
- Expliquer pourquoi c'est un problème, pas seulement quoi
```

- [ ] **Step 2 : Créer `tester.md`**

Créer `.opencode/agents/tester.md` :

```markdown
---
description: Testeur — écrit et roule les tests, jamais de code fonctionnel
mode: subagent
model: anthropic/claude-haiku-4-5-20251001
permission:
  bash:
    "npm test*": allow
    "pytest*": allow
    "go test*": allow
    "dotnet test*": allow
    "cargo test*": allow
---
Tu es un spécialiste des tests. Ton rôle est d'écrire des tests et de les exécuter. Tu ne touches jamais au code fonctionnel.

## Règles absolues
- Tu n'écris que des fichiers de tests. Jamais de code d'implémentation.
- Tu ne modifies jamais un test pour le faire passer. Si un test échoue, tu rapportes la cause à l'humain.
- Un test qui passe après modification du test n'est pas un test — c'est une tautologie.

## Ce que tu fais
1. Analyser le code à tester (lecture seule)
2. Identifier les cas à couvrir : happy path, cas limites, erreurs
3. Écrire les tests dans le framework détecté
4. Lancer les tests
5. Reporter les résultats avec causes précises en cas d'échec

## Conventions de test
- Un test = un comportement
- Nommage : `test_[quoi]_[condition]_[résultat_attendu]`
- Arrange / Act / Assert
- Pas de logique dans les tests (pas de if, pas de boucles)
- Données de test explicites, jamais de random

## En cas d'échec
Rapport à l'humain :
- Nom exact du test échoué
- Erreur exacte (stack trace si disponible)
- Cause probable dans le code d'implémentation
- Action suggérée pour @build (jamais pour toi)
```

- [ ] **Step 3 : Créer `explorer.md`**

Créer `.opencode/agents/explorer.md` :

```markdown
---
description: Explorateur — discovery et cartographie, read-only
mode: subagent
model: anthropic/claude-sonnet-4-6
permission:
  edit: deny
  bash:
    "find *": allow
    "ls *": allow
    "cat *": allow
    "grep *": allow
    "git log*": allow
    "git diff*": allow
---
Tu es un explorateur de codebase. Ton rôle est de découvrir, analyser et cartographier. Tu ne modifies jamais rien.

## Règles absolues
- Tu ne modifies aucun fichier. Jamais. Pas même pour "corriger une typo".
- Tu ne proposes pas d'implémentation. Tu décris ce qui existe.
- Si tu trouves quelque chose de problématique, tu le notes sans le corriger.

## Ce que tu fais
- Explorer la structure d'un projet ou d'un répertoire
- Identifier les patterns architecturaux utilisés
- Trouver les points d'entrée et les dépendances
- Cartographier les relations entre modules
- Générer PROJECT-MAP.md sur demande

## Méthode d'exploration
1. Structure top-level d'abord
2. Fichiers de configuration (package.json, pyproject.toml, *.csproj, go.mod...)
3. Points d'entrée principaux
4. Modules et leurs responsabilités
5. Dépendances externes

## Format de sortie
Clair, structuré, avec des exemples concrets de ce que tu trouves.
Toujours indiquer : où tu as cherché, ce que tu as trouvé, ce que ça implique pour la mission.
```

- [ ] **Step 4 : Vérifier les 3 fichiers**

```bash
ls -la .opencode/agents/
```

Résultat attendu : 3 fichiers `.md` (reviewer, tester, explorer).

```bash
head -8 .opencode/agents/reviewer.md
head -8 .opencode/agents/tester.md
head -8 .opencode/agents/explorer.md
```

Chaque fichier doit avoir `mode: subagent` et `model:` dans le frontmatter.

- [ ] **Step 5 : Commit**

```bash
git add .opencode/agents/
git commit -m "feat: add .opencode/agents/ — reviewer, tester, explorer"
```

---

## Task 3 : Créer les skills `.opencode/skills/`

**Files:**
- Create: `.opencode/skills/azure/SKILL.md`
- Create: `.opencode/skills/openshift/SKILL.md`
- Create: `.opencode/skills/terraform/SKILL.md`

- [ ] **Step 1 : Créer `azure/SKILL.md`**

```bash
mkdir -p .opencode/skills/azure
```

Créer `.opencode/skills/azure/SKILL.md` :

```markdown
---
name: azure
description: Azure cloud patterns: ARM/Bicep, RBAC, naming conventions, resource groups
---

## Naming Conventions Azure

Suivre le Cloud Adoption Framework (CAF) Microsoft :

```
[type-ressource]-[projet]-[env]-[région]-[numéro]
ex: rg-monprojet-prod-eastus-001
    kv-monprojet-dev-westeu-001
    vnet-monprojet-prod-eastus-001
```

Abréviations courantes :
- `rg` → Resource Group
- `kv` → Key Vault
- `st` → Storage Account
- `vnet` → Virtual Network
- `snet` → Subnet
- `nsg` → Network Security Group
- `pip` → Public IP
- `aks` → AKS Cluster

## Bicep — Patterns recommandés

**Paramétrage :**
```bicep
@description('Environnement de déploiement')
@allowed(['dev', 'staging', 'prod'])
param environment string

@description('Région Azure')
param location string = resourceGroup().location
```

**Output systématique pour les ressources clés :**
```bicep
output storageAccountId string = storageAccount.id
output keyVaultUri string = keyVault.properties.vaultUri
```

**Utiliser des modules pour les ressources réutilisables.**

## RBAC — Principe du moindre privilège

- Ne jamais attribuer `Owner` ou `Contributor` à des identités applicatives
- Privilégier les rôles intégrés : `Reader`, `Contributor`, `[Service] Contributor`
- Managed Identity > Service Principal > Client Secret
- Auditer les assignments avec : `az role assignment list --scope /subscriptions/[id]`

## Resource Groups

- Un RG par environnement et par workload
- Tags obligatoires : `Environment`, `Project`, `Owner`, `CostCenter`
- Locks sur les RGs de production : `az lock create --lock-type CanNotDelete`

## Checklist déploiement

- [ ] Naming convention respectée
- [ ] Tags appliqués sur toutes les ressources
- [ ] RBAC avec moindre privilège
- [ ] Secrets dans Key Vault (jamais en dur)
- [ ] Diagnostic settings activés
- [ ] Lock sur le resource group de prod
```

- [ ] **Step 2 : Créer `openshift/SKILL.md`**

```bash
mkdir -p .opencode/skills/openshift
```

Créer `.opencode/skills/openshift/SKILL.md` :

```markdown
---
name: openshift
description: OpenShift/Kubernetes patterns: Helm, routes, deployments, namespaces
---

## Namespaces — Convention de nommage

```
[equipe]-[projet]-[env]
ex: platform-monprojet-dev
    platform-monprojet-prod
```

## Deployment — Patterns recommandés

**Toujours définir les resource limits :**
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

**Liveness et Readiness probes obligatoires :**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

**Toujours spécifier le `securityContext` :**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
```

## Routes OpenShift

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: mon-service
spec:
  to:
    kind: Service
    name: mon-service
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

Toujours forcer TLS (`insecureEdgeTerminationPolicy: Redirect`).

## Helm — Bonnes pratiques

- Un chart par microservice
- `values.yaml` contient les valeurs par défaut (dev)
- `values-prod.yaml` override uniquement ce qui diffère
- Utiliser `helm diff` avant tout `helm upgrade`
- Versionner les charts avec semver

## ConfigMaps et Secrets

- ConfigMaps pour la config non-sensible
- Secrets pour tout ce qui est sensible (utiliser External Secrets Operator si disponible)
- Ne jamais committer de Secrets en clair dans git

## Checklist déploiement

- [ ] Resource limits définies
- [ ] Probes configurées
- [ ] securityContext non-root
- [ ] Route TLS activée
- [ ] Secrets externalisés
- [ ] Namespace correctement nommé
```

- [ ] **Step 3 : Créer `terraform/SKILL.md`**

```bash
mkdir -p .opencode/skills/terraform
```

Créer `.opencode/skills/terraform/SKILL.md` :

```markdown
---
name: terraform
description: Terraform patterns: state management, modules, workspaces, remote backends
---

## Structure de projet recommandée

```
terraform/
├── main.tf          ← ressources principales
├── variables.tf     ← déclarations de variables
├── outputs.tf       ← outputs exposés
├── versions.tf      ← required_providers + terraform block
├── backend.tf       ← configuration du backend distant
└── modules/
    └── [nom]/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Backend distant — Toujours

Ne jamais utiliser le state local en équipe. Exemple Azure :

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate001"
    container_name       = "tfstate"
    key                  = "monprojet/prod/terraform.tfstate"
  }
}
```

## Versions — Toujours épingler

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}
```

## Modules — Règles

- Un module = une responsabilité claire
- Toujours documenter les variables avec `description`
- Toujours typer les variables (`string`, `number`, `bool`, `list`, `map`, `object`)
- Outputs obligatoires pour les IDs et URLs des ressources créées

```hcl
variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'environnement doit être dev, staging ou prod."
  }
}
```

## Workspaces vs répertoires séparés

**Recommandation :** répertoires séparés par environnement pour les projets complexes.
Workspaces pour les projets simples avec peu de différences entre envs.

## Workflow standard

```bash
terraform fmt          # formater avant tout
terraform validate     # valider la syntaxe
terraform plan -out=tfplan   # toujours sauvegarder le plan
terraform show tfplan        # reviewer le plan
terraform apply tfplan       # appliquer le plan sauvegardé
```

**Jamais `terraform apply` sans `plan` préalable.**

## Checklist

- [ ] Backend distant configuré
- [ ] Versions providers épinglées
- [ ] Variables typées et documentées
- [ ] `terraform fmt` passé
- [ ] `terraform validate` passé
- [ ] Plan reviewé avant apply
- [ ] State protégé (versioning + locking activés)
```

- [ ] **Step 4 : Vérifier les 3 skills**

```bash
ls -la .opencode/skills/
ls .opencode/skills/azure/ .opencode/skills/openshift/ .opencode/skills/terraform/
```

Résultat attendu : 3 dossiers, chacun contenant `SKILL.md`.

```bash
head -5 .opencode/skills/azure/SKILL.md
head -5 .opencode/skills/openshift/SKILL.md
head -5 .opencode/skills/terraform/SKILL.md
```

Chaque fichier doit avoir `name:` et `description:` dans le frontmatter.

- [ ] **Step 5 : Commit**

```bash
git add .opencode/skills/
git commit -m "feat: add .opencode/skills/ — azure, openshift, terraform"
```

---

## Task 4 : Corriger le README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1 : Corriger les noms de dossiers dans le bloc structure**

Dans `README.md`, localiser le bloc de structure (autour de la ligne 50-88) et remplacer :

```
├── .opencode/
│   ├── command/           ← Slash commands
│   │   ├── onboard.md     ← /onboard
│   │   ├── map.md         ← /map
│   │   ├── compact.md     ← /compact
│   │   ├── review.md      ← /review
│   │   └── test.md        ← /test
│   │
│   ├── agent/             ← Specialized sub-agents
│   │   ├── reviewer.md    ← Read-only code reviewer
│   │   ├── tester.md      ← Test writer (Haiku model)
│   │   └── explorer.md    ← Read-only discovery & mapping
│   │
│   └── skill/             ← Domain expertise, loaded on demand
│       ├── azure/
│       ├── openshift/
│       └── terraform/
```

par :

```
├── .opencode/
│   ├── commands/          ← Slash commands
│   │   ├── onboard.md     ← /onboard
│   │   ├── map.md         ← /map
│   │   ├── compact.md     ← /compact
│   │   ├── review.md      ← /review
│   │   └── test.md        ← /test
│   │
│   ├── agents/            ← Specialized sub-agents
│   │   ├── reviewer.md    ← Read-only code reviewer
│   │   ├── tester.md      ← Test writer (Haiku model)
│   │   └── explorer.md    ← Read-only discovery & mapping
│   │
│   └── skills/            ← Domain expertise, loaded on demand
│       ├── azure/
│       │   └── SKILL.md
│       ├── openshift/
│       │   └── SKILL.md
│       └── terraform/
│           └── SKILL.md
```

- [ ] **Step 2 : Vérifier le README**

```bash
grep -n "command/\|agent/\|skill/" README.md
```

Résultat attendu : aucune occurrence (tous remplacés par les formes plurielles).

```bash
grep -n "commands/\|agents/\|skills/" README.md
```

Résultat attendu : au moins 3 occurrences (une par dossier).

- [ ] **Step 3 : Commit**

```bash
git add README.md
git commit -m "fix: correct .opencode/ directory names to match official OpenCode spec (plural)"
```

---

## Task 5 : Publication GitHub

**Files:** aucun fichier modifié — git push uniquement.

- [ ] **Step 1 : Vérifier l'état git**

```bash
git status
git log --oneline -5
```

Résultat attendu : working tree propre, au moins 4 commits depuis `Initial commit`.

- [ ] **Step 2 : Vérifier le remote**

```bash
git remote -v
```

Résultat attendu : `origin https://github.com/ba544a7c93f99fcc91e78e0c49c2008c/opencode-starter.git`

- [ ] **Step 3 : Push**

```bash
git push origin main
```

Résultat attendu : succès sans erreur, `main -> main` affiché.

- [ ] **Step 4 : Vérifier sur GitHub**

```bash
gh repo view --web
```

Ou vérifier manuellement que les fichiers apparaissent sur le dépôt GitHub.
