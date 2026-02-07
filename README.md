# Claude Code Configuration

Personal configuration repository for [Claude Code](https://claude.com/claude-code) - Anthropic's official CLI for Claude. This repository stores configuration files and custom instructions to optimize AI-assisted development in a homelab Kubernetes environment.

## Overview

This repository contains my personalized Claude Code setup, including:
- Developer profile and environment specifications
- Tool permissions and security policies
- Git workflow automation (Gitea + GitHub dual-remote)
- Kubernetes cluster context (K3s with Cilium, ArgoCD, cert-manager)
- MCP (Model Context Protocol) server configurations
- Custom hooks for workflow automation

## Prerequisites

- [Claude Code CLI](https://claude.com/claude-code) installed
- Homelab K3s cluster (or similar Kubernetes environment)
- Git with Gitea (`tea`) and GitHub (`gh`) CLIs
- Container tools: Podman (not Docker)
- Kubernetes tools: kubectl, kustomize, kubeseal

## Installation

### 1. Clone the Repository

```bash
git clone https://git.shadyknollcave.io/micro/Claude_Code_Configuration.git ~/development/Claude_Code_Configuration
cd ~/development/Claude_Code_Configuration
```

### 2. Symlink Configuration Files

```bash
# Link CLAUDE.md to global config location
ln -s ~/development/Claude_Code_Configuration/CLAUDE.md ~/.claude/CLAUDE.md

# Link settings.json (optional - customize first)
cp ~/development/Claude_Code_Configuration/settings.json ~/.claude/settings.json
```

### 3. Customize settings.json

Edit `~/.claude/settings.json` to update:
- **GITHUB_TOKEN**: Add your GitHub personal access token
- **Permissions**: Review allow/deny/ask lists for your environment
- **MCP Servers**: Enable/disable servers as needed

### 4. Verify Configuration

```bash
# Check Claude Code configuration
claude --version

# View active configuration
cat ~/.claude/settings.json
cat ~/.claude/CLAUDE.md
```

## Usage

### Claude Code Commands

Start a Claude Code session in any project directory:

```bash
cd ~/development/your-project
claude
```

### Custom Configuration Features

#### Developer Profile
- **Name**: Pedro Fernandez
- **Email**: microreal@shadyknollcave.io
- **Environment**: Air-gapped/PKI-protected networks, homelab K3s cluster

#### Automated Git Workflow

The configuration includes automatic repository creation and management:

```bash
# Claude Code will automatically:
# 1. Check if repo exists on Gitea (tea repo list)
# 2. Create repo if missing (tea repo create)
# 3. Check if backup exists on GitHub (gh repo list)
# 4. Create backup if missing (gh repo create)
# 5. Configure both remotes (origin + backup)
# 6. Push to both remotes on every commit
```

#### Kubernetes Context

Full K3s cluster context is provided to Claude Code, including:
- **Cluster**: Rancher K3s v1.34.3+k3s1 (3x Beelink SER9 Max nodes)
- **CNI**: Cilium v1.18.6 with eBPF and BGP
- **Ingress**: Dual controllers (Cilium external + Nginx internal)
- **TLS**: cert-manager v1.19.2 with Let's Encrypt automation
- **GitOps**: ArgoCD for continuous deployment

#### Tool Permissions

Pre-configured permission model for balanced security and productivity:

**Allowed Tools** (auto-executed):
- Read operations: ls, cat, grep, find, tree
- Git read-only: status, diff, log, branch, show
- GitHub read-only: auth status, repo view, issue/pr list
- Development tools: pytest, black, flake8, yamllint
- Container inspection: podman ps, logs, inspect

**Denied Tools** (blocked):
- Destructive operations: rm, dd, mkfs, fdisk
- System commands: shutdown, reboot, halt
- Secret reading: .env*, secrets/, *.key, *.pem

**Ask Confirmation** (user approval required):
- Git writes: commit, push, reset, merge, rebase
- GitHub writes: issue/pr create, close, edit
- Package management: npm install, pip install
- File modifications: Write operations

## Project Structure

```
Claude_Code_Configuration/
├── README.md           # This file
├── CLAUDE.md          # Global instructions for Claude Code
└── settings.json      # Claude Code configuration (permissions, MCP, hooks)
```

## Configuration Components

### CLAUDE.md

Contains comprehensive developer context including:
- Available CLI tools and usage
- Git workflow and repository management
- Kubernetes cluster configuration
- Container registry and secrets management
- Coding standards and project preferences
- Security requirements

### settings.json

#### Permissions
- **allow**: Tools Claude can execute automatically
- **deny**: Dangerous tools that are blocked
- **ask**: Tools requiring user confirmation

#### MCP Servers
- **filesystem**: File system access (`~/development`)
- **git**: Git repository operations
- **github**: GitHub API integration (disabled by default)

#### Hooks
- **PostToolUse**: Executes commands after Edit/Write operations
- Example: Logs file modification timestamps

## Development Setup

### Making Changes

1. Edit configuration files in this repository
2. Test changes in Claude Code session
3. Commit and push to both remotes:

```bash
git add .
git commit -m "feat: update Claude Code configuration"
git push origin main
git push backup main
```

### Updating Configuration

After pulling changes:

```bash
cd ~/development/Claude_Code_Configuration
git pull origin main
git pull backup main

# Re-link if needed
ln -sf ~/development/Claude_Code_Configuration/CLAUDE.md ~/.claude/CLAUDE.md
```

## Troubleshooting

### Claude Code Not Using Configuration

```bash
# Verify config file locations
ls -la ~/.claude/

# Check for syntax errors in JSON
jq . ~/.claude/settings.json

# Restart Claude Code session
exit
claude
```

### MCP Servers Not Starting

```bash
# Check Node.js and npm are installed
node --version
npm --version

# Test MCP server manually
npx -y @modelcontextprotocol/server-filesystem ~/development
```

### Permissions Too Restrictive/Lenient

Edit `settings.json` and adjust the `permissions` section:
- Add commands to `allow` for auto-execution
- Add dangerous commands to `deny` for blocking
- Move commands from `allow` to `ask` for confirmation

## Kubernetes Cluster Information

The configuration includes detailed context for the homelab K3s cluster:

### Network Configuration
- **VLAN**: 10 (10.10.10.0/24)
- **Pod CIDR**: 10.42.0.0/16
- **Service CIDR**: 10.43.0.0/16
- **LoadBalancer IPs**: 10.10.10.200/29

### Ingress Controllers
- **Cilium** (ingressClassName: `cilium`): External/public access
  - Shared IP: 10.10.10.200
  - BGP-advertised to UDM Pro
  - Let's Encrypt TLS certificates
- **Nginx Local** (ingressClassName: `nginx-local`): Internal access
  - Dedicated IP: 10.10.10.210
  - Self-signed certificates

### Key Services
- Rancher: rancher.shadyknollcave.io
- ArgoCD: argocd.shadyknollcave.io
- Gitea: git.shadyknollcave.io
- Grafana: grafana.shadyknollcave.io
- Hubble UI: hubble.shadyknollcave.io

## Contributing

This is a personal configuration repository, but suggestions and improvements are welcome! Feel free to open issues or submit pull requests.

## License

This configuration is provided as-is for personal use. Adapt and modify for your own environment.

## Author

**Pedro Fernandez**
- Email: microreal@shadyknollcave.io
- Git: https://git.shadyknollcave.io/micro
- GitHub: https://github.com/pedrof

## Version

Version 1.0.0 - Initial configuration setup

---

*Generated with [Claude Code](https://claude.com/claude-code)*
