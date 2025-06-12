# 🚀 Jenkins High Availability CI Infrastructure Solution – AWS Based

## 📘 Project Overview

As a **DevOps Consultant at Luul Solutions**, I was engaged by a client to deliver a **highly available, secure, and fully automated Jenkins CI/CD platform on AWS**. The client's infrastructure relied on EC2-based deployments with no containerization, making it critical to build a scalable CI system that supports legacy workloads without compromising modern DevSecOps practices.



✅ I was solely responsible for designing, building, automating, and securing the entire infrastructure — aligning DevOps best practices with business objectives.


---
<img width="737" alt="Screenshot 2025-06-03 at 01 24 44" src="https://github.com/user-attachments/assets/fccf7d35-68ec-4dc0-a3c5-a4dfd9864179" />


## 🧩 Business Scenario

A mid-sized technology consulting firm faced critical challenges with their CI platform:

- ❌ Frequent Jenkins downtime during upgrades
- ❌ No consistent configuration between environments
- ❌ Manual image creation and patching
- ❌ No disaster recovery or rollback mechanism
- ❌ Zero observability or alerting
- ❌ No backup strategy for Jenkins job data


---

## ❗ Objectives

I was responsible for delivering an infrastructure that is:


- ✅ Highly available across multiple AZs using **Auto Scaling Groups**
- ✅ Zero-downtime upgrade-capable using **Blue-Green strategy**
- ✅ Built using **modular, reusable Infrastructure as Code**
- ✅ Secure with vulnerability scanning, IAM hardening, and encrypted storage
- ✅ Scalable with dynamic agent provisioning and automated image updates
- ✅ Fully monitored, observable, and auditable
- ✅ Disaster recovery–ready with S3 backups and rollback-safe AMIs


---

## 🏗️ Solution Architecture

| Tool / Service       | Purpose                                                    |
|----------------------|------------------------------------------------------------|
| AWS (EC2, EFS, ELB)  | Core infrastructure, storage, high availability routing     |
| Auto Scaling Groups  | High availability and self-healing for Jenkins agents       |
| Terraform            | Infrastructure provisioning (modular + reusable)            |
| Packer               | Golden AMI creation with Jenkins pre-installed              |
| Ansible              | Configuration of Jenkins master + hardening                 |
| Jenkins              | Core CI/CD tool, orchestrating the Golden Image pipeline    |
| Trivy                | Vulnerability scanning of AMIs                              |
| Bash / Shell         | Backup and automation scripts                               |
| Prometheus + Grafana | CI metrics, agent health, alerting dashboards               |
| S3 + Lifecycle       | Encrypted backups, versioning, and retention policies       |

---
## 🔄 Blue-Green Deployment Strategy


<img width="889" alt="Screenshot 2025-06-07 at 13 08 15" src="https://github.com/user-attachments/assets/449ecbe6-fe44-47ec-acea-abd35fecb18b" />

# To avoid downtime during upgrades:

1. 🔧 Jenkins "Green" AMI is created and deployed in a new ASG
2. 🧪 Health checks run via ELB
3. 🔁 ELB traffic switches from "Blue" to "Green"
4. 🔙 "Blue" is retained temporarily for rollback
5. 🔄 Result: **Zero downtime** during Jenkins upgrades or patching

---
This method supports:
- 🔄 Jenkins version upgrades
- 💡 Instance type changes
- 💥 Instant rollback without disruption

---


## 🔍 Monitoring & Backup Strategy

### Monitoring

- Jenkins metrics exported via **Prometheus Jenkins Exporter**
- Dashboards built in **Grafana**:
  - Build failures, agent load, job durations
- Alerting via **AWS CloudWatch** and Prometheus rules

### Backups

- Custom **cron job** runs on Jenkins master
- Archives `/var/lib/jenkins` into `.tar.gz`
- Uploads to **S3** with:
  - ✅ Versioning enabled
  - ✅ Server-side encryption (SSE)
  - ✅ Lifecycle rule:
    - Retain last 30 days
    - Auto-delete after 90 days

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

## 🛠️ Technical Implementation (End-to-End by Me)

I was solely responsible for designing, implementing, securing, and automating the Jenkins HA infrastructure from the ground up.

---

### 1️⃣ Golden AMI Pipeline – Packer + Jenkins + Ansible

- Terraform retrieves EFS ID
- Packer builds AMI with:
  - Jenkins, Java, NFS utils, and Jenkins data mount
  - Ansible roles for Jenkins setup and OS patching
- Trivy scans AMI for vulnerabilities
- AMI is tagged and stored in AWS for use in Launch Templates

### 2️⃣ Infrastructure Provisioning – **Terraform**
- Provisioned complete infrastructure in **multi-AZ architecture**
- Creates:
  - VPC, subnets, NAT gateways, routing
  - EFS for persistent Jenkins storage
  - ALB with HTTPS support
  - Auto Scaling Group and Launch Template
  - VPC Endpoints to access S3 securely (no public internet)
  - S3 bucket with backup lifecycle policies
- Used **remote state backend** in S3 + DynamoDB locking
- Infrastructure coded in **modular, reusable Terraform modules**

---

### 3️⃣ Jenkins Configuration – Ansible

- Installs Jenkins
- Configures RBAC, CSRF protection, secure CLI
- Installs essential plugins
- Locks down Jenkins Master using hardened roles
- Built **idempotent Ansible roles** to ensure repeatable configurations across all environments (Dev/QA/Prod)

---

### 4️⃣ High Availability

- Jenkins master is deployed in **ASG**
- **EFS** ensures all master instances access the same data
- **ALB** routes traffic based on health checks
- If master fails, ASG launches a new instance from Golden AMI

---

### 5️⃣ CI/CD Orchestration – Jenkins Pipelines

- AMI build and upgrade pipeline runs via Jenkins
- Git triggers Packer + Terraform workflows
- All commits pass through review, scan, and testing stages
- Environments supported: **Dev, QA, Prod**


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
| Inconsistent configurations    | Ansible roles for repeatable config across environments  
| Manual patching and backup     | Jenkinsfile + cron job + S3 automated retention                     |
| Security and compliance gaps   | Packer image scanning, IAM least privilege, encrypted EFS           |
| Manual effort and overhead     | Full automation via Terraform, Packer, Ansible, and CI scripts      |
| Lack of observability          | Prometheus + Grafana dashboards + CloudWatch logs & alerts          |

---

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
- 🚀 Scalable design using **Auto Scaling Groups** and ELB-based routing, 
- 🔍 Observability built in from day one with **Prometheus and Grafana**
- ♻️ **Rollback strategy** with version-controlled Jenkins AMIs for Seamless rollback strategy and Blue-Green logic


---

## 🧰 Technology Stack

| Category           | Tools & Services                                          |
|--------------------|-----------------------------------------------------------|
| Cloud              | AWS (EC2, ELB, EFS, Auto Scaling, IAM, S3, CloudWatch)    |
| IaC                | Terraform                                                 |
| Image Automation   | Packer                                                    |
| Config Management  | Ansible                                                   |
| CI/CD Engine       | Jenkins (HA + Blue-Green setup)                           |
| Observability      | Prometheus, Grafana, AWS CloudWatch   
| Security           | Trivy, IAM Least Privilege, SSE, VPC Endpoints            |
| Backup             | S3 (versioning + lifecycle policies), Bash cron scripts   |
| Automation         | Bash / Shell                                              |

---
---

## 📋 Getting Started

### Requirements

- AWS account + IAM access
- Jenkins Agent with:
  - Terraform
  - Packer
  - Ansible
  - AWS CLI
  - Trivy

---

## 👨‍💻 Author

**Abdihakim Said**  
DevOps & Multi-Cloud Engineer  
💼 Project completed as part of my consulting role at **Luul Solutions**  
📧 abdihakimsaid1@gmail.com  
🔗 [linkedin.com/in/said-devops](https://linkedin.com/in/said-devops)  
🔗 [github.com/abdihakim-said](https://github.com/abdihakim-said)

---

## 📄 License

MIT License

---

> Want to explore or fork the project?  
> 🔗 [GitHub Repository – jenkins-ha-cicd-on-aws](https://github.com/abdihakim-said/jenkins-ha-cicd-on-aws)
