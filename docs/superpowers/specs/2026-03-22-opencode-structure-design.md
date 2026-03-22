# Design Spec — Complétion structure .opencode/ + Publication GitHub

**Date :** 2026-03-22
**Statut :** Approuvé

---

## Contexte

Le projet `opencode-starter` a été créé via Claude web. La structure `.opencode/` décrite dans le README est absente. Ce spec couvre la création de ces fichiers selon le format officiel OpenCode, la correction du README, et la publication sur GitHub.

---

## Fichiers à créer

### `.opencode/commands/` — 5 commandes

Format : markdown avec frontmatter YAML. Le nom de fichier (sans extension) devient l'ID de la commande.

Le champ `model` est optionnel dans les commandes — il n'est pas spécifié ici, l'agent héritera du modèle par défaut de la session.

| Fichier | Frontmatter `agent` | Frontmatter `description` | Corps |
|---|---|---|---|
| `onboard.md` | `build` | Setup initial du profil développeur | Instructions issues de ONBOARD.md |
| `map.md` | `explorer` | Cartographier le projet selon PLAN.md | Instructions pour générer PROJECT-MAP.md |
| `compact.md` | `build` | Résumer et archiver memory/ | Instructions de compaction et archivage |
| `review.md` | `reviewer` | Déclencher la revue de code | Instructions pour @reviewer sur fichiers modifiés |
| `test.md` | `tester` | Déclencher les tests et rapport | Instructions pour @tester + exécution + rapport |

### `.opencode/agents/` — 3 agents

Format : markdown avec frontmatter YAML (`description`, `mode`, `model`, `permission`).

**`reviewer.md`**
- mode: `subagent`
- model: `anthropic/claude-sonnet-4-6`
- Rôle: revue de code read-only, jamais de modifications
- Permission YAML :
```yaml
permission:
  edit: deny
  bash:
    "git diff*": allow
    "git log*": allow
    "grep *": allow
```

**`tester.md`**
- mode: `subagent`
- model: `anthropic/claude-haiku-4-5-20251001`
- Rôle: écriture et exécution de tests uniquement, jamais de code fonctionnel
- Permission YAML :
```yaml
permission:
  bash:
    "npm test*": allow
    "pytest*": allow
    "go test*": allow
    "dotnet test*": allow
```

**`explorer.md`**
- mode: `subagent`
- model: `anthropic/claude-sonnet-4-6`
- Rôle: discovery et cartographie, jamais de modifications
- Permission YAML :
```yaml
permission:
  edit: deny
  bash:
    "find *": allow
    "ls *": allow
    "cat *": allow
    "grep *": allow
```

### `.opencode/skills/` — 3 skills

Format : dossier par skill contenant un `SKILL.md` avec frontmatter `name` + `description` (obligatoires).

| Dossier | `name` | `description` | Contenu |
|---|---|---|---|
| `azure/SKILL.md` | `azure` | Azure cloud patterns: ARM/Bicep, RBAC, naming conventions, resource groups | Patterns ARM/Bicep, RBAC, naming conventions |
| `openshift/SKILL.md` | `openshift` | OpenShift/Kubernetes patterns: Helm, routes, deployments, namespaces | Patterns OpenShift, Kubernetes, Helm, routes |
| `terraform/SKILL.md` | `terraform` | Terraform patterns: state management, modules, workspaces, remote backends | Patterns Terraform, state management, modules, workspaces |

---

## Modifications README.md

Corriger les noms de dossiers pour matcher la spec officielle OpenCode :

- `command/` → `commands/`
- `agent/` → `agents/`
- `skill/` → `skills/`
- Structure skill dans le tree : chaque skill affiché avec son `SKILL.md` enfant, ex. `skills/azure/SKILL.md`

---

## Publication GitHub

- Remote déjà configuré : `https://github.com/ba544a7c93f99fcc91e78e0c49c2008c/opencode-starter.git`
- Dépôt déjà existant sur GitHub
- Action : `git add` des nouveaux fichiers + `git commit` + `git push origin main`

---

## Critères de succès

- [ ] 5 fichiers dans `.opencode/commands/` avec frontmatter valide
- [ ] 3 fichiers dans `.opencode/agents/` avec frontmatter valide
- [ ] 3 dossiers dans `.opencode/skills/` avec `SKILL.md` valide
- [ ] README.md mis à jour avec les noms pluriels corrects
- [ ] `git push` réussi vers GitHub
