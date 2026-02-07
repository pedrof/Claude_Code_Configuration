# macOS Development Tools Installation Guide

This guide explains how to use the automated installation script for setting up all CLI tools required for development in the homelab K3s environment on macOS.

## Quick Start

```bash
# Clone or navigate to the configuration directory
cd ~/development/Claude_Code_Configuration

# Run the installation script
./install-tools-macos.sh
```

## Requirements

- **OS**: macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)
- **Architecture**: Intel (x86_64) or Apple Silicon (M1/M2/M3/M4 - arm64)
- **Privileges**: Administrator access (for installing packages)
- **Network**: Internet connection (for downloading packages)

## What Gets Installed

The script installs all CLI tools documented in `CLAUDE.md` using Homebrew:

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
- **python3 / pip3** - Python development
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
- **eza** - Enhanced ls (replacement for exa)
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

## Installation Steps

### 1. Prepare Your Mac

Ensure your system is up to date:

```bash
# Check for macOS updates
sudo softwareupdate --install --all

# Restart if required
```

### 2. Run the Installation Script

```bash
cd ~/development/Claude_Code_Configuration
chmod +x install-tools-macos.sh
./install-tools-macos.sh
```

The script will:
- **Check macOS version** (requires 12+)
- **Detect architecture** (Intel vs Apple Silicon)
- **Install Xcode Command Line Tools** (if not present)
- **Install Homebrew** (if not present)
- **Install Rosetta 2** (on Apple Silicon, for Intel compatibility)
- **Install all development tools** via Homebrew
- **Configure shell environment** automatically
- **Verify installations** at the end

### 3. Restart Your Shell

After installation, restart your shell to load new environment variables:

```bash
# For zsh (default on modern macOS)
source ~/.zprofile

# For bash
source ~/.bash_profile
```

Or close and reopen Terminal.

### 4. Configure Git

Set up your git identity:

```bash
git config --global user.name "Pedro Fernandez"
git config --global user.email "microreal@shadyknollcave.io"
git config --global init.defaultBranch main
```

### 5. Authenticate with Git Hosts

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

### 6. Initialize Podman (Optional)

If you're using Podman for containers:

```bash
# Initialize podman machine (creates VM)
podman machine init

# Start the podman machine
podman machine start

# Verify
podman info
```

### 7. Configure kubectl (if needed)

If you have K3s cluster access:

```bash
# Create .kube directory
mkdir -p ~/.kube

# Copy your kubeconfig file
#scp user@k3s-server:/etc/rancher/k3s/k3s.yaml ~/.kube/config

# Or export KUBECONFIG
export KUBECONFIG=/path/to/your/kubeconfig
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

## macOS-Specific Considerations

### Apple Silicon (M1/M2/M3/M4)

The script automatically:
- Detects Apple Silicon architecture
- Installs Rosetta 2 for Intel compatibility
- Configures Homebrew for `/opt/homebrew` (ARM64)
- Sets up proper shell environment

### Intel Macs

The script will:
- Detect Intel x86_64 architecture
- Use `/usr/local/bin` for Homebrew (Intel)
- Skip Rosetta 2 installation

### Xcode Command Line Tools

The script will prompt you to install Xcode Command Line Tools if not present:

```bash
xcode-select --install
```

Complete the installation, then run the script again.

### Homebrew Location

- **Apple Silicon**: `/opt/homebrew/bin/brew`
- **Intel**: `/usr/local/bin/brew`

The script automatically configures your shell (`.zprofile` or `.bash_profile`) to add Homebrew to PATH.

## Troubleshooting

### Script Permission Denied

```bash
chmod +x install-tools-macos.sh
```

### Command Not Found After Installation

Restart your shell or source your profile:

```bash
# zsh
source ~/.zprofile

# bash
source ~/.bash_profile
```

### Homebrew Not Found

Manually install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-install instructions displayed by the installer.

### Podman Machine Issues

On Apple Silicon, Podman runs in a VM:

```bash
# Initialize VM
podman machine init

# Start VM
podman machine start

# Check status
podman machine ls

# Connect to VM console
podman machine ssh
```

### Python Tools Not in PATH

Python tools installed via `pip3 --user` are in `~/Library/Python/3.x/bin/`. Add to PATH:

```bash
# For zsh
echo 'export PATH="$HOME/Library/Python/3.13/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For bash
echo 'export PATH="$HOME/Library/Python/3.13/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

### Gitea CLI (tea) Login Issues

Make sure your Gitea instance is accessible:

```bash
ping git.shadyknollcave.io
curl https://git.shadyknollcave.io
```

If using custom CA certificates:

```bash
# Configure tea to skip TLS verification (not recommended for production)
tea login add --insecure-skip-tls-verify
```

### GitHub CLI (gh) Authentication

If you encounter issues, try web browser authentication:

```bash
gh auth login --web
```

## Manual Installation (Alternative)

If the script fails, you can install tools manually via Homebrew:

### Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install Core Tools

```bash
# Kubernetes tools
brew install kubectl kubeseal kustomize podman cilium

# Git tools
brew install git
brew tap gitea/tap https://git.shadyknollcave.io/gitea/homebrew-gitea.git
brew install tea
brew install gh

# Development tools
brew install python@3 node jq yq

# Code quality tools
pip3 install --user black pylint flake8 yamllint
npm install -g prettier eslint

# Additional tools
brew install bat eza fd ripgrep htop neovim tmux tree

# AI-optimized tools
brew install k9s fzf tree-sitter tokei lazygit kube-score just dive ollama shellcheck
```

## Updating Tools

To update installed tools:

```bash
# Update Homebrew and all packages
brew update
brew upgrade

# Update Python packages
pip3 install --upgrade --user black pylint flake8 yamllint

# Update Node.js packages
npm update -g prettier eslint

# Note: All AI-optimized tools (k9s, fzf, tree-sitter, tokei, lazygit,
# kube-score, just, dive, ollama, shellcheck) are managed by Homebrew
# and are automatically updated when you run `brew upgrade`
```

## Uninstallation

To remove installed tools:

```bash
# Uninstall via Homebrew
brew uninstall --force \
    kubectl kubeseal kustomize podman cilium \
    git tea gh \
    python@3 node jq yq \
    bat eza fd ripgrep htop neovim tmux tree \
    k9s fzf tree-sitter tokei lazygit kube-score just dive ollama shellcheck

# Remove Python packages
pip3 uninstall -y black pylint flake8 yamllint

# Remove Node.js packages
npm uninstall -g prettier eslint

# Uninstall Homebrew (optional)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

## Security Considerations

### Xcode Command Line Tools

These require administrator privileges and are signed by Apple:

```bash
# Verify installation
xcode-select -p
```

### Homebrew Security

Homebrew verifies all packages via SHA256 checksums and HTTPS:

```bash
# Audit Homebrew installation
brew audit --strict
```

### Podman VM

Podman runs in a lightweight VM on macOS:

```bash
# Check VM status
podman machine ls

# Stop VM when not needed
podman machine stop
```

## Performance Tips

### Apple Silicon Optimization

- Use ARM64-native versions of all tools (automatic via Homebrew)
- Rosetta 2 runs Intel tools with minimal performance penalty

### Homebrew Bottles

Homebrew downloads precompiled binaries (bottles) for faster installation:

```bash
# Check bottle status
brew info --json=v2 --installed | jq '.formulae[].bottle.stable'
```

## Contributing

If you find issues with the installation script or have suggestions for improvements:

1. Check the script: `install-tools-macos.sh`
2. Review the documentation: `CLAUDE.md`
3. Update the script with improvements
4. Submit changes to the repository

## Known Issues

### Gatekeeper Warnings

Some tools may trigger Gatekeeper on first run:

```bash
# Allow specific tool
xattr -cr /opt/homebrew/bin/tool-name
```

### macOS Sequoia (15.x) Specifics

If you're on macOS Sequoia and encounter issues:

```bash
# Update Xcode Command Line Tools
sudo softwareupdate --install "Command Line Tools for Xcode-16.*"
```

## License

This installation script is part of the Claude Code Configuration repository and follows the same license.

## Author

**Pedro Fernandez** - microreal@shadyknollcave.io

## Version

- **Script Version**: 1.0.0
- **Last Updated**: 2025-02-07
- **Compatible With**: macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)

---

*For more information about the development environment and tool usage, see [CLAUDE.md](CLAUDE.md)*
