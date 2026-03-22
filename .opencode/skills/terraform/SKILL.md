---
name: terraform
description: Terraform patterns: state management, modules, workspaces, remote backends
---

## Recommended Project Structure

```
terraform/
├── main.tf          ← main resources
├── variables.tf     ← variable declarations
├── outputs.tf       ← exposed outputs
├── versions.tf      ← required_providers + terraform block
├── backend.tf       ← remote backend configuration
└── modules/
    └── [name]/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Remote Backend — Always

Never use local state in a team. Azure example:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate001"
    container_name       = "tfstate"
    key                  = "myproject/prod/terraform.tfstate"
  }
}
```

## Versions — Always Pin

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

## Modules — Rules

- One module = one clear responsibility
- Always document variables with `description`
- Always type variables (`string`, `number`, `bool`, `list`, `map`, `object`)
- Mandatory outputs for IDs and URLs of created resources

```hcl
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

## Workspaces vs Separate Directories

**Recommendation:** separate directories per environment for complex projects.
Workspaces for simple projects with few differences between environments.

## Standard Workflow

```bash
terraform fmt          # format first
terraform validate     # validate syntax
terraform plan -out=tfplan   # always save the plan
terraform show tfplan        # review the plan
terraform apply tfplan       # apply the saved plan
```

**Never `terraform apply` without a prior `plan`.**

## Checklist

- [ ] Remote backend configured
- [ ] Provider versions pinned
- [ ] Variables typed and documented
- [ ] `terraform fmt` passed
- [ ] `terraform validate` passed
- [ ] Plan reviewed before apply
- [ ] State protected (versioning + locking enabled)
