# GCP Terraform Project

Welcome to my GCP Terraform project! This project was developed as part of an assignment during my journey to become a professional DevOps Engineer in the industry.

## Project Overview

This project deploys my home lab dashboard and front page using [Dashy](https://dashy.to/), an open-source application dashboard. The deployment architecture features a GKE cluster in a private project, connected through a Private Service Connect (PSC) connection from an external load balancer to a private load balancer. you can find the application here at [dashy-gcp.mdch-lab.dev](https://dashy-gcp.mdch-lab.dev)

## Architecture

The GCP Terraform project focuses on building relatively complex infrastructure on Google Cloud Platform using Terraform best practices and modern deployment patterns.

### High-Level Design (HLD)
![alt text](img/gcp-terraform.drawio.png)
## Key Features & Focus Points

### 1. Terraform Modules Usage
- Leveraged Terraform modules wherever possible to maintain code simplicity and reusability
- Utilized official Google Cloud modules for standardized infrastructure patterns
- Modular approach ensures maintainability and consistency across deployments

### 2. Automated Terraform Workflow
- **GitHub Actions Integration**: Unified CI/CD pipeline for infrastructure management
- **Workload Identity Federation (WIF)**: Secure authentication with Google Cloud from GitHub runners without using JSON keys
- **GitOps Approach**: Infrastructure managed entirely through code commits

### 3. Extended Provider Ecosystem
Beyond the standard Google provider, this project leverages multiple providers to extend Terraform functionality:

- **Flux Provider**: Automatically installs Flux in the GKE cluster and synchronizes manifests from the Git repository
- **Cloudflare Provider**: Updates A records in Cloudflare with the external load balancer's IP address
- **Kubernetes Provider**: Dynamically retrieves the ServiceAttachmentURL from CRDs created in the cluster using Flux

### 4. Modern Traffic Management with Envoy Gateway
- **Transition to Gateway API**: This project has migrated from traditional Ingress controllers to the more modern and powerful Kubernetes Gateway API, using Envoy Gateway as the implementation.

### 5. GitOps with FluxCD and CRD-Managed Resources
- **FluxCD for GitOps**: Leverages FluxCD to enable GitOps, with all Kubernetes manifests version-controlled in this repository.
- **CRD-Driven Infrastructure**: GCP resources that are directly related to the GKE cluster like ServiceAttachments and the internal Load Balancer are dynamically created and managed through Kubernetes CRDs and annotations, such as the Gateway service annotation and the ServiceAttachment CRD.

### 6. Cloud Armor Security
- **Advanced Security**: Utilizes Cloud Armor with Advanced DDoS Protection, restricting traffic to Israel only.
- **Enforced at the Edge**: The policy is attached to the external load balancer's backends, securing the application at the edge.

## Technical Challenges & Solutions

### Private Service Connect (PSC) External Load Balancer
**Challenge**: Initial connection issues between backend NEGs and service attachments despite seemingly correct configuration.

**Solution**: 
- Modified external load balancer type from `EXTERNAL` to `EXTERNAL_MANAGED`
- Resolved 400 errors from nginx ingress controller by addressing port configuration conflicts
- Issue was caused by PSC's port-agnostic nature where the internal load balancer selected port 443, conflicting with the external load balancer's port 80 forwarding after TLS termination

## Future Improvements

DevOps and IT projects are continuously evolving, and there's always room for enhancement. Here are planned improvements to enhance security, resiliency, and performance:

### 1. Full Lifecycle IaC Management with Terragrunt
**Goal**: Implement Terragrunt to automate the entire infrastructure lifecycle, from initial setup to application deployment, ensuring a secure, modular, and maintainable codebase.

**Improvement Plan**:
- **Dedicated Management Project**: Use Terragrunt to create and manage a dedicated project for core infrastructure, including OIDC configuration for GitHub WIF and initial IAM bindings.
- **DRY Configuration**: Keep the infrastructure code DRY (Don't Repeat Yourself) by defining common configurations once and reusing them across environments.
- **Granular IAM Security**: Provision a unique, least-privilege service account for each Terraform module, managed by Terragrunt, to eliminate reliance on a single, over-privileged account.
- **Dependency Orchestration**: Automate the deployment order and manage dependencies between different infrastructure components seamlessly.

### 2. Enhanced Cluster Security
**Current Limitation**: GKE control plane has public IP for GitHub runner connectivity.

**Security Enhancement Plan**:
- Disable public access to the control plane entirely
- Implement Identity-Aware Proxy (IAP) connection using a bastion host
- Migrate to self-hosted GitHub runners within the internal VPC
- Achieve complete network isolation while maintaining automation capabilities

### 3. End-to-End HTTPS Implementation
**Goal**: Implement comprehensive HTTPS encryption throughout the entire request path.

**Enhancement Plan**:
- Use DNS01 challenge with Cloudflare and use a valid backend certificate with authenticated backends.
- Allow TLS passthrough at the external load balancer to allow truly end-to-end encryption.

### 4. Enhanced Terraform Workflow
**Planned Features**:
- Pull Request integration with `terraform init` and `terraform plan` commands
- Automated failure notifications and reporting
- Enhanced code review process with infrastructure change previews