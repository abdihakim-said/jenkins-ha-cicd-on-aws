# 🚀 Jenkins High Availability CI Infrastructure Solution

## 📘 Overview

This project delivers a **secure, scalable, and highly available Jenkins CI/CD platform** built entirely on AWS, designed with full automation, enterprise-grade security, and production-level reliability.

✅ I was solely responsible for designing, building, automating, and securing the entire infrastructure — aligning DevOps best practices with business objectives.


---
<img width="737" alt="Screenshot 2025-06-03 at 01 24 44" src="https://github.com/user-attachments/assets/fccf7d35-68ec-4dc0-a3c5-a4dfd9864179" />


## 🧩 Business Scenario

A mid-sized technology consulting firm faced critical challenges with their CI platform:

- Jenkins master instability and **frequent downtime during upgrades**
- Manual, **time-consuming infrastructure management**
- **Manual deployments** Inconsistent configurations across environments
- **Scalability issues** as team sizes and workloads grew
- Increased **operational overhead** for DevOps teams and slow release cycles
- Lack of **security best practices and compliance enforcement**

---

## ❗ Objectives

To resolve these pain points, I was tasked to deliver a Jenkins infrastructure that is:

- ✅ **Highly available** across Availability Zones(multi-AZ)
- ✅ **Zero-downtime upgrade capable with rollback protection**
- ✅ **Fully automated** from image to deployment using Infrastructure as Code
- ✅ Compliant with security standards (IAM, encryption, backups)
- ✅ **Scalable** Scales automatically based on workload with auto-healing jenkins agents and dynamic agent provisioning
- ✅ Observable and easy to maintain by internal DevOps teams


---

## 🏗️ Solution Architecture

### 🔧 Key Components

| Tool / Service       | Purpose                                                   |
|----------------------|-----------------------------------------------------------|
| AWS (EC2, EFS, ELB)  | Compute, storage, HA routing                              |
| Auto Scaling Groups  | Dynamic Jenkins agent provisioning                        |
| Terraform            | Infrastructure provisioning (modular and reusable)        |
| Packer               | Golden AMI builds with secure Jenkins installation         |
| Ansible              | Jenkins configuration, security hardening                 |
| Jenkins (HA)         | Core CI/CD tool, running in a Blue-Green setup            |
| Bash / Shell         | Custom automation and backup scripts                      |
| Prometheus & Grafana | Monitoring and visualization                              |
| CloudWatch           | Logging and alerting                                      |
| S3 + Lifecycle Policy| Daily backups of Jenkins data with versioning and cleanup |

---
## 🔁 Deployment Strategy: Blue-Green
<img width="889" alt="Screenshot 2025-06-07 at 13 08 15" src="https://github.com/user-attachments/assets/449ecbe6-fe44-47ec-acea-abd35fecb18b" />


To enable **zero-downtime upgrades**, I implemented a Blue-Green deployment strategy:

1. Deploy new Jenkins instance (Green) using new AMI.
2. Mount existing **EFS volume** to ensure persistent Jenkins data.
3. Verify new instance with health checks and smoke tests.
4. Switch ELB traffic from Blue → Green.
5. Keep Blue as a fallback instance in case rollback is needed.

This method supports:
- 🔄 Jenkins version upgrades
- 💡 Instance type changes
- 💥 Instant rollback without disruption

---

## 🤔 Why Jenkins (HA) over GitHub Actions or GitLab CI?

While GitHub Actions and GitLab CI are great tools, I chose **self-hosted Jenkins in an HA setup** because:

- ✅ Full **infrastructure control** for compliance-heavy environments and **customizability**
- ✅ - Greater **plugin ecosystem** and compatibility with legacy integrations
- ✅ Easier rollback and upgrade strategy using AMIs  
- ✅ - Native support for **Blue-Green upgrade strategies** to achieve zero-downtime
- ✅ - High availability with **Elastic Load Balancer** and **Dynamic agent scaling via Auto Scaling**
- ✅ - **Centralized, scalable CI** across multiple teams

  This setup gave the client a **centralized, secure, and team-friendly CI platform** that could scale with demand and evolve with minimal vendor lock-in.

---
## 🧠 Why EC2 Over EKS?

As the lead DevOps consultant, I recommended EC2 over EKS for several key reasons:

### ✅ Business Constraints & Budget
- EKS introduces **control plane and per-service costs**, plus additional complexity.
- EC2 with Auto Scaling and EFS offered **predictable, lower cost**, and simplified management.

### ✅ Internal Team Skillset
- The client’s team had **no Kubernetes experience**.
- EC2 allowed them to leverage their existing knowledge in Linux, EC2, and Jenkins.

### ✅ Simplicity and Stability for Jenkins Master
- Jenkins master is a **stateful workload**.
- EC2 + EFS provided **straightforward backups, persistence, and auditability** without dealing with PVCs, StatefulSets, or persistent volume issues.

### ✅ Simpler HA and Upgrades
- **Blue-green upgrades** with ELB + Packer AMIs were easier to build and roll back compared to Kubernetes-based Jenkins master deployments.

### ✅ Fit for Purpose
- The goal wasn’t containerization, but a **stable, secure, and scalable CI/CD platform**.
- EC2 delivered more value faster and kept long-term maintenance simple for the client.

---
# 🔐 Monitoring & Backup Strategy – Jenkins HA CI/CD on AWS

This section outlines the observability and disaster recovery approach used in a highly available Jenkins infrastructure setup on AWS.

---

## 🔍 Monitoring Strategy

**Prometheus + Grafana Integration**

- Prometheus Jenkins exporter configured to expose:
  - Job duration & status
  - Queue length
  - Executor availability
  - Agent/node health

- Grafana dashboards for:
  - Build trends
  - Failed jobs over time
  - Agent load and saturation
  - CI performance metrics

- Alerting integrated via CloudWatch and Prometheus rules for high failure rates and build queue spikes

---

## 💾 Backup Strategy

**Automated Daily Backups with S3**

- Jenkins Home (`/var/lib/jenkins`) is backed up daily using a custom Bash script
- Script runs on a cron job and:
  - Creates a `.tar.gz` archive of Jenkins config and job data
  - Uploads to **S3 bucket** with encryption enabled
  - Tags backup with timestamp and instance version

**S3 Lifecycle Policies:**

- **Versioning enabled**: Allows point-in-time recovery
- **Lifecycle rules**:
  - Retain recent 30 days of backups
  - Automatically delete older versions after 90 days

---

## 🛠️ Technical Implementation (End-to-End by Me)

I was solely responsible for designing, implementing, securing, and automating the Jenkins HA infrastructure from the ground up.

---

### 1️⃣ Image Creation – **Packer**
- Built secure, hardened Jenkins master **Golden AMIs**
- Automated:
  - Plugin installation
  - System hardening
  - Jenkins setup
- Embedded **security scanning** using Trivy during AMI builds
- Quarterly AMI refreshes for patching and version updates
- AMI version tagging and change log management for auditability

---

### 2️⃣ Infrastructure Provisioning – **Terraform**
- Provisioned complete infrastructure in **multi-AZ architecture**
- Created:
  - EC2 instances (Jenkins Master, Agents)
  - Auto Scaling Groups for dynamic Jenkins agents
  - Elastic File System (EFS) for Jenkins persistent data
  - Elastic Load Balancer (ALB) with **Blue-Green** support
  - VPC, subnets, internet/NAT gateways, and route tables
- Used **remote state backend** in S3 + DynamoDB locking
- Infrastructure coded in **modular, reusable Terraform modules**

---

### 3️⃣ Jenkins Configuration – **Ansible**
- Configured Jenkins master with:
  - Secure CLI lockdown
  - Role-based access control (RBAC)
  - CSRF protection and plugin installation
- Built **idempotent Ansible roles** to ensure repeatable configurations across all environments (Dev/QA/Prod)

---

### 4️⃣ Deployment Strategy – **Blue-Green Deployment**
- Deployed new Jenkins AMI (Green) parallel to live (Blue)
- Mounted shared **EFS** to preserve job history and plugin state
- Performed smoke tests and health checks via ELB before switch
- Seamlessly routed traffic to Green using **ELB Target Groups**
- Kept Blue online temporarily for **rollback safety**

---

### 5️⃣ Monitoring & Observability – **Prometheus + Grafana + CloudWatch**
- Configured **Prometheus Jenkins Exporter** for CI metrics:
  - Job duration, queue depth, node health, executor availability
- Built **Grafana dashboards**:
  - CI health overview
  - Agent saturation
  - Failed job analysis
- Logs shipped to **AWS CloudWatch Logs**
  - With log groups and alerts for critical Jenkins events

---

### 6️⃣ Backup & Disaster Recovery Strategy – **Shell + S3**
- Automated **daily backups** of `/var/lib/jenkins` using a Bash script
- Script:
  - Runs via cron
  - Archives Jenkins config and job data
  - Uploads `.tar.gz` file to secure **S3 bucket**

#### S3 Configuration:
- ✅ **Versioning Enabled**: Enables point-in-time recovery
- ✅ **Server-Side Encryption (SSE)** for compliance
- ✅ **Lifecycle Policy**:
  - Retain backups for 30 days
  - Automatically delete objects >90 days old
  - Transition to Glacier if needed for cold storage

---
### Infrastructure and image updates fully orchestrated via Jenkinsfiles
<img width="756" alt="Screenshot 2025-06-07 at 13 06 48" src="https://github.com/user-attachments/assets/0cd02bda-4048-4f9c-80a6-7bd88b564a62" />

### 7️⃣ CI/CD Orchestration – **Jenkins Pipelines**
- Automated Blue-Green deployments and AMI refresh via Jenkinsfiles
- Git-triggered pipelines for infra updates (via Terraform) and image rebuilds (via Packer)
- All changes pass through Git approvals, vulnerability scans, and dry-run staging checks

---

> 🔐 **Security Best Practices Applied Throughout**
- IAM policies: **Least privilege**
- Network security: **Locked-down security groups**
- Secrets: **Encrypted and managed via AWS SSM/Secrets Manager**
- Jenkins: **No public access, secured via SSH jump box**

---

✅ This infrastructure is:
- **Repeatable** – templated for future teams or clients  
- **Reliable** – zero-downtime deployments with monitoring and rollback  
- **Scalable** – grows with demand through Auto Scaling and load balancing  
- **Secure** – meets compliance and audit requirements for DevOps maturity

---

## 📊 Challenges and Solutions

| Challenge                       | Solution                                                            |
|--------------------------------|---------------------------------------------------------------------|
| Downtime during upgrades       | Implemented blue-green deployment with ELB switching                |
| Inconsistent configurations    | Ansible roles for repeatable config across environments             |
| Security and compliance gaps   | Packer image scanning, IAM least privilege, encrypted EFS           |
| Manual effort and overhead     | Full automation via Terraform, Packer, Ansible, and CI scripts      |
| Limited monitoring & insight      | Prometheus + Grafana dashboards + CloudWatch logs & alerts       |

---

## 🔄 CI/CD Workflow

This workflow represents the complete lifecycle of provisioning, configuring, upgrading, and maintaining the Jenkins High Availability infrastructure — fully automated and repeatable.

```text
1. 🏗️ Build Secure Jenkins AMI
   - Triggered via Jenkins or GitHub commit
   - Packer pulls base image, installs Jenkins, applies hardening
   - Plugins pre-installed, Trivy scans image
   - Outputs version-tagged AMI

2. 🌐 Provision Infrastructure (Terraform)
   - Terraform deploys:
     - EC2 instances (Jenkins master & agents)
     - EFS volume
     - VPC, subnets, route tables
     - Auto Scaling Group & ELB for Blue/Green
   - State managed securely in S3 with DynamoDB locking

3. ⚙️ Configure Jenkins (Ansible)
   - Ansible connects to new EC2 instance
   - Applies:
     - Jenkins security (RBAC, CSRF protection)
     - Plugin config
     - CLI lockdown
   - Ensures idempotent, production-ready setup

4. 🔁 Blue-Green Upgrade Strategy
   - New “Green” Jenkins instance launched using fresh AMI
   - Mounts shared EFS for job history and configs
   - Sanity checks via ELB health targets
   - ELB traffic switched from “Blue” to “Green”
   - “Blue” remains on standby for rollback

5. 🔍 Monitoring & Observability
   - Prometheus scrapes metrics via Jenkins exporter
   - Grafana dashboards auto-refresh CI insights
   - CloudWatch captures logs and sends alerts

6. 💾 Daily Backups
   - Bash cron job creates `.tar.gz` of Jenkins home
   - Uploads to encrypted S3 bucket
   - S3 lifecycle policy retains 30 days, deletes after 90
   - Versioning enabled for rollback

7. 📈 CI/CD Control via Jenkins Pipelines
   - Infrastructure and image updates fully orchestrated via Jenkinsfiles
   - Supports multi-environment workflows (Dev, QA, Prod)
   - All updates pass through review + scan before deployment


## ✅ Project Outcomes

### 💼 Business Value

- **99.9% availability** of Jenkins CI/CD services
- **Zero-downtime upgrades**, enabling uninterrupted developer workflows(improving developer experience)
- **40% reduction in operational overhead** through full automation
- **Faster development cycles**, leading to improved time-to-market
- A **repeatable and scalable platform** for future clients or internal teams
- A **secure, scalable, and repeatable CI foundation**


### 🔧 Technical Achievements

- 🔁 **Fully automated infrastructure lifecycle** from image to deployment
- 🧱 Built **modular and reusable Terraform + Ansible roles**
- 🔐 **Security-first architecture** (RBAC, IAM, encrypted EFS, backup versioning)
- 🚀 Scalable design using **Auto Scaling Groups** and ELB-based routing
- 🔍 Observability built in from day one with **Prometheus and Grafana**
- ♻️ **Rollback strategy** with version-controlled Jenkins AMIs and Blue-Green logic


---

## 🧰 Technology Stack

| Category           | Tools & Services                                          |
|--------------------|-----------------------------------------------------------|
| Cloud              | AWS (EC2, ELB, EFS, Auto Scaling, IAM, S3, CloudWatch)    |
| IaC                | Terraform                                                 |
| Image Automation   | Packer                                                    |
| Config Management  | Ansible                                                   |
| CI/CD Engine       | Jenkins (HA + Blue-Green setup)                           |
| Monitoring         | Prometheus, Grafana, AWS CloudWatch                       |
| Backup             | S3 (versioning + lifecycle policies), Shell scripts       |
| Automation         | Bash / Shell                                              |

---

## 🧪 Getting Started

### 📋 Prerequisites

Before deploying, ensure you have the following:

- An AWS account with CLI credentials configured
- Installed locally:
  - [Terraform](https://developer.hashicorp.com/terraform/downloads)
  - [Packer](https://developer.hashicorp.com/packer/downloads)
  - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
  - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

---

