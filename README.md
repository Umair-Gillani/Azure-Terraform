# Azure Terraform Infrastructure

## Directory Structure
```
.
├── main.tf                # Root module for Terraform configuration
├── variables.tf           # Input variables for the Terraform configuration
├── outputs.tf             # Outputs from the Terraform deployment
├── modules                # Directory containing reusable modules
│   ├── vnet               # Module for Virtual Network and Subnets
│   │   ├── main.tf        # Configuration for VNet and subnets
│   │   ├── outputs.tf     # Outputs for VNet module
│   │   └── variables.tf    # Variables for VNet module
│   ├── aks                # Module for Azure Kubernetes Service
│   │   ├── main.tf        # Configuration for AKS
│   │   ├── outputs.tf     # Outputs for AKS module
│   │   └── variables.tf    # Variables for AKS module
│   ├── bastion            # Module for Bastion host
│   │   ├── main.tf        # Configuration for Bastion
│   │   ├── outputs.tf     # Outputs for Bastion module
│   │   └── variables.tf    # Variables for Bastion module
│   ├── acr                # Module for Azure Container Registry
│   │   ├── main.tf        # Configuration for ACR
│   │   ├── outputs.tf     # Outputs for ACR module
│   │   └── variables.tf    # Variables for ACR module
│   └── resource_group      # Module for Resource Group
│       ├── main.tf        # Configuration for Resource Group
│       ├── outputs.tf     # Outputs for Resource Group module
│       └── variables.tf    # Variables for Resource Group module
└── .gitignore             # Git ignore file
```



