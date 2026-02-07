# System Instructions

## Core Directives

### Decision Making Priorities
When making decisions, prioritize in this order:
1. **Security**: PKI-aware, air-gap compatible, no plain secrets
2. **Standards Compliance**: Follow all conventions marked [REQUIRED] below
3. **Efficiency**: Use dual-remote Git workflow, automated tooling
4. **Clarity**: Ask when uncertain, state assumptions explicitly

### Tool Substitutions (MANDATORY)
- **podman** (not docker) for all container operations
- **tea** (not git CLI) for Gitea operations
- **gh** for GitHub backup operations
- **Containerfile** (not Dockerfile) for container builds

### When to Ask vs Proceed

**ASK before:**
- Creating new Git repositories (Gitea or GitHub)
- Pushing to remotes (origin or backup)
- Applying Kubernetes manifests to cluster
- Deleting any resources (files, containers, K8s resources)
- Modifying production infrastructure

**PROCEED with:**
- Reading files and gathering context
- Running local tests (pytest, npm test, etc.)
- Generating code and documentation
- Creating local branches
- Building container images locally

**CONFIRM assumptions when:**
- Configuration is ambiguous (state assumption and proceed)
- Multiple valid approaches exist (present options)
- Tool availability is uncertain (check and report)

### Error Handling
- **Tool unavailable**: Suggest alternative or ask user to install
- **File doesn't exist**: Create according to project standards
- **Command fails**: Report error, suggest fix, ask for confirmation
- **Permission denied**: Check permissions, suggest using sudo if appropriate

# Developer Profile & Environment

## Who
- **Name**: Pedro Fernandez
- **Email**: microreal@shadyknollcave.io
- **Environment**: Air-gapped/PKI-protected networks, homelab K3s cluster

## Security Context
- **Network**: VLAN 10 (10.10.10.0/24) - isolated homelab
- **PKI**: Certificate-based authentication for services
- **Secrets**: Sealed Secrets only - never commit plain secrets
- **Air-gap**: Prefer self-built/trusted images, offline-compatible solutions
- **Access Control**: Role-based access, principle of least privilege

# Infrastructure Overview

## Kubernetes Cluster
- **Platform**: Rancher K3s v1.34.3+k3s1
- **Nodes**: 3x Beelink SER9 Max (24 cores/48 threads, 192GB RAM, 10GbE)
- **GitOps**: ArgoCD for continuous deployment
- **Default Namespace**: default (or specify per-project)

## Network Architecture
- **Pod CIDR**: 10.42.0.0/16 (managed by Cilium IPAM)
- **Service CIDR**: 10.43.0.0/16 (ClusterIP services)
- **LoadBalancer IPs**: 10.10.10.200/29 (external access)
- **CNI**: Cilium v1.18.6 with eBPF and BGP (replaces Flannel/kube-proxy)

## Ingress Strategy
The cluster uses two ingress controllers for different purposes:

1. **Cilium Ingress** (ingressClassName: `cilium`)
   - **Purpose**: External/public access
   - **IP**: Shared 10.10.10.200 (SNI-based routing)
   - **TLS**: Let's Encrypt certificates (DNS-01 or HTTP-01)
   - **BGP**: Advertised to UDM Pro for internet routing
   - **Use for**: Public-facing applications, production services

2. **Ingress-Nginx Local** (ingressClassName: `nginx-local`)
   - **Purpose**: Internal/cluster-only access
   - **IP**: Dedicated 10.10.10.210
   - **TLS**: Self-signed certificates (browsers show warnings)
   - **Use for**: Admin interfaces, internal tools, dev/test environments

## Container Registry
- **URL**: git.shadyknollcave.io (Gitea integrated registry)
- **Image Format**: git.shadyknollcave.io/micro/[project-name]:[tag]
- **Build Tool**: podman build
- **Authentication**: PKI-based, integrated with Gitea

# Available Tools

## Kubernetes & Container Tools
- `kubectl` - Kubernetes CLI (configured for K3s cluster)
- `kubeseal` - Sealed Secrets encryption
- `kustomize` - Kubernetes manifest management
- `podman` - Container management (MANDATORY - not docker)
- `cilium` - Cilium CLI for network operations

## Git & Repository Management
- `git` - Version control
- `tea` - Gitea CLI for git.shadyknollcave.io (MANDATORY for Gitea operations)
- `gh` - GitHub CLI for github.com backup repos

## Development Tools
- `python3` / `pip` - Python development
- `node` / `npm` - Node.js development
- `jq` / `yq` - JSON/YAML processing
- `black` - Python code formatting
- `prettier` - JavaScript/TypeScript formatting
- `yamllint` - YAML linting

# Core Workflows

## New Project Creation Workflow

**Trigger**: User requests creating a new application/project, says "let's start a new project", or asks to initialize a project

**Process:**
1. **Check if Gitea repo exists**: `tea repo list | grep <project-name>`
2. **If not found, create on Gitea**:
   ```bash
   tea repo create --name <project-name> --owner micro --description "<project description>"
   ```
3. **Check if GitHub backup exists**: `gh repo list pedrof | grep <project-name>`
4. **If not found, create on GitHub**:
   ```bash
   gh repo create <project-name> --public --description "<project description>"
   ```
5. **Initialize local repository with both remotes**:
   ```bash
   git init
   git remote add origin https://git.shadyknollcave.io/micro/<project-name>.git
   git remote add backup git@github.com:pedrof/<project-name>.git
   ```
6. **Create project structure** (see Project Standards below)
7. **Initial commit** with comprehensive README.md
8. **Push to both remotes**:
   ```bash
   git push -u origin main
   git push -u backup main
   ```

**Assumptions:**
- Project name should be lowercase, hyphen-separated
- Default to public visibility unless user specifies private
- Use semantic versioning from the start (v0.1.0 for initial release)

## Container Build & Deploy Workflow

**Trigger**: User mentions "deploy", "push image", "build container", or "update manifests"

**Process:**
1. **Read VERSION file** or prompt for version tag
2. **Build container image**:
   ```bash
   podman build -t git.shadyknollcave.io/micro/<project>:<version> .
   ```
3. **Test locally** (if user requests or automated tests exist):
   ```bash
   podman run --rm git.shadyknollcave.io/micro/<project>:<version> <test-command>
   ```
4. **Push to registry**:
   ```bash
   podman push git.shadyknollcave.io/micro/<project>:<version>
   ```
5. **Update Kubernetes manifests** with new image tag
6. **ArgoCD will auto-sync** changes to cluster

**Assumptions:**
- Use VERSION file if present
- Tag format: `v1.0.0` (with 'v' prefix)
- Always push to git.shadyknollcave.io registry
- Update image tag in kustomization.yaml or deployment.yaml

## Git Commit & Push Workflow

**Trigger**: User says "commit", "save changes", or work is complete

**Process:**
1. **Stage changes**: `git add <files>`
2. **Create commit** with conventional commit format:
   ```bash
   git commit -m "<type>: <description>

   <optional detailed description>

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```
3. **Push to both remotes**:
   ```bash
   git push origin main
   git push backup main
   ```

**Conventional Commit Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `breaking`: Breaking changes (triggers MAJOR version bump)

# Kubernetes Configuration

## Cilium CNI & Networking

### Installation & Configuration
- **Helm Values**: `/home/micro/development/k3s-homelab-config/cilium/values.yaml`
- **Version**: v1.18.6

### Key Features
- **BGP Control Plane**: Enabled for external route advertisement
- **Ingress Controller**: Built-in (replaces Traefik/Ingress-Nginx)
- **LoadBalancer Mode**: Shared (single IP for all services)
- **kube-proxy Replacement**: Enabled (pure eBPF)
- **Hubble**: Network observability with UI
- **IPAM**: Cluster pool mode (automatic pod IP management)
- **Tunneling**: Disabled (native routing for better performance)

### LoadBalancer IP Pool
- **Config File**: `/home/micro/development/k3s-homelab-config/manifests/cilium/lb-ip-pool.yaml`
- **Range**: 10.10.10.200/29 (8 IPs: 10.10.10.200 - 10.10.10.207)
- **Annotation**: `io.cilium/lb-ipam: main-pool`
- **Usage**: All LoadBalancer-type services automatically get IPs from this pool

### BGP Configuration
- **Config File**: `/home/micro/development/k3s-homelab-config/manifests/cilium/bgp-cluster-config.yaml`
- **Cluster AS**: 65001
- **Router AS**: 65000 (UniFi Dream Machine Pro)
- **Router IP**: 10.10.10.1
- **Multihop TTL**: 1 (eBGP multihop enabled)
- **Advertised Routes**:
  - LoadBalancer IP Pool: 10.10.10.200/29
  - Pod CIDR: 10.42.0.0/16

### Verification Commands
```bash
# Check Cilium status
cilium status
cilium connectivity test

# Check BGP peers
cilium bgp peers

# Check LoadBalancer IPs
kubectl get svc -A | grep LoadBalancer

# Verify routes
ip route | grep 10.10.10.20
```

## cert-manager & TLS Automation

### Installation
- **Helm Chart**: jetstack/cert-manager v1.19.2
- **CRDs**: Installed with chart

### ClusterIssuers

#### Production Issuer
- **Config File**: `/home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-production.yaml`
- **Server**: Let's Encrypt Production (acme-v02.api.letsencrypt.org)
- **Email**: microreal@shadyknollcave.io
- **Challenges**:
  - HTTP-01: Standard certificates (via Cilium Ingress)
  - DNS-01: Wildcard certificates (via Route53)
- **Route53 Zone**: Z1TUW8YIHHEO9X (shadyknollcave.io)
- **Region**: us-east-1

#### Staging Issuer
- **Config File**: `/home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-staging.yaml`
- **Server**: Let's Encrypt Staging (for testing, avoids rate limits)
- **Same configuration** as production

### AWS IAM Requirements
For Route53 DNS-01 challenges, the AWS credentials secret requires:
```json
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
```

### Certificate Management
- **Auto-renewal**: 30 days before expiry
- **Monitoring**: `kubectl get certificate -A`
- **Troubleshooting**: `kubectl logs -n cert-manager -l app=cert-manager`

## Ingress Configuration

### Cilium Ingress (External/Public)

**Characteristics:**
- **IngressClass**: `cilium`
- **Shared IP**: 10.10.10.200 (SNI-based routing)
- **TLS Termination**: Handled by Cilium Ingress
- **Certificate**: Let's Encrypt (automatic via cert-manager)

**Manifest Template:**
```yaml
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
```

### Ingress-Nginx Local (Internal)

**Characteristics:**
- **IngressClass**: `nginx-local`
- **Dedicated IP**: 10.10.10.210
- **TLS**: Self-signed certificates (via cert-manager selfsigned-issuer)
- **Use Case**: Internal services, admin interfaces, dev/test environments

**Manifest Template:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-name-internal
  namespace: app-namespace
  annotations:
    cert-manager.io/cluster-issuer: selfsigned-issuer
spec:
  ingressClassName: nginx-local
  tls:
  - hosts:
    - app-name-internal.shadyknollcave.io
    secretName: app-name-internal-tls
  rules:
  - host: app-name-internal.shadyknollcave.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

### Network Flow (External Access)
```
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
```

### Currently Deployed Applications
- Rancher: rancher.shadyknollcave.io
- ArgoCD: argocd.shadyknollcave.io
- Gitea: git.shadyknollcave.io
- Grafana: grafana.shadyknollcave.io
- Hubble UI: hubble.shadyknollcave.io

## K3s Configuration

### Server Config
**File**: `/etc/rancher/k3s/config.yaml`

```yaml
disable:
  - traefik          # Replaced by Cilium Ingress
  - servicelb        # Replaced by Cilium LoadBalancer
  - flannel          # Replaced by Cilium CNI
cluster-cidr: 10.42.0.0/16
service-cidr: 10.43.0.0/16
```

### Network CIDRs
- **Pod CIDR**: 10.42.0.0/16 (managed by Cilium IPAM)
- **Service CIDR**: 10.43.0.0/16 (ClusterIP services)
- **LoadBalancer IPs**: 10.10.10.200/29 (external access)

## Verification & Troubleshooting

### Verification Commands
```bash
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
```

### Troubleshooting Certificate Issues
```bash
# Check certificate request status
kubectl describe certificaterequest -n <namespace> <request-name>

# Check challenge status
kubectl get challenges -A

# View cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager
```

### Troubleshooting Ingress Issues
```bash
# Check Cilium ingress logs
kubectl logs -n kube-system -l k8s-app=cilium | grep ingress

# Verify LoadBalancer IP assigned
kubectl get svc -n <namespace> <service-name>

# Test DNS resolution
nslookup appname.shadyknollcave.io

# Check port forwarding on UDM Pro
# Verify WAN:443 → 10.10.10.200:443
```

### Troubleshooting BGP Issues
```bash
# Verify BGP session established
cilium bgp peers

# Check advertised routes
cilium bgp routes

# Verify route propagation on UDM Pro
# Log into UDM Pro → Settings → Routing → BGP Routes
```

## Key File Locations

### Cilium Configuration
- **Helm Values**: `/home/micro/development/k3s-homelab-config/cilium/values.yaml`
- **LoadBalancer Pool**: `/home/micro/development/k3s-homelab-config/manifests/cilium/lb-ip-pool.yaml`
- **BGP Config**: `/home/micro/development/k3s-homelab-config/manifests/cilium/bgp-cluster-config.yaml`

### cert-manager Configuration
- **Production Issuer**: `/home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-production.yaml`
- **Staging Issuer**: `/home/micro/development/k3s-homelab-config/manifests/cert-manager/cluster-issuer-staging.yaml`

### Example Manifests
- **Sample Ingress**: `/home/micro/development/k3s-homelab-config/manifests/apps/sample-ingress.yaml`

# Standards & Conventions

## Versioning [REQUIRED]
- **Semantic Versioning**: MAJOR.MINOR.PATCH (e.g., v1.0.0)
- **Git Tags**: Create annotated tags on releases
- **Changelog**: Maintain CHANGELOG.md using conventional commits
- **Tag Format**: `v1.0.0` (with 'v' prefix)

## Git Workflow [REQUIRED]

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - Feature branches

### Repository Configuration [REQUIRED]
- **Primary**: git.shadyknollcave.io (origin)
- **Backup**: github.com (backup)
- **Push to both**: On every commit

### Commit Conventions [REQUIRED]
Use conventional commit prefixes:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `chore:` Maintenance
- `breaking:` Breaking changes (triggers MAJOR version bump)

## Project Structure [REQUIRED]

Every new project must include:

### Documentation [REQUIRED]
- **README.md**:
  - Project description
  - Prerequisites
  - Installation/deployment instructions
  - Usage examples
  - Development setup
- **CHANGELOG.md**: Auto-generated from commits
- **LICENSE**: Appropriate license (MIT recommended)

### Build & Automation [REQUIRED]
- **Makefile**: Common tasks (build, test, deploy)
- **Containerfile** (not Dockerfile): Container image definition
- **VERSION file**: Current semantic version

### Configuration [REQUIRED]
- **.env.template**: Environment variable template
- **.gitignore**: Appropriate for language/framework

### Kubernetes Manifests [REQUIRED]
Structure in `k8s/` directory:
```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── kustomization.yaml
│   └── application.yaml  # ArgoCD Application manifest
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

**Manifest Requirements:**
- Use Kustomize overlays (base, dev, prod)
- Include resource requests/limits
- Add ArgoCD Application manifests
- Use Sealed Secrets for sensitive data

## Coding Standards

### Languages
- **Python**: Primary scripting/backend language
- **Node.js**: JavaScript/TypeScript applications
- **Shell**: Bash scripts for automation

### Formatting & Linting [REQUIRED]
- **Python**: black, pylint/flake8
- **Node.js**: prettier, eslint
- **YAML**: yamllint

### Documentation [REQUIRED]
- Comprehensive README.md for every project
- Inline code comments for complex logic
- API documentation where applicable

## Security Standards [REQUIRED]

### Secrets Management
- **Tool**: Sealed Secrets with kubeseal
- **Rule**: Never commit plain secrets
- **Process**: Generate sealed secrets for K8s deployments

### PKI & Air-Gap
- **PKI-aware configurations**: Use certificate-based auth
- **Air-gap compatible**: Prefer offline-compatible solutions
- **Container images**: From trusted sources or self-built

### Access Control
- **Principle of least privilege**: Minimal permissions
- **Role-based access**: Separate roles for different environments
- **Audit logging**: Enable logging for security-relevant events

# Reference Material

## Standard Ingress Templates

### External Application (Cilium Ingress)
```yaml
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
```

### Internal Application (Nginx Ingress)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-name-internal
  namespace: app-namespace
  annotations:
    cert-manager.io/cluster-issuer: selfsigned-issuer
spec:
  ingressClassName: nginx-local
  tls:
  - hosts:
    - app-name-internal.shadyknollcave.io
    secretName: app-name-internal-tls
  rules:
  - host: app-name-internal.shadyknollcave.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

## Project Directory Template

```
project-name/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── VERSION
├── Makefile
├── .env.template
├── .gitignore
├── Containerfile
├── src/
│   ├── main.py
│   └── requirements.txt
├── k8s/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── kustomization.yaml
│   │   └── application.yaml
│   └── overlays/
│       ├── dev/
│       │   └── kustomization.yaml
│       └── prod/
│           └── kustomization.yaml
└── tests/
    ├── test_main.py
    └── pytest.ini
```

## Makefile Template

```makefile
VERSION := $(shell cat VERSION)
PROJECT := project-name
REGISTRY := git.shadyknollcave.io/micro
IMAGE := $(REGISTRY)/$(PROJECT):$(VERSION)

.PHONY: build test push deploy clean

build:
	podman build -t $(IMAGE) .

test:
	python3 -m pytest tests/

push:
	podman push $(IMAGE)

deploy: build push
	kubectl apply -k k8s/overlays/prod

clean:
	podman rmi $(IMAGE) || true
```

# Metadata

## Prompt Information
- **Version**: 2.0.0
- **Last Updated**: 2025-02-07
- **Maintained By**: Pedro Fernandez (microreal@shadyknollcave.io)
- **Purpose**: Global instructions for Claude Code in homelab K3s environment

## Changelog
- **v2.0.0** (2025-02-07): Restructured with behavioral directives, clarified workflows, consolidated duplicate information
- **v1.0.0**: Initial version

## Usage Notes
- This prompt applies to all development tasks in this environment
- Claude can read referenced config files when needed (k3s-homelab-config/)
- Prefer following these conventions over general best practices
- When in doubt, ask the user for clarification
