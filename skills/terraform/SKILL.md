---
name: terraform
description: >
  Organizational standards and best practices for Terraform infrastructure-as-code development.
  Use this skill whenever writing, reviewing, scaffolding, or refactoring any Terraform code —
  including .tf files, modules, variables, outputs, state management, provider configuration,
  resource tagging, backend configuration, or terratest. Also use when creating new Terraform
  projects, reviewing for standards compliance, or generating boilerplate/templates.
  Default provider context is Azure (azurerm) unless otherwise specified.
---

# Terraform Development Standards

This document outlines the standards and best practices for Terraform infrastructure-as-code development.

## Project Structure

```
ProjectName/
├── environments/    # Environment-specific configurations
│   ├── dev/         # Development environment
│   ├── staging/     # Staging environment
│   └── prod/        # Production environment
├── modules/         # Reusable Terraform modules
├── policies/        # Sentinel/OPA policies
├── scripts/         # Helper scripts and automation
├── tests/           # Terraform tests (terratest)
├── docs/            # Documentation
├── .terraform/      # Terraform working directory (git ignored)
└── README.md        # Project documentation
```

## Code Standards

### 1. File Organization and Naming
- Use descriptive file names: `main.tf`, `variables.tf`, `outputs.tf`
- Group related resources in logical files: `networking.tf`, `security.tf`
- Use consistent naming across environments
- Include `versions.tf` for provider version constraints
- Use `terraform.tf` for Terraform version requirements

### 2. Resource Naming Conventions
- Use consistent naming pattern: `{project}-{environment}-{resource-type}-{purpose}`
- Use lowercase with hyphens for resource names
- Use descriptive names that indicate purpose
- Avoid abbreviations unless widely understood
- Use prefixes for resource grouping

### 3. Variable Management
- **ALWAYS** define variables with descriptions, types, and defaults
- Use snake_case for variable names: `vpc_cidr_block`
- Group related variables together
- Use validation blocks for input validation
- Separate sensitive variables appropriately

### 4. Documentation Standards
- Include detailed comments for complex resources
- Document all variables with clear descriptions
- Include examples in variable descriptions
- Maintain up-to-date README.md files
- Document module usage and requirements

### 5. Module Development
- Keep modules focused on single responsibility
- Use semantic versioning for module releases
- Include comprehensive examples
- Provide clear input/output documentation
- Test modules independently

### 6. State Management
- Use remote state backends (S3, Terraform Cloud, etc.)
- Enable state locking to prevent conflicts
- Use separate state files per environment
- Never commit state files to version control
- Implement state backup strategies

### 7. Security Best Practices
- Never hardcode secrets or credentials
- Use Terraform data sources for sensitive information
- Implement least privilege access principles
- Enable encryption for sensitive resources
- Use secure communication protocols

### 8. Code Formatting and Style
- Use `terraform fmt` for consistent formatting
- Use 2-space indentation
- Align resource arguments for readability
- Use meaningful resource and data source names
- Keep line length reasonable (120 characters)

### 9. Resource Management
- Use data sources instead of hardcoded values when possible
- Implement proper resource dependencies
- Use `depends_on` explicitly when needed
- Tag all resources consistently
- Implement resource lifecycle management

### 10. Testing Requirements
- Write tests using Terratest or similar framework
- Test module functionality and edge cases
- Validate resource creation and configuration
- Test infrastructure changes in non-production first
- Include integration tests for complex setups

## Required Tools and Standards

### Development Environment
- Terraform 1.0+ (prefer latest stable version)
- terraform-docs for documentation generation
- tflint for additional linting
- terragrunt for DRY configurations (if applicable)

### Code Quality
- Run `terraform fmt` before committing
- Use `terraform validate` to check syntax
- Run `tflint` for additional checks
- Use pre-commit hooks for automation
- Address all validation errors and warnings

### Version Control
- Use semantic versioning for modules and major changes
- Write descriptive commit messages
- Create feature branches for new development
- Use pull requests for code review
- Tag stable releases

## Template Usage

1. Copy the template structure
2. Rename files and directories appropriately
3. Update README.md with project-specific information
4. Configure backend and provider requirements
5. Follow the coding standards outlined above
6. Write tests for infrastructure components
7. Run validation and formatting before committing

## Enforcement

- All code must pass terraform validate with no errors
- All modules must have proper documentation
- Code reviews are mandatory for all changes
- Infrastructure changes must be tested before production deployment

## Example Commands

### Basic Operations
```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

### Code Quality
```bash
terraform fmt -recursive
terraform validate
tflint --recursive
```

### Documentation
```bash
terraform-docs markdown table --output-file README.md .
```

### Testing
```bash
# Using Terratest
go test -v -timeout 30m
```

## Configuration Examples

### Provider Configuration
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstatesa"
    container_name       = "tfstate"
    key                  = "infrastructure/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
```

### Variable Definition
```hcl
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}
```

### Output Definition
```hcl
output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.main.id
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.main.id
}
```

### Resource Tagging
All resources must follow the standardized tagging scheme using common tags merged with resource-specific tags:

```hcl
resource "azurerm_virtual_machine" "web" {
  name                = "${var.project_name}-${var.environment}-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  vm_size             = var.vm_size

  tags = merge(
    var.common_tags,
    {
      BusinessUnit     = var.business_unit
      TechincalContact = var.technical_contact
      ApplicationName  = var.application_name
      Name             = "${var.project_name}-${var.environment}-web-server"
      Role             = "web-server"
    }
  )
}
```

#### Required Tag Structure
Define common tags and resource-specific tag variables:

```hcl
# Common tags applied to all resources
variable "common_tags" {
  description = "Common tags applied to all resources"
  type = object({
    IAC         = string
    Environment = string
    CreatedOn   = string
    CreatedBy   = string
  })
  default = {
    IAC         = "true"
    Environment = "prod"
    CreatedOn   = "01/01/2025"
    CreatedBy   = "Terraform"
  }
}

# Resource-specific tag variables
variable "business_unit" {
  description = "Business unit responsible for the resource"
  type        = string
  default     = "Platform Services"
}

variable "technical_contact" {
  description = "Technical contact for the resource"
  type        = string
  default     = "IT Operations"
}

variable "application_name" {
  description = "Name of the application or service"
  type        = string
  default     = "infrastructure"
}
```
