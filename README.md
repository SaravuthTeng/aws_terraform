# AWS Infrastructure Automation with Terraform

Modular AWS infrastructure labs built with **Terraform**—applying enterprise on-premise network segmentation, firewall chaining, and high-availability design principles to **Infrastructure as Code (IaC)**.

> **Project Status:** 🚧 **Active Development** — Phase 1 (Three-Tier Network Foundation) is complete. Compute (WordPress EC2/ALB), Database (RDS), and CI/CD automation are currently in progress.

---

## 📌 Project Roadmap: Three-Tier WordPress Architecture

* [x] **Phase 1: Three-Tier VPC & Network Security (`modules/three-tier-network`)** — Multi-AZ subnets, Internet/NAT gateways, isolated routing, and chained Security Groups.
* [ ] **Phase 2: Application & Database Tiers** — EC2 Auto Scaling Group for WordPress, Application Load Balancer (ALB), and Multi-AZ Amazon RDS (MySQL).
* [ ] **Phase 3: CI/CD Automation** — Automated `terraform fmt`, `validate`, `plan`, and `apply` workflows via GitHub Actions.

---

## 🏗️ Current Architecture (Phase 1: Network Layer)

```text
                           [ Internet ]
                                │
                    ┌───────────┴───────────┐
                    ▼  (Ports 80 / 443)     ▼
            [ Public Subnet 1 ]     [ Public Subnet 2 ]        (Tier 1: Future ALB & NAT Gateways)
             10.x.1.0/24 (AZ-1)      10.x.2.0/24 (AZ-2)
                    │                       │
                    ▼  (var.app_port)       ▼
           [ Private Subnet 1 ]    [ Private Subnet 2 ]       (Tier 2: Future WordPress App Tier)
            10.x.11.0/24 (AZ-1)     10.x.12.0/24 (AZ-2)
                    │                       │
                    ▼  (Port 3306)          ▼
          [ Isolated Subnet 1 ]   [ Isolated Subnet 2 ]       (Tier 3: Future RDS / Aurora DB Tier)
            10.x.21.0/24 (AZ-1)     10.x.22.0/24 (AZ-2)
```

### Design Decisions & Engineering Highlights
* **6-Subnet Multi-AZ Segmentation (`2 AZs x 3 Tiers`):** Uses `cidrsubnet()` to dynamically carve `/24` subnets across two Availability Zones:
  * **Public Subnets (`+1`, `+2`):** Routed to the Internet Gateway (`0.0.0.0/0`) for public-facing load balancers and NAT Gateways.
  * **Private Subnets (`+11`, `+12`):** Routed through NAT Gateways so application instances can download updates without direct inbound internet exposure.
  * **Isolated Subnets (`+21`, `+22`):** Uses a dedicated route table with **no** Internet Gateway or NAT Gateway routes to fully isolate the database tier.
* **Cost-Control Toggle (`var.single_nat_gateway`):** Added a boolean flag to deploy **1 NAT Gateway** in Dev/UAT labs (`true`) to reduce hourly AWS costs while retaining **2 NAT Gateways** (`false`) for multi-AZ high availability in Production.
* **Zero-Trust Security Group Chaining:** Configured standalone `aws_vpc_security_group_ingress_rule` and `egress_rule` resources so each tier only accepts traffic from the exact Security Group above it (`Internet -> public_sg -> private_sg -> isolate_sg`).

---

## 📂 Repository Structure

```text
aws_terraform/
├── devops/                        # Development / CI-CD lab environment
│   ├── backend.tf                 # Remote state backend configuration
│   ├── main.tf                    # Calls the three-tier-network module
│   ├── outputs.tf                 # Environment output values
│   ├── providers.tf               # AWS provider configuration
│   ├── variables.tf               # Input variable declarations
│   └── versions.tf                # Terraform & provider version constraints
├── modules/
│   └── three-tier-network/        # Reusable 3-tier VPC, subnet, routing & security module
│       ├── main.tf                # VPC, IGW, 6 Subnets, NAT GWs, Route Tables & 3-Tier SGs
│       ├── output.tf              # Exported network IDs (VPC, subnets, security groups)
│       └── variable.tf            # Module input parameters
├── prod/                          # Production environment configuration
├── .gitignore                     # Excludes local .terraform/ directories and state files
└── README.md                      # Project documentation
```

---

## 🛠️ Module Inputs (`modules/three-tier-network`)

| Variable | Description | Example |
| :--- | :--- | :--- |
| `environment` | Environment prefix for resource naming and tags | `"devops"` or `"prod"` |
| `vpc_cidr` | Base CIDR block for the three-tier VPC | `"10.0.0.0/16"` |
| `azs` | List of 2 Availability Zones for multi-AZ deployment | `["ap-southeast-1a", "ap-southeast-1b"]` |
| `single_nat_gateway` | `true` for 1 NAT Gateway (Dev/Lab cost saving) or `false` for 2 (Prod HA) | `true` |
| `app_port` | Application port allowed from `public_sg` to `private_sg` | `80` or `8080` |

---

## 🚀 How to Test Phase 1 (Network Deployment)

1. **Clone the repository:**
   ```bash
   git clone https://github.com
   cd aws_terraform/devops
   ```

2. **Initialize Terraform and download providers:**
   ```bash
   terraform init
   ```

3. **Preview the network resources to be created:**
   ```bash
   terraform plan
   ```

4. **Deploy the network stack:**
   ```bash
   terraform apply
   ```

5. **Clean up lab resources when finished:**
   ```bash
   terraform destroy
   ```

## 🤝 Acknowledgments

* Infrastructure code and documentation structured, reviewed, and refined with assistance from **Google AI**.

---

## 👨‍💻 Author

**Saravuth Teng** — *IT Infrastructure & Network Security Specialist transitioning to Cloud & DevOps Engineering*
* **GitHub:** [@SaravuthTeng](https://github.com)
