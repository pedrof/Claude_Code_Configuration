# Homelab Development Tools Installation Guide

This guide explains how to use the automated installation script for setting up all CLI tools required for development in the homelab K3s environment.

## Quick Start

```bash
# Clone or navigate to the configuration directory
cd ~/development/Claude_Code_Configuration

# Run the installation script
./install-tools-ubuntu24.sh
```

## What Gets Installed

The script installs all CLI tools documented in `CLAUDE.md`:

### Kubernetes & Container Tools
- **kubectl** - Kubernetes command-line tool
- **kubeseal** - Sealed Secrets encryption utility
- **kustomize** - Kubernetes manifest customization
- **podman** - Container management (daemonless Docker alternative)
- **cilium-cli** - Cilium CNI management tool

### Git & Repository Management
- **git** - Version control system
- **tea** - Gitea CLI for git.shadyknollcave.io operations
- **gh** - GitHub CLI for github.com backup repositories

### Development Tools
- **python3 / pip** - Python development
- **node / npm** - Node.js development
- **jq** - JSON processor
- **yq** - YAML processor

### Code Formatting & Linting
- **black** - Python code formatter
- **pylint** - Python linter
- **flake8** - Python style checker
- **prettier** - JavaScript/TypeScript formatter
- **eslint** - JavaScript/TypeScript linter
- **yamllint** - YAML linter

### Additional Tools
- **bat** - Enhanced cat
- **exa** - Enhanced ls
- **fd** - Enhanced find
- **ripgrep** - Fast grep
- **htop** - Interactive process viewer
- **neovim** - Enhanced vim
- **tmux** - Terminal multiplexer
- **tree** - Directory tree viewer

### AI-Optimized Tools [HIGHLY RECOMMENDED]
- **k9s** - Kubernetes Terminal UI (visual cluster state, easier than kubectl)
- **fzf** - Fuzzy finder (fast file/command/branch navigation)
- **tree-sitter** - Code parsing into ASTs (Claude uses this internally)
- **tokei** - Code statistics (understand codebase composition/complexity)
- **lazygit** - Git Terminal UI (visual repo history, intuitive navigation)
- **kube-score** - Kubernetes linter (automatic best practices checking)
- **just** - Command runner (better than Makefile for agent-executed commands)
- **dive** - Docker image analyzer (inspect container layers efficiently)
- **ollama** - Local LLM runner (offline AI development, test prompts locally)
- **shellcheck** - Shell script linter (improve automation reliability)

## Requirements

- **OS**: Ubuntu 24.04 (Noble Numbat)
- **Privileges**: sudo access (for package installation)
- **Network**: Internet connection (for downloading packages)

## Installation Steps

### 1. Prepare Your System

Ensure your system is up to date:

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Run the Installation Script

```bash
cd ~/development/Claude_Code_Configuration
chmod +x install-tools-ubuntu24.sh
./install-tools-ubuntu24.sh
```

The script will:
- Check if tools are already installed (skips if present)
- Download and install each tool
- Provide color-coded output for progress tracking
- Verify installations at the end

### 3. Configure Git

Set up your git identity:

```bash
git config --global user.name "Pedro Fernandez"
git config --global user.email "microreal@shadyknollcave.io"
git config --global init.defaultBranch main
git config --global core.autocrlf input
```

### 4. Authenticate with Git Hosts

**Gitea (git.shadyknollcave.io):**
```bash
tea login add
# Follow prompts to enter your Gitea credentials
```

**GitHub (github.com):**
```bash
gh auth login
# Follow prompts to authenticate with GitHub
```

### 5. Configure kubectl (if needed)

If you have K3s cluster access:

```bash
mkdir -p ~/.kube
# Copy your kubeconfig file to ~/.kube/config
# Or export KUBECONFIG=/path/to/your/kubeconfig
```

Verify connection:
```bash
kubectl get nodes
```

## Post-Installation Verification

Check that all tools are installed:

```bash
# Kubernetes tools
kubectl version --client
kubeseal --version
kustomize version
podman --version
cilium version

# Git tools
git --version
tea --version
gh --version

# Development tools
python3 --version
pip3 --version
node --version
npm --version
jq --version
yq --version

# Code quality tools
black --version
pylint --version
flake8 --version
prettier --version
eslint --version
yamllint --version

# AI-optimized tools
k9s version
fzf --version
tree-sitter --version
tokei --version
lazygit --version
kube-score version
just --version
dive --version
ollama --version
shellcheck --version
```

## Troubleshooting

### Script Permission Denied

```bash
chmod +x install-tools-ubuntu24.sh
```

### Package Not Found

Ensure you're running Ubuntu 24.04:

```bash
lsb_release -a
```

### Gitea CLI (tea) Login Issues

Make sure your Gitea instance is accessible:

```bash
ping git.shadyknollcave.io
curl https://git.shadyknollcave.io
```

### GitHub CLI (gh) Authentication

If you encounter issues, try web browser authentication:

```bash
gh auth login --web
```

### kubectl Connection Issues

Verify your kubeconfig:

```bash
echo $KUBECONFIG
ls -la ~/.kube/config
kubectl cluster-info
```

### Python Tools in System Packages

The script uses `--break-system-packages` flag for pip3. If you prefer a cleaner setup:

```bash
python3 -m venv ~/.venv
source ~/.venv/bin/activate
pip install black pylint flake8
```

## Manual Installation (Alternative)

If the script fails, you can install tools manually:

### kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### kubeseal
```bash
KUBESEAL_VERSION="0.24.0"
curl -LO "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/
```

### kustomize
```bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/
```

### podman
```bash
sudo apt install -y podman
```

### tea (Gitea CLI)
```bash
TEA_VERSION="0.9.0"
curl -L "https://dl.gitea.io/tea/${TEA_VERSION}/tea-${TEA_VERSION}-linux-amd64" -o tea
chmod +x tea
sudo mv tea /usr/local/bin/
```

### gh (GitHub CLI)
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
```

### Node.js & npm
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### Python tools
```bash
sudo pip3 install --break-system-packages black pylint flake8 yamllint
```

### Node.js tools
```bash
sudo npm install -g prettier eslint
```

### yq
```bash
YQ_VERSION="v4.40.5"
wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O yq
chmod +x yq
sudo mv yq /usr/local/bin/
```

### jq, yamllint
```bash
sudo apt install -y jq yamllint
```

### AI-Optimized Tools

#### k9s (Kubernetes Terminal UI)
```bash
K9S_VERSION="v0.32.5"
curl -sSLO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf k9s_Linux_amd64.tar.gz
sudo install -m 755 k9s /usr/local/bin/
rm -f k9s_Linux_amd64.tar.gz LICENSE.md
```

#### fzf (Fuzzy Finder)
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all --no-bash --no-zsh
sudo cp ~/.fzf/bin/fzf /usr/local/bin/
```

#### tree-sitter (Code Parser)
```bash
sudo apt install -y tree-sitter-cli
```

#### tokei (Code Statistics)
```bash
TOKEI_VERSION="v12.7.3"
curl -sSLO "https://github.com/XAMPPRocky/tokei/releases/download/${TOKEI_VERSION}/tokei-${TOKEI_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf tokei-${TOKEI_VERSION}-x86_64-unknown-linux-gnu.tar.gz
sudo mv tokei /usr/local/bin/
rm -f tokei-${TOKEI_VERSION}-x86_64-unknown-linux-gnu.tar.gz
```

#### lazygit (Git Terminal UI)
```bash
LAZYGIT_VERSION="v0.44.1"
curl -sSLO "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xzf lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
sudo mv lazygit /usr/local/bin/
rm -f lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz LICENSE
```

#### kube-score (Kubernetes Linter)
```bash
KUBE_SCORE_VERSION="v1.19.0"
curl -sSLO "https://github.com/zegl/kube-score/releases/download/${KUBE_SCORE_VERSION}/kube-score_${KUBE_SCORE_VERSION}_linux_amd64"
chmod +x kube-score_${KUBE_SCORE_VERSION}_linux_amd64
sudo mv kube-score_${KUBE_SCORE_VERSION}_linux_amd64 /usr/local/bin/kube-score
```

#### just (Command Runner)
```bash
JUST_VERSION="1.33.0"
curl -sSLO "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar -xzf just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz
sudo mv just /usr/local/bin/
rm -f just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz
```

#### dive (Docker Image Analyzer)
```bash
DIVE_VERSION="v0.12.0"
wget https://github.com/wagoodman/dive/releases/download/${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.tar.gz
tar -xzf dive_${DIVE_VERSION}_linux_amd64.tar.gz
sudo mv dive /usr/local/bin/
rm -f dive_${DIVE_VERSION}_linux_amd64.tar.gz
```

#### ollama (Local LLM Runner)
```bash
curl -fsSL https://ollama.com/install.sh | sh
# Start ollama service
ollama serve
# Pull a model (optional)
ollama pull codellama
```

#### shellcheck (Shell Script Linter)
```bash
sudo apt install -y shellcheck
```

## Updating Tools

To update installed tools:

```bash
# System packages
sudo apt update && sudo apt upgrade -y

# Python tools
sudo pip3 install --upgrade --break-system-packages black pylint flake8 yamllint

# Node.js tools
sudo npm update -g prettier eslint

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# tea (Gitea CLI)
TEA_VERSION="0.9.0"  # Check for latest version
curl -L "https://dl.gitea.io/tea/${TEA_VERSION}/tea-${TEA_VERSION}-linux-amd64" -o tea
chmod +x tea
sudo mv tea /usr/local/bin/

# AI-optimized tools
# Update k9s
K9S_VERSION="v0.32.5"  # Check for latest version
curl -sSLO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf k9s_Linux_amd64.tar.gz
sudo install -m 755 k9s /usr/local/bin/

# Update tokei
TOKEI_VERSION="v12.7.3"  # Check for latest version
curl -sSLO "https://github.com/XAMPPRocky/tokei/releases/download/${TOKEI_VERSION}/tokei-${TOKEI_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf tokei-${TOKEI_VERSION}-x86_64-unknown-linux-gnu.tar.gz
sudo mv tokei /usr/local/bin/

# Update lazygit
LAZYGIT_VERSION="v0.44.1"  # Check for latest version
curl -sSLO "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xzf lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
sudo mv lazygit /usr/local/bin/

# Update kube-score
KUBE_SCORE_VERSION="v1.19.0"  # Check for latest version
curl -sSLO "https://github.com/zegl/kube-score/releases/download/${KUBE_SCORE_VERSION}/kube-score_${KUBE_SCORE_VERSION}_linux_amd64"
chmod +x kube-score_${KUBE_SCORE_VERSION}_linux_amd64
sudo mv kube-score_${KUBE_SCORE_VERSION}_linux_amd64 /usr/local/bin/kube-score

# Update just
JUST_VERSION="1.33.0"  # Check for latest version
curl -sSLO "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar -xzf just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz
sudo mv just /usr/local/bin/

# Update dive
DIVE_VERSION="v0.12.0"  # Check for latest version
wget https://github.com/wagoodman/dive/releases/download/${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.tar.gz
tar -xzf dive_${DIVE_VERSION}_linux_amd64.tar.gz
sudo mv dive /usr/local/bin/

# Update ollama (uses its own update mechanism)
ollama --version  # Check version
# ollama automatically updates when you run it
```

## Uninstallation

To remove installed tools:

```bash
# WARNING: This will remove all installed packages
sudo apt remove --purge -y \
    kubectl kubeseal kustomize podman \
    git tea gh \
    python3 python3-pip nodejs npm \
    jq yq yamllint tree-sitter-cli shellcheck

# Remove Python packages
sudo pip3 uninstall --break-system-packages -y black pylint flake8

# Remove Node.js packages
sudo npm uninstall -g prettier eslint

# Remove manual installations (Kubernetes tools)
sudo rm -f /usr/local/bin/kubectl /usr/local/bin/kubeseal /usr/local/bin/kustomize /usr/local/bin/tea /usr/local/bin/yq /usr/local/bin/cilium

# Remove AI-optimized tools
sudo rm -f /usr/local/bin/k9s /usr/local/bin/fzf /usr/local/bin/tokei /usr/local/bin/lazygit /usr/local/bin/kube-score /usr/local/bin/just /usr/local/bin/dive /usr/local/bin/tree-sitter

# Remove ollama
ollama stop 2>/dev/null || true
sudo systemctl disable ollama 2>/dev/null || true
sudo rm -rf /usr/local/bin/ollama /usr/share/ollama ~/.ollama

# Remove fzf directory
rm -rf ~/.fzf
```

## Contributing

If you find issues with the installation script or have suggestions for improvements:

1. Check the script: `install-tools-ubuntu24.sh`
2. Review the documentation: `CLAUDE.md`
3. Update the script with improvements
4. Submit changes to the repository

## License

This installation script is part of the Claude Code Configuration repository and follows the same license.

## Author

**Pedro Fernandez** - microreal@shadyknollcave.io

## Version

- **Script Version**: 1.0.0
- **Last Updated**: 2025-02-07
- **Compatible With**: Ubuntu 24.04 (Noble Numbat)

---

*For more information about the development environment and tool usage, see [CLAUDE.md](CLAUDE.md)*
