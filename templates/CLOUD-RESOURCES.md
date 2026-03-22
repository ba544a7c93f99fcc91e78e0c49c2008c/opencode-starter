# CLOUD-RESOURCES.md
> Cloud resource inventory
> Agent checks this file before any cloud command

## Azure

| Resource | Resource Group | Subscription | Environment | Lab? |
|----------|---------------|--------------|-------------|------|
| | | | dev/staging/prod | yes/no |

## OpenShift

| Project/Namespace | Cluster | Environment | Lab? |
|------------------|---------|-------------|------|
| | | dev/staging/prod | yes/no |

## Access Rules

- **Lab** → Tests allowed, disposable resources
- **Dev** → Modifications with caution
- **Staging** → Human confirmation required
- **Prod** → Mandatory "go" + show exact command

## Read vs Write — Command Classification

Read operations execute freely (no approval needed):
- `az ... list / show / get / describe`
- `kubectl get / describe / logs`
- `terraform plan`
- `SELECT ...` queries

Write operations always require **"go"** — regardless of environment:
- `az ... create / update / delete / set`
- `kubectl apply / delete / scale / rollout`
- `terraform apply / destroy`
- `INSERT / UPDATE / DELETE / DROP`
- Any flag: `--force`, `--delete`, `--purge`, `--override`

When in doubt: if the command changes state anywhere, it's a write. Ask.

## Sensitive Commands
> Always ask for "go" before any write operation, on any environment.
