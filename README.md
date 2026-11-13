# AWS Infrastructure Automation with Terraform

Automated, modular AWS infrastructure labs built with **Terraform** and **CI/CD** practices—translating enterprise on-premise network security, subnet segmentation, and high-availability design into repeatable **Infrastructure as Code (IaC)**.

---

## 📌 Featured Project: Three-Tier WordPress Network & Deployment

A scalable, fault-tolerant three-tier AWS network architecture built with a custom reusable Terraform module (`modules/three-tier-network`) across isolated environments (`devops` and `prod`).

### Architecture Overview

```text
                           [ Internet Users ]
                                   │
                    ┌──────────────┴──────────────┐
                    ▼  (Ports 80 / 443)           ▼
            [ Public Subnet 1 ]           [ Public Subnet 2 ]        (Tier 1: ALB & NAT Gateways)
             10.x.1.0/24 (AZ-1)            10.x.2.0/24 (AZ-2)
                    │                             │
                    ▼  (var.app_port)             ▼
           [ Private Subnet 1 ]          [ Private Subnet 2 ]       (Tier 2: WordPress App Tier)
            10.x.11.0/24 (AZ-1)           10.x.12.0/24 (AZ-2)
                    │                             │
                    ▼  (Port 3306 / MySQL)        ▼
          [ Isolated Subnet 1 ]         [ Isolated Subnet 2 ]       (Tier 3: RDS / Aurora DB Tier)
            10.x.21.0/24 (AZ-1)           10.x.22.0/24 (AZ-2)
```

### Key Architectural & Security Highlights
* **6-Subnet Multi-AZ Segmentation (`2 AZs x 3 Tiers`):** Dynamically calculates `/24` subnet CIDRs using `cidrsubnet()` across two Availability Zones:
  * **Public Subnets (`+1`, `+2`):** Hosts the Application Load Balancer (ALB) and NAT Gateways with routes to the Internet Gateway (`0.0.0.0/0`).
  * **Private Subnets (`+11`, `+12`):** Hosts the WordPress application tier with outbound internet access routed through NAT Gateways for OS/plugin updates.
  * **Isolated Subnets (`+21`, `+22`):** Hosts the RDS / Aurora database tier with a dedicated route table containing **zero** Internet Gateway or NAT Gateway routes.
* **Cost-Optimized NAT Gateway Toggle (`var.single_nat_gateway`):** Supports deploying a single NAT Gateway in Dev/UAT (`true`) to reduce lab costs, or dual NAT Gateways across both AZs in Production (`false`) for full high availability.
* **Zero-Trust Security Group Chaining:** Enforces strict tier-to-tier traffic flow using standalone `aws_vpc_security_group_ingress_rule` and `egress_rule` resources:
  * **Tier 1 (`public_sg`):** Accepts inbound HTTP (`80`) and HTTPS (`443`) from `0.0.0.0/0` and restricts egress strictly to `private_sg` on `var.app_port`.
  * **Tier 2 (`private_sg`):** Accepts inbound traffic **only** from `public_sg` on `var.app_port`.
  * **Tier 3 (`isolate_sg`):** Accepts inbound MySQL (`3306`) traffic **only** from `private_sg`.

---

## 📂 Repository Structure

```text
aws_terraform/
├── devops/                        # Development / CI-CD lab environment
│   ├── backend.tf                 # Remote state backend configuration
│   ├── main.tf                    # Core environment resource definitions
│   ├── outputs.tf                 # Environment output values
│   ├── providers.tf               # AWS provider configuration
│   ├── variables.tf               # Input variable declarations
│   └── versions.tf                # Terraform & provider version constraints
├── modules/
│   └── three-tier-network/        # Reusable 3-tier VPC, subnet, routing & security module
│       ├── main.tf                # VPC, IGW, 6 Subnets, NAT GWs, Route Tables & 3-Tier SGs
│       ├── output.tf              # Exported network IDs (VPC, subnets, security groups)
│       └── variable.tf            # Module input parameters (vpc_cidr, azs, single_nat_gateway, app_port)
├── prod/                          # Production environment configuration
├── .gitignore                     # Excludes local .terraform/ directories and sensitive files
└── README.md                      # Project documentation
```

---

## 🛠️ Module Inputs (`modules/three-tier-network`)

| Variable | Description | Example |
| :--- | :--- | :--- |
| `environment` | Environment prefix for resource naming and tags | `"devops"` or `"prod"` |
| `vpc_cidr` | Base CIDR block for the three-tier VPC | `"10.0.0.0/16"` |
| `azs` | List of 2 Availability Zones for multi-AZ deployment | `["ap-southeast-1a", "ap-southeast-1b"]` |
| `single_nat_gateway` | Use `true` for 1 NAT Gateway (Dev/UAT) or `false` for 2 NAT Gateways (Prod) | `true` |
| `app_port` | Application port allowed from the ALB tier to the private app tier | `80` or `8080` |

---

## 🚀 Getting Started & Deployment

1. **Clone the repository:**
   ```bash
   git clone https://github.com
   cd aws_terraform
   ```

2. **Navigate to your target environment (`devops` or `prod`):**
   ```bash
   cd devops
   ```

3. **Initialize Terraform, configure the remote backend, and load the `three-tier-network` module:**
   ```bash
   terraform init
   ```

4. **Review the execution plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration to provision AWS resources:**
   ```bash
   terraform apply
   ```
   *(Type `yes` when prompted to confirm deployment.)*

---

## 🧹 Cleanup

To avoid ongoing AWS charges after testing the lab, destroy the provisioned infrastructure:

```bash
terraform destroy
```

---

## 🤝 Acknowledgments

* Infrastructure code and documentation structured, reviewed, and refined with assistance from **Google AI**.

---

## 👨‍💻 Author

**Saravuth Teng** — *IT Infrastructure & Network Security Specialist transitioning to Cloud & DevOps Engineering*
* **GitHub:** [@SaravuthTeng](https://github.com)
