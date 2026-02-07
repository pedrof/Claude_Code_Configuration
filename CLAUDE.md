# Developer Profile
- Name: Pedro Fernandez
- Email: microreal@shadyknollcave.io
- Environment: homelab K3s cluster

# Available CLI Tools
## Kubernetes & Container Tools
- kubectl - Kubernetes CLI (configured for K3s cluster)
- kubeseal - Sealed Secrets encryption
- kustomize - Kubernetes manifest management
- podman - Container management (no Docker)

## Git & Repository Management
- git - Version control
- tea - Gitea CLI (for git.shadyknollcave.io)
- gh - GitHub CLI (for github.com backup repos)

## Development Tools
- python3 / pip - Python development
- node / npm - Node.js development
- jq / yq - JSON/YAML processing

# Git Workflow
## Repository Auto-Creation
- **Always check if repository exists first**
- **If repository doesn't exist**: Create it automatically using `tea` CLI
- **Primary**: Create on git.shadyknollcave.io/micro/[project-name]
- **Backup**: Create on github.com:pedrof/[project-name] using `gh` CLI
- Set up both remotes in local git config

## Primary Repository
- URL: https://git.shadyknollcave.io/micro/[project-name]
- Protocol: HTTPS (default)
- CLI: Use `tea` for Gitea operations, `git` for version control

## Backup Repository  
- URL: git@github.com:pedrof/[project-name]
- Protocol: SSH
- CLI: Use `gh` for GitHub operations
- Auto-sync: Push to both remotes on every commit

## Versioning Strategy
- **Semantic Versioning**: MAJOR.MINOR.PATCH (e.g., v1.0.0)
- **Automatic Git Tagging**: Create annotated tags on releases
- **Changelog Generation**: Maintain CHANGELOG.md using conventional commits
- **Tag format**: v1.0.0
- **Branch strategy**: 
  - main - production-ready code
  - develop - integration branch
  - feature/* - feature branches
- **Commit conventions**: 
  - feat: New feature
  - fix: Bug fix
  - docs: Documentation
  - chore: Maintenance
  - breaking: Breaking changes (triggers MAJOR version bump)

# Infrastructure
## Kubernetes Environment
- Platform: Rancher K3s cluster
- Nodes: 3x Beelink SER9 Max
- GitOps: ArgoCD
- Default namespace: default (or specify per-project)

## Container Registry
- Registry URL: git.shadyknollcave.io (Gitea integrated registry)
- Image format: git.shadyknollcave.io/micro/[project-name]:[tag]
- Build tool: podman build (not docker)
- Push using: podman push

## Secrets Management
- Tool: Sealed Secrets with kubeseal
- Never commit plain secrets
- Generate sealed secrets for K8s deployments

# Coding Standards
## Languages
- Python: Primary scripting/backend language
- Node.js: JavaScript/TypeScript applications
- Shell: Bash scripts for automation

## Formatting & Linting
- Python: black, pylint/flake8
- Node.js: prettier, eslint
- YAML: yamllint

## Documentation
- Comprehensive README.md for every project
- Inline code comments
- API documentation where applicable

## Kubernetes Manifests
- Use Kustomize overlays (base, dev, prod)
- Include resource requests/limits
- Add ArgoCD Application manifests

# Security Requirements
- No secrets in code/manifests (use Sealed Secrets)
- PKI-aware configurations
- Air-gap compatible solutions when possible
- Container images from trusted sources or self-built

# Project Preferences
## Every New Project Should Include:
- README.md with:
  - Project description
  - Prerequisites
  - Installation/deployment instructions
  - Usage examples
  - Development setup
- CHANGELOG.md (auto-generated from commits)
- Makefile for common tasks (build, test, deploy)
- .env.template for environment variables
- .gitignore appropriate for language/framework
- Kubernetes manifests in k8s/ directory
  - base/ kustomization
  - overlays/ for different environments
  - ArgoCD Application manifest
- Containerfile (not Dockerfile - using podman)
- VERSION file or equivalent

## Git Repository Setup Process
1. Check if repo exists on Gitea (tea repo list)
2. If not exists: Create with `tea repo create`
3. Check if repo exists on GitHub (gh repo list)
4. If not exists: Create with `gh repo create`
5. Initialize local repo with both remotes:
   - origin: git.shadyknollcave.io (primary)
   - backup: github.com (secondary)
6. Initial commit with project structure
7. Push to both remotes

## Container Image Workflow
1. Build: `podman build -t git.shadyknollcave.io/micro/[project]:[version]`
2. Test locally with podman
3. Push: `podman push git.shadyknollcave.io/micro/[project]:[version]`
4. Update K8s manifests with new image tag
5. ArgoCD will sync changes automatically



## Kubernetes Cluster Configuration

  ### Cluster Overview
  - **Platform**: Rancher K3s v1.34.3+k3s1
  - **Nodes**: 3x Beelink SER9 Max (24 cores/48 threads, 192GB RAM, 10GbE)
  - **Network**: VLAN 10 (10.10.10.0/24)
  - **CNI**: Cilium v1.18.6 with eBPF and BGP
  - **Ingress**: Cilium Ingress Controller with shared LoadBalancer
  - **TLS**: cert-manager v1.19.2 with Let's Encrypt automation

  ### Cilium CNI & Ingress Configuration

  #### Installation
  Cilium is installed via Helm with values at `/home/micro/development/k3s-homelab-config/cilium/values.yaml`:
  ```bash
  helm install cilium cilium/cilium --version 1.18.6 --namespace kube-system --values cilium/values.yaml

  Key Cilium Features

  - BGP Control Plane: Enabled for external route advertisement
  - Ingress Controller: Built-in ingress (replaces Traefik/Ingress-Nginx)
  - LoadBalancer Mode: Shared (single IP for all ingress resources)
  - kube-proxy Replacement: Enabled (pure eBPF)
  - Hubble: Network observability with UI
  - IPAM: Cluster pool mode (automatic pod IP management)
  - Tunneling: Disabled (native routing for better performance)

  LoadBalancer IP Pool

  File: /home/micro/development/k3s-homelab-config/manifests/cilium/lb-ip-pool.yaml
  - Range: 10.10.10.200/29 (8 IPs: 10.10.10.200 - 10.10.10.207)
  - Usage: All LoadBalancer-type services automatically get IPs from this pool
  - Annotation: io.cilium/lb-ipam: main-pool

  BGP Configuration

  File: /home/micro/development/k3s-homelab-config/manifests/cilium/bgp-cluster-config.yaml

  BGP Peering Setup:
  - Cluster AS: 65001
  - Router AS: 65000 (UniFi Dream Machine Pro)
  - Router IP: 10.10.10.1
  - Multihop TTL: 1 (eBGP multihop enabled)

  Advertised Routes:
  1. LoadBalancer IP Pool: 10.10.10.200/29
  2. Pod CIDR: 10.42.0.0/16

  Verification:
  # Check BGP peers
  cilium bgp peers

  # Check LoadBalancer IPs
  kubectl get svc -A | grep LoadBalancer

  # Verify routes
  ip route | grep 10.10.10.20

  cert-manager & Let's Encrypt Integration

  Installation

  cert-manager installed via Helm:
  helm install cert-manager jetstack/cert-manager --namespace cert-manager --version 1.19.2 --set installCRDs=true

  ClusterIssuers

  Production: /home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-production.yaml
  - Server: Let's Encrypt Production (acme-v02.api.letsencrypt.org)
  - Email: microreal@shadyknollcave.io
  - Challenges:
    - HTTP-01: Standard certificates (via Cilium Ingress)
    - DNS-01: Wildcard certificates (via Route53)
  - Route53 Zone: Z1TUW8YIHHEO9X (shadyknollcave.io)
  - Region: us-east-1

  Staging: /home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-staging.yaml
  - Server: Let's Encrypt Staging (for testing, avoids rate limits)
  - Same configuration as production

  AWS IAM Requirements

  For Route53 DNS-01 challenges, the AWS credentials secret requires:
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "route53:GetChange",
          "route53:ListHostedZonesByName"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource": "arn:aws:route53:::hostedzone/Z1TUW8YIHHEO9X"
      }
    ]
  }

  Certificate Management

  - Auto-renewal: 30 days before expiry
  - Monitoring: Check certificate status with kubectl get certificate -A
  - Troubleshooting: Check cert-manager logs: kubectl logs -n cert-manager -l app=cert-manager

  Ingress Configuration

  Cilium Ingress Controller

  - IngressClass: cilium
  - Shared IP: All ingress resources share 10.10.10.200 (SNI-based routing)
  - TLS Termination: Handled by Cilium Ingress
  - Backend Routing: SNI hostname routes to different services

  Standard Ingress Manifest Template

  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: app-name
    namespace: app-namespace
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
  spec:
    ingressClassName: cilium
    tls:
    - hosts:
      - appname.shadyknollcave.io
      secretName: app-name-tls
    rules:
    - host: appname.shadyknollcave.io
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: app-service
              port:
                number: 80

  Network Flow

  Internet (HTTPS:443)
      ↓
  Public IP (UDM Pro WAN)
      ↓
  Port Forward: WAN:443 → 10.10.10.200:443
      ↓
  Cilium Ingress LoadBalancer (10.10.10.200)
      ↓
  SNI-based hostname routing
      ↓
  Backend Service (ClusterIP)
      ↓
  Application Pods

  Example Applications

  Currently deployed with ingress:
  - Rancher: rancher.shadyknollcave.io
  - ArgoCD: argocd.shadyknollcave.io
  - Gitea: git.shadyknollcave.io
  - Grafana: grafana.shadyknollcave.io
  - Hubble UI: hubble.shadyknollcave.io

  K3s Configuration

  Server Config (/etc/rancher/k3s/config.yaml)

  disable:
    - traefik          # Replaced by Cilium Ingress
    - servicelb        # Replaced by Cilium LoadBalancer
    - flannel          # Replaced by Cilium CNI
  cluster-cidr: 10.42.0.0/16
  service-cidr: 10.43.0.0/16

  Network CIDRs

  - Pod CIDR: 10.42.0.0/16 (managed by Cilium IPAM)
  - Service CIDR: 10.43.0.0/16 (ClusterIP services)
  - LoadBalancer IPs: 10.10.10.200/29 (external access)

  Verification Commands

  # Check Cilium status
  cilium status
  cilium connectivity test

  # Check BGP peers
  cilium bgp peers

  # List all LoadBalancer services
  kubectl get svc -A | grep LoadBalancer

  # List all ingress resources
  kubectl get ingress -A

  # Check certificates
  kubectl get certificate -A
  kubectl describe certificate -n <namespace> <cert-name>

  # Check cluster issuers
  kubectl get clusterissuers

  # View certificate requests
  kubectl get certificaterequests -A

  # Check cert-manager logs
  kubectl logs -n cert-manager -l app=cert-manager --tail=100 -f

  # Test ingress connectivity
  curl -v https://appname.shadyknollcave.io

  Troubleshooting

  Certificate Issues

  # Check certificate request status
  kubectl describe certificaterequest -n <namespace> <request-name>

  # Check challenge status
  kubectl get challenges -A

  # View cert-manager logs
  kubectl logs -n cert-manager -l app=cert-manager

  Ingress Issues

  # Check Cilium ingress logs
  kubectl logs -n kube-system -l k8s-app=cilium | grep ingress

  # Verify LoadBalancer IP assigned
  kubectl get svc -n <namespace> <service-name>

  # Test DNS resolution
  nslookup appname.shadyknollcave.io

  # Check port forwarding on UDM Pro
  # Verify WAN:443 → 10.10.10.200:443

  BGP Issues

  # Verify BGP session established
  cilium bgp peers

  # Check advertised routes
  cilium bgp routes

  # Verify route propagation on UDM Pro
  # Log into UDM Pro → Settings → Routing → BGP Routes

# the two types of ingress we use

The cluster supports two ingress controllers for different use cases: **Cilium Ingress**
  (ingressClassName: `cilium`) for external/public access, and **Ingress-Nginx Local**
  (ingressClassName: `nginx-local`) for internal/cluster-only access. Cilium Ingress uses a
  shared LoadBalancer IP (10.10.10.200) with SNI-based routing, advertised via BGP to the UDM
   Pro, making it ideal for publicly-exposed services with automatic Let's Encrypt TLS
  certificates via DNS-01 or HTTP-01 challenges. Ingress-Nginx Local uses a dedicated
  LoadBalancer IP (10.10.10.210) for internal services, administrative interfaces, or
  development/testing environments that should not be exposed to the internet; it supports
  either HTTP-only or HTTPS with self-signed certificates (via cert-manager's
  selfsigned-issuer ClusterIssuer), though browsers will show security warnings for
  self-signed certificates.


  Key File Locations

  - Cilium Values: /home/micro/development/k3s-homelab-config/cilium/values.yaml
  - LoadBalancer Pool: /home/micro/development/k3s-homelab-config/manifests/cilium/lb-ip-pool.yaml
  - BGP Config: /home/micro/development/k3s-homelab-config/manifests/cilium/bgp-cluster-config.yaml
  - Production Issuer: /home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-production.yaml
  - Staging Issuer: /home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-staging.yaml
  - Sample Ingress: /home/micro/development/k3s-homelab-config/manifests/apps/sample-ingress.yaml



