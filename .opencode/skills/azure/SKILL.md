---
name: azure
description: Azure cloud patterns: ARM/Bicep, RBAC, naming conventions, resource groups
---

## Azure Naming Conventions

Follow the Microsoft Cloud Adoption Framework (CAF):

```
[resource-type]-[project]-[env]-[region]-[number]
e.g. rg-myproject-prod-eastus-001
     kv-myproject-dev-westeu-001
     vnet-myproject-prod-eastus-001
```

Common abbreviations:
- `rg` → Resource Group
- `kv` → Key Vault
- `st` → Storage Account
- `vnet` → Virtual Network
- `snet` → Subnet
- `nsg` → Network Security Group
- `pip` → Public IP
- `aks` → AKS Cluster

## Bicep — Recommended Patterns

**Parameters:**
```bicep
@description('Deployment environment')
@allowed(['dev', 'staging', 'prod'])
param environment string

@description('Azure region')
param location string = resourceGroup().location
```

**Systematic outputs for key resources:**
```bicep
output storageAccountId string = storageAccount.id
output keyVaultUri string = keyVault.properties.vaultUri
```

**Use modules for reusable resources.**

## RBAC — Principle of Least Privilege

- Never assign `Owner` or `Contributor` to application identities
- Prefer built-in roles: `Reader`, `Contributor`, `[Service] Contributor`
- Managed Identity > Service Principal > Client Secret
- Audit assignments with: `az role assignment list --scope /subscriptions/[id]`

## Resource Groups

- One RG per environment and workload
- Mandatory tags: `Environment`, `Project`, `Owner`, `CostCenter`
- Locks on production RGs: `az lock create --lock-type CanNotDelete`

## Deployment Checklist

- [ ] Naming convention followed
- [ ] Tags applied to all resources
- [ ] RBAC with least privilege
- [ ] Secrets in Key Vault (never hardcoded)
- [ ] Diagnostic settings enabled
- [ ] Lock on production resource group
