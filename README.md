# 🔐 Secure AWS Infrastructure Provisioning with Terraform, Terragrunt & OPA

![Terraform](https://img.shields.io/badge/Terraform-v1.5+-informational?logo=terraform)
![GitHub Actions](https://img.shields.io/github/workflow/status/<your-org>/<your-repo>/Secure%20Terraform%20Provisioning?logo=github)
![License](https://img.shields.io/github/license/<your-org>/<your-repo>)

This repository provides an **enterprise-grade secure infrastructure-as-code (IaC) pipeline** using:

- **Terraform** – Provision infrastructure declaratively
- **Terragrunt** – DRY wrapper for Terraform with environment orchestration
- **OPA + Conftest** – Policy-as-code for governance
- **tfsec / Checkov** – Static code analysis for IaC
- **GitHub Actions** – CI/CD pipeline
- **AWS Services** – VPC, EC2, RDS, S3, IAM, KMS

---

## 📌 Use Cases

- Securely provision AWS infrastructure using Terraform
- Enforce compliance & governance via OPA policies
- Automate validation and deployment with CI/CD
- Maintain modular, reusable, and auditable IaC

---

## 📁 Folder Structure

```bash
.
├── modules/                # Reusable Terraform modules
├── policies/               # OPA policies (rego)
├── terragrunt/live/        # Dev/prod environment configurations
├── .github/workflows/      # CI/CD via GitHub Actions
├── conftest.yaml           # OPA test configuration
└── terragrunt.hcl          # Root configuration


---

## Secure Infrastructure Provisioning with Terraform, Terragrunt, OPA on AWS

Overview

This repository demonstrates an enterprise-grade, secure infrastructure provisioning workflow using the following tools:

Terraform – Infrastructure as Code (IaC)

Terragrunt – DRY wrapper for Terraform

OPA (Open Policy Agent) + Conftest – Policy as code

tfsec / Checkov – Static code analysis

GitHub Actions – CI/CD pipeline

AWS Services – VPC, EC2, RDS, S3, IAM, KMS


Architecture

                        Git Repository (IaC)
                               |
                    +----------+----------+
                    |                     |
          Pre-commit hooks          CI/CD Pipeline (GitHub Actions)
                    |                     |
       +------------+----------+          |
       | OPA (Conftest)        |          |
       | tfsec / checkov       |          |
       +------------+----------+          |
                    |                     v
             Terragrunt (plan/apply) -> Terraform Modules
                                           |
                                +----------+----------+
                                |                     |
                        AWS Services Provisioned (e.g., VPC, EC2, RDS)
                                |
                     Audit via AWS Config, CloudTrail, GuardDuty

Folder Structure

.
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   └── s3/
│
├── policies/                  # OPA policies (Rego files)
│   └── deny_public_s3.rego
│
├── terragrunt/
│   └── live/
│       ├── dev/
│       │   ├── vpc/terragrunt.hcl
│       │   ├── ec2/terragrunt.hcl
│       │   └── rds/terragrunt.hcl
│       └── prod/
│           └── ...
│
├── .github/workflows/         # GitHub Actions pipeline
│   └── secure-provisioning.yml
│
├── conftest.yaml              # OPA test config
├── terragrunt.hcl             # Root Terragrunt config
└── README.md

GitHub Actions: secure-provisioning.yml

name: Secure Terraform Provisioning

on:
  push:
    paths:
      - '**.tf'
      - '**.hcl'
      - '**.rego'
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Terraform
      uses: hashicorp/setup-terraform@v2

    - name: Run tfsec
      uses: aquasecurity/tfsec-action@v1.0.0

    - name: Run Checkov
      uses: bridgecrewio/checkov-action@v12

    - name: Run Conftest (OPA policy check)
      run: |
        conftest test terragrunt/live/dev/

    - name: Terragrunt Plan
      run: |
        cd terragrunt/live/dev/vpc
        terragrunt plan

Sample OPA Policy: deny_public_s3.rego

package main

deny[reason] {
  input.resource_type == "aws_s3_bucket"
  input.config.acl == "public-read"
  reason := "S3 buckets must not be publicly readable"
}

Tools Summary

Tool

Purpose

Terraform

Infrastructure provisioning (IaaS)

Terragrunt

Modular, reusable infrastructure configs

OPA + Conftest

Policy enforcement pre-deployment

tfsec / Checkov

Static code security checks

GitHub Actions

CI/CD automation

AWS Services

VPC, EC2, RDS, IAM, KMS, S3, etc.

AWS Config

Auditing deployed resources

CloudTrail, GuardDuty

Logging and threat detection

Secure Workflow Example

# 1. Lint Terraform
$ tflint

# 2. Static security analysis
$ tfsec .
$ checkov -d .

# 3. OPA Policy Testing
$ conftest test terragrunt/live/dev/

# 4. Terraform Plan and Apply using Terragrunt
$ cd terragrunt/live/dev/vpc
$ terragrunt plan
$ terragrunt apply

Next Steps

Add pre-commit hooks for tfsec/checkov/opa

Implement environment-specific guardrails (e.g., via SCPs in AWS Organizations)

Set up AWS Config rules for drift detection and continuous compliance

Use AWS Secrets Manager and KMS for secure credential and key management

This setup provides a robust foundation for secure, compliant, and scalable cloud infrastructure provisioning.

|---------------------------|----------------------------------------------|
| Tool/Service              | Purpose                                      |
|---------------------------|----------------------------------------------|
| Checkov / tfsec           | Static code analysis for Terraform           |
| AWS Config                | Detect and remediate misconfigurations       |
| AWS IAM Access Analyzer   | Detect overly permissive IAM policies        |
| KMS + Secrets Manager     | Key and secret lifecycle management          |
| AWS Organizations SCPs    | Enforce guardrails across accounts           |
| AWS CloudTrail + GuardDuty| Monitoring & threat detection                |
|---------------------------|----------------------------------------------|

