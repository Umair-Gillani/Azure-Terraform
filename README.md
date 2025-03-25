# Azure Terraform Infrastructure

## Introduction
This repository contains Terraform code for deploying an Azure infrastructure that includes a resource group, virtual network, subnets, a Bastion host, and an Azure Container Registry (ACR). The infrastructure is designed to support an Azure Kubernetes Service (AKS) cluster and other related resources.

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

## Components
- **Resource Group**: Organizes all resources in a specific Azure region.
- **Virtual Network (VNet)**: Provides a secure network for resources, with one public subnet and two private subnets.
- **Bastion Host**: Allows secure access to virtual machines in private subnets.
- **Azure Container Registry (ACR)**: Stores Docker images for use with AKS.
- **Azure Kubernetes Service (AKS)**: Manages containerized applications with Kubernetes.

## Usage
1. Set up your Azure credentials.
2. Modify the `variables.tf` file to set your desired configuration.
3. Run `terraform init` to initialize the Terraform configuration.
4. Run `terraform apply` to deploy the infrastructure.

## Outputs
After deployment, the following outputs will be available:
- Resource Group Name
- AKS Cluster Name
- ACR Name
- Public IP of Bastion Host
