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

## Sensitive Commands
> Always ask for "go" before executing on staging or prod.
