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


---

# **Azure Infrastructure with Terraform**

This Terraform project sets up a **secure, highly available, and scalable** infrastructure on Microsoft Azure. The key highlights include:

- **VNet** with **three subnets** (public, AKS private, DB private).
- **Bastion Host** in the public subnet for secure SSH/management access.
- **AKS (Kubernetes) cluster** in the private subnet with auto-scaling.
- **Azure Container Registry (ACR)** for storing and pulling container images.
- **NSGs** (Network Security Groups) for restricting traffic flow (only specific ports and directions).
- **Private AKS cluster** so that Kubernetes API is only accessible within the VNet (no public endpoint).
- **Optional NAT Gateway** or Azure Load Balancer for outbound traffic from private subnets.

## **Purpose of This Code**

1. **Easy Resource Creation**  
   Automate deployment of core Azure components (like a VNet, AKS, and DB) with minimal manual effort.  
2. **Security-First Architecture**  
   - Private subnet for AKS nodes and DB, blocking all inbound traffic unless explicitly allowed by NSGs.  
   - A Bastion host in a public subnet for controlled SSH.  
   - Private endpoints for the AKS API server (private cluster).  
3. **Scalability & HA**  
   - AKS cluster uses auto-scaling from 3 → 4 nodes (or your chosen min/max).  
   - Azure Container Registry is integrated for easier container image pulls.  
4. **Reusable**  
   Variables (`.tfvars`) make it simple to change region, naming, or environment (staging vs. production).

## **Security Measures**

1. **Private Subnets**  
   - **AKS Subnet**: Denies all inbound except from Bastion or DB.  
   - **DB Subnet**: Denies all inbound except from AKS or specific public IP if needed (e.g., MySQL port).  
   - All other traffic is blocked by default, ensuring zero trust inbound.
2. **NSGs (Network Security Groups)**  
   - Each subnet has a dedicated NSG.  
   - Strict rules (port 22, 80, 443 only from internet on the public subnet).  
   - **Outbound** to internet is allowed so nodes can pull container images, updates.  
3. **Bastion Host**  
   - Deployed in the **public subnet**, so you never expose the private subnets directly.  
   - Only port 22 on this host, preventing direct SSH to private VMs.  
4. **Private AKS**  
   - Kubernetes API is only accessible inside the VNet (via Bastion or a jumpbox). No public IP for the control plane.  
   - Traffic flows through a **private endpoint**.
5. **Azure Container Registry**  
   - **`admin_enabled`** can be disabled in production for improved security, relying on Azure AD or tokens.  
   - Tokens/Webhooks provide granular push/pull permissions if needed.

## **Prerequisites**

1. **Azure Subscription**  
   - Make sure your subscription is **active** (not in read-only or disabled state).  
   - Enough vCPU quota if you plan to run multiple nodes.
2. **Terraform 1.x**  
   - `terraform -version` should show at least 1.0 or higher.  
3. **Azure CLI** (Optional but recommended)  
   - For checking cluster logs, debugging, and local credential authentication.
4. **SSH Key**  
   - Provide your public key for the Bastion host to allow secure SSH.
5. **Sufficient IP Range**  
   - Your VNet CIDR must be large enough to host AKS (especially if min_count + max_count is big).

## **How to Use**

1. **Clone This Repo**  
   ```bash
   git clone https://github.com/Umair-Gillani/Azure-Terraform.git
   cd Azure-Terraform
   ```
2. **Configure `.tfvars`**  
   - Set `location = "Central US"`, `vnet_cidr = "10.17.0.0/16"`, or anything else that suits your environment.
3. **Initialize and Plan**  
   ```bash
   terraform init
   terraform plan
   ```
4. **Apply**  
   ```bash
   terraform apply
   ```
5. **Access**  
   - Bastion Host: Public IP → SSH port 22  
   - AKS cluster: via Bastion, run:
     ```bash
     az aks get-credentials --name <aks_name> --resource-group <rg_name>
     kubectl get nodes
     ```
6. **Clean Up**  
   ```bash
   terraform destroy
   ```

## **Benefits**

- **Fully Automated**: No manual creation of subnets, NSGs, or resource groups.  
- **Reusable**: Switch from dev to production by simply changing `.tfvars` or variable defaults.  
- **Secure by Default**: Zero-trust inbound rules, private cluster, dedicated Bastion.  
- **Scalable**: AKS auto-scaling node pool plus a container registry for easy image pulls.

---
