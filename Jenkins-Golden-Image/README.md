# Jenkins Golden AMI Pipeline

This project automates the creation, provisioning, and security scanning of a Jenkins AMI on AWS using Ansible roles, Packer, Terraform, and Trivy, orchestrated by a Jenkins pipeline.

---

<img width="756" alt="Screenshot 2025-06-07 at 13 06 48" src="https://github.com/user-attachments/assets/1b2878ba-7de5-41d7-a96e-28cbedbb2f87" />




## Problem Statement

Provisioning and maintaining consistent, secure, and up-to-date Jenkins environments on AWS can be time-consuming and error-prone. Manual setup leads to configuration drift, inconsistent environments, and potential security vulnerabilities. Additionally, integrating AWS resources like EFS and ensuring the AMI is secure before deployment adds further complexity.

## Solution

This project provides an automated, repeatable pipeline for building, configuring, and validating Jenkins AMIs on AWS. Using a combination of Terraform, Packer, Ansible, and Trivy, the pipeline:

- **Automates Infrastructure Provisioning:** Terraform manages AWS resources and injects dynamic values (like EFS IDs) into the build process.
- **Automates Jenkins AMI Creation:** Packer builds a new AMI using Ansible roles (`master` and `ospatch`) for consistent configuration.
- **Integrates AWS EFS:** The EFS ID is dynamically injected and configured during the AMI build.
- **Ensures Security:** Trivy scans the resulting AMI for vulnerabilities before it is used in production.
- **Orchestrates Everything in Jenkins:** The entire process is triggered and managed by a Jenkins pipeline, ensuring repeatability and auditability.

This approach eliminates manual steps, reduces errors, enforces security best practices, and delivers production-ready Jenkins AMIs with integrated AWS resources.


---

## Features

- **Ansible Roles**: Uses `master` and `ospatch` roles for AMI provisioning.
- **Packer**: Builds a Jenkins AMI, injecting the EFS ID.
- **Terraform**: Manages AWS infrastructure and triggers Packer builds.
- **Trivy**: Scans the built AMI for vulnerabilities.
- **Jenkins Pipeline**: Automates the entire workflow.

---

## Prerequisites

- Jenkins with a node labeled `packer`
- AWS credentials stored in Jenkins as secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Terraform, Packer, Ansible, and Trivy installed on the Jenkins agent
- Required IAM permissions for EC2, EFS, and AMI operations
- An existing EFS File System in AWS

---



## Pipeline Overview

1. **Terraform Stage**
    - Initializes and validates Terraform configuration.
    - Looks up the specified EFS file system.
    - Triggers a Packer build with the EFS ID injected as a variable.

2. **Packer Build**
    - Runs `setup.sh` as part of the AMI build.
    - Installs Ansible, extracts roles, and runs the `jenkins.yml` playbook with the EFS ID.

3. **Trivy Scan Stage**
    - Retrieves the latest AMI ID owned by your AWS account in `us-east-1`.
    - Runs a vulnerability scan on the AMI using Trivy.

---

## Key Files

- **`jenkins.yml`**: Ansible playbook using the `master` and `ospatch` roles.
- **`aws-ami.json`**: Packer template for building the Jenkins AMI.
- **`main.tf`**: Terraform configuration for AWS provider, EFS lookup, and Packer trigger.
- **`setup.sh`**: Installs Ansible, extracts roles, runs the playbook, and removes Ansible.
- **`vars.tfvars`**: Variables for Terraform (must include `efs_id`).

---

