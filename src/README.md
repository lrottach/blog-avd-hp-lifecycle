# Azure Virtual Desktop Terraform Demo: Session Host Lifecycle Management

A Terraform configuration demonstrating **proper AVD session host cleanup and scale-down operations**. This project showcases how to prevent orphaned session host registrations in Azure Virtual Desktop Host Pools when using infrastructure as code.

## 🎯 Purpose of This Demo

**Primary Focus**: This demo was created to demonstrate **automatic session host deregistration** from AVD Host Pools during Terraform destroy operations. When scaling down or destroying session hosts, many Terraform implementations leave behind "ghost" registrations in the Host Pool with "Can't connect" or "Unavailable" status.

**What This Demo Solves:**
- ✅ Automatic cleanup of session host registrations when destroying VMs
- ✅ Proper scale-down behavior (reduce session host count without manual cleanup)
- ✅ Version-based session host replacement with clean deregistration
- ✅ Force deletion support for active/disconnected user sessions
- ✅ Uses `azapi` provider to interact with AVD Host Pool API during destroy operations

**Key Features:**
- Automated deployment of AVD session hosts from marketplace images
- Self-contained networking (VNet and subnet creation)
- Modern security features (Trusted Launch, Encryption at Host, Entra ID Join)
- Version tracking through hostname suffixes
- **Session host cleanup logic using azapi provider**

📖 **Read the full blog post**: [Link will be added upon publication]

## ⚠️ Important Disclaimers

**Demo Purpose Only**: This project is created for blog post demonstrations and learning purposes. It showcases the session host lifecycle management pattern and is **not recommended for production environments** without significant modifications and hardening.

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
- **Automatic registration to existing AVD Host Pool**
- **Automatic deregistration on destroy using azapi provider**

**Security Features:**
- Trusted Launch (Secure Boot + vTPM)
- Encryption at Host enabled
- Entra ID Join for cloud-native identity
- Guest Attestation for integrity monitoring

**Architecture**: Two resource groups are automatically created: one for networking infrastructure and one for session hosts. Session hosts are connected to the provisioned VNet and registered to an existing AVD host pool using automatically generated registration tokens. The configuration uses the `azapi` provider to ensure proper cleanup of session host registrations during scale-down or destroy operations.

## 📋 Prerequisites

Before deploying, ensure you have:

1. **Azure subscription** with appropriate permissions (Contributor or higher)
2. **Existing AVD Host Pool** - Must be created beforehand in Azure
3. **Terraform** >= 1.5.0 installed locally
4. **Azure CLI** installed and authenticated (`az login`)

**Provider Requirements:**
- `hashicorp/azurerm` ~> 4.38
- `Azure/azapi` ~> 2.0 (for session host cleanup logic)

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

## 🔄 Session Host Lifecycle Management

This demo implements proper session host cleanup using the `azapi` provider to prevent orphaned registrations in the AVD Host Pool.

### How It Works

**During Creation/Update:**
- Session hosts are registered to the Host Pool via DSC extension
- `azapi_resource` data source tracks the registration
- No cleanup actions are performed

**During Scale-Down/Destroy:**
1. `azapi_resource_action` with `when = "destroy"` triggers
2. Sends DELETE request to Azure API with `force=true` parameter
3. Session host deregistered from Host Pool
4. VM deletion proceeds
5. Host Pool maintains clean state without orphaned entries

**Session Host FQDN Format** (Entra ID joined VMs):
```
{vm_name}.{azure_region}.cloudapp.azure.com
```
Example: `avd-sh-v1-001.westeurope.cloudapp.azure.com`

### Common Scenarios

**Scale Down**: Reduce `session_host_count` from 3 to 2
```hcl
session_host_count = 2  # Down from 3
```
Result: Third session host cleanly deregistered and VM deleted

**Version Replacement**: Change `vm_name_suffix` to deploy new generation
```hcl
vm_name_suffix = "v2"  # Was "v1"
```
Result: Old v1 hosts deregistered and deleted, new v2 hosts deployed

**Scale to Zero**: Remove all session hosts
```hcl
session_host_count = 0
```
Result: All session hosts deregistered and VMs deleted

**Force Deletion**: The `force=true` parameter handles:
- Active user sessions
- Disconnected (but not logged off) sessions
- Unavailable session hosts

## 🧹 Cleanup

To remove all deployed resources:

```bash
terraform destroy
```

**What Happens During Destroy:**
1. Session hosts are deregistered from the AVD Host Pool (via azapi)
2. Virtual machines and associated resources are deleted
3. Networking infrastructure is removed
4. Resource groups are deleted
5. **No orphaned session host registrations remain in the Host Pool**

**Warning**: This will delete all session hosts, networking infrastructure, and associated resources created by this configuration. The force deletion feature will disconnect any active user sessions.

## 📚 Additional Resources

- 📖 Blog Post: [Link will be added upon publication]
- [Azure Virtual Desktop Documentation](https://docs.microsoft.com/azure/virtual-desktop/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Terraform AzAPI Provider](https://registry.terraform.io/providers/Azure/azapi/latest)
- [Azure Marketplace Windows Images](https://docs.microsoft.com/azure/virtual-machines/windows/cli-ps-findimage)
- [AVD Session Hosts REST API](https://learn.microsoft.com/en-us/rest/api/desktopvirtualization/session-hosts)

## 🛠️ Technical Implementation

### Key Components

**Session Host Cleanup Logic** (`modules/session-hosts/main.tf`):
- `data.azapi_resource.avd_session_host` - Queries session host registrations
- `resource.azapi_resource_action.avd_session_host_delete` - Deletes registrations on destroy

**API Version**: `Microsoft.DesktopVirtualization/hostPools/sessionHosts@2022-02-10-preview`

**Dependencies**:
- azurerm provider: ~> 4.38
- azapi provider: ~> 2.0

### Files Modified for Session Host Cleanup

| File | Purpose |
|------|---------|
| `providers.tf` | Added azapi provider configuration |
| `main.tf` | Pass hostpool_id to session_hosts module |
| `modules/session-hosts/variables.tf` | Added hostpool_id variable |
| `modules/session-hosts/main.tf` | Implemented cleanup data source and resource action |
| `modules/session-hosts/versions.tf` | Declared provider requirements |

This implementation ensures that AVD Host Pools remain in a clean state when using infrastructure as code for session host management.
