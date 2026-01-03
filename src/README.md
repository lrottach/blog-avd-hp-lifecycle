# Azure Virtual Desktop Terraform Demo

A simplified Terraform configuration for deploying Azure Virtual Desktop (AVD) session hosts using Azure Marketplace images. This project demonstrates modern AVD deployment patterns with infrastructure as code.

**Key Features:**
- Automated deployment of AVD session hosts from marketplace images
- Self-contained networking (VNet and subnet creation)
- Modern security features (Trusted Launch, Encryption at Host, Entra ID Join)
- Version tracking through hostname suffixes

Read the full blog post: [Link to be added]

## ⚠️ Important Disclaimers

**Demo Purpose Only**: This project is created for blog post demonstrations and learning purposes. It is **not recommended for production environments** without significant modifications and hardening.

**Custom Images for Production**: While this demo uses Azure Marketplace images for simplicity and ease of deployment, production environments should consider using **custom images from Azure Compute Gallery** to:
- Maintain consistent baseline configurations across your environment
- Include pre-installed applications, patches, and corporate tools
- Implement organization-specific security hardening and compliance requirements
- Control update schedules and image versioning independently

## 🚀 What Gets Deployed

This Terraform configuration automatically creates:

**Network Infrastructure:**
- Resource group for networking (default: `rg-{network_name_prefix}-network`)
- Virtual Network with configurable address space (default: 10.0.0.0/16)
- Subnet for session hosts (default: 10.0.1.0/24)

**Session Hosts:**
- Resource group for session hosts (user-specified name)
- Windows 11 Enterprise Multi-Session + Microsoft 365 Apps (latest from marketplace)
- Deployed across availability zones for high availability
- System-assigned managed identities
- Network interfaces with dynamic IP allocation

**Security Features:**
- Trusted Launch (Secure Boot + vTPM)
- Encryption at Host enabled
- Entra ID Join for cloud-native identity
- Guest Attestation for integrity monitoring

**Architecture**: Two resource groups are automatically created: one for networking infrastructure and one for session hosts. Session hosts are connected to the provisioned VNet and registered to an existing AVD host pool using automatically generated registration tokens.

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Azure subscription** with appropriate permissions (Contributor or higher)
2. **Existing AVD Host Pool** - Must be created beforehand in Azure
3. **Terraform** >= 1.5.0 installed locally
4. **Azure CLI** installed and authenticated (`az login`)

## 🚀 Quick Start

1. **Clone and navigate to the project:**
   ```bash
   git clone <repository-url>
   cd avd-terraform-demo
   ```

2. **Configure your deployment:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your Azure resource names
   ```

3. **Set the admin password:**
   ```bash
   export TF_VAR_admin_password="YourSecurePassword123!"
   ```

4. **Deploy the infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

The host pool registration token is automatically generated with a 4-hour validity period.

## 🔧 Configuration

Key settings are configured in `terraform.tfvars`. Main options include:

- **Resource Groups**: Both networking and session host resource groups are created automatically
  - Session hosts: Specify explicit name via `resource_group_name`
  - Networking: Default `rg-{network_name_prefix}-network`, or override with `network_resource_group_name`
- **Session Host Count**: Number of VMs to deploy (default: 2)
- **VM Image**: Change `marketplace_image_sku` to use different Windows versions
- **Version Tracking**: Set `vm_name_suffix` (e.g., "v1", "v2") for hostname versioning
- **VM Size**: Default is `Standard_D4s_v5` (supports Trusted Launch and Encryption at Host)
- **Networking**: Customize VNet and subnet address spaces

**Common Windows SKUs** (see `terraform.tfvars.example` for complete list):
- `win11-23h2-avd-m365` - Windows 11 + M365 Apps (default)
- `win11-23h2-avd` - Windows 11 without M365
- `win10-22h2-avd-m365` - Windows 10 + M365 Apps

**Hostname Example** with `vm_name_suffix = "v1"`:
```
avd-sh-v1-001, avd-sh-v1-002, avd-sh-v1-003
```

## 🧹 Cleanup

To remove all deployed resources:

```bash
terraform destroy
```

**Warning**: This will delete all session hosts, networking infrastructure, and associated resources created by this configuration.

## 📚 Additional Resources

- Blog Post: [Link to be added]
- [Azure Virtual Desktop Documentation](https://docs.microsoft.com/azure/virtual-desktop/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Azure Marketplace Windows Images](https://docs.microsoft.com/azure/virtual-machines/windows/cli-ps-findimage)
