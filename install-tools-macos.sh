#!/bin/bash
################################################################################
# Homelab Development Tools Installation Script for macOS
#
# This script installs all CLI tools from the Claude Code configuration:
# - Kubernetes & Container Tools: kubectl, kubeseal, kustomize, helm, podman, cilium, k9s, stern,
#   kubectx, kubens, kubeconform, hubble, krew, velero
# - Git & Repository Management: git, tea (Gitea CLI), gh (GitHub CLI), lazygit, delta
# - Development Tools: python3, pip, node, npm, jq, yq, black, prettier, yamllint, ruff, mise
# - Security & Supply Chain: trivy, cosign, grype, syft, sops, age, step-cli, nmap
# - AI-Optimized Tools: fzf, tree-sitter, tokei, kube-score, just, dive, ollama, shellcheck
# - Productivity Enhancers: bat, eza, fd, ripgrep, direnv, entr, watchexec
#
# Requirements: macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)
#               Homebrew package manager
#               Xcode Command Line Tools
#
# Author: Pedro Fernandez (microreal@shadyknollcave.io)
# Version: 2.2.0
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

################################################################################
# Colors for output
################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Helper functions
################################################################################
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        log_success "$1 is already installed ($(command -v $1))"
        return 0
    else
        return 1
    fi
}

check_macos_version() {
    local version=$(sw_vers -productVersion)
    local major=$(echo "$version" | cut -d. -f1)

    if [ "$major" -lt 12 ]; then
        log_error "macOS version $version is not supported. Requires macOS 12+ (Monterey or later)"
        exit 1
    fi

    log_success "macOS $version detected"
}

detect_architecture() {
    local arch=$(uname -m)
    if [ "$arch" = "arm64" ]; then
        log_info "Apple Silicon detected (arm64)"
        return 0
    elif [ "$arch" = "x86_64" ]; then
        log_info "Intel detected (x86_64)"
        return 1
    else
        log_error "Unknown architecture: $arch"
        exit 1
    fi
}

################################################################################
# Check if running on macOS
################################################################################
if [[ $(uname) != "Darwin" ]]; then
    log_error "This script is designed for macOS only. Use install-tools-ubuntu24.sh for Linux."
    exit 1
fi

################################################################################
# Check macOS version and architecture
################################################################################
log_info "=== System Information ==="
check_macos_version
detect_architecture

################################################################################
# Install Xcode Command Line Tools if not present
################################################################################
log_info "=== Checking Xcode Command Line Tools ==="
if ! command -v xcode-select &> /dev/null; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    log_warning "Please complete the Xcode Command Line Tools installation, then run this script again."
    exit 0
else
    log_success "Xcode Command Line Tools installed"
fi

################################################################################
# Install Homebrew if not present
################################################################################
log_info "=== Checking Homebrew ==="
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set up Homebrew for Apple Silicon
    if detect_architecture; then
        log_info "Configuring Homebrew for Apple Silicon..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_success "Homebrew installed successfully"
else
    log_success "Homebrew is already installed"
    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update > /dev/null 2>&1
fi

################################################################################
# Install Rosetta 2 for Apple Silicon (for Intel tools)
################################################################################
if detect_architecture; then
    log_info "=== Checking Rosetta 2 ==="
    if ! arch -x86_64 uname &> /dev/null; then
        log_info "Installing Rosetta 2 for Intel compatibility..."
        softwareupdate --install-rosetta --agree-to-license
    else
        log_success "Rosetta 2 is installed"
    fi
fi

################################################################################
# Install Kubernetes & Container Tools
################################################################################

log_info "=== Installing Kubernetes & Container Tools ==="

# kubectl
if ! check_command kubectl; then
    log_info "Installing kubectl via Homebrew..."
    brew install kubectl
    log_success "kubectl installed successfully"
fi

# kubeseal
if ! check_command kubeseal; then
    log_info "Installing kubeseal via Homebrew..."
    brew install kubeseal
    log_success "kubeseal installed successfully"
fi

# kustomize
if ! check_command kustomize; then
    log_info "Installing kustomize via Homebrew..."
    brew install kustomize
    log_success "kustomize installed successfully"
fi

# podman
if ! check_command podman; then
    log_info "Installing podman via Homebrew..."
    brew install podman
    log_success "podman installed successfully"
    log_warning "Initialize podman with: podman machine init"
fi

# cilium-cli
if ! check_command cilium; then
    log_info "Installing cilium-cli via Homebrew..."
    brew install cilium
    log_success "cilium-cli installed successfully"
fi

# helm
if ! check_command helm; then
    log_info "Installing helm via Homebrew..."
    brew install helm
    log_success "helm installed successfully"
fi

# hubble - Cilium network observability CLI
if ! check_command hubble; then
    log_info "Installing hubble (Cilium observability CLI)..."
    brew install hubble
    log_success "hubble installed successfully"
fi

# kubectx and kubens - Fast context and namespace switching
if ! check_command kubectx; then
    log_info "Installing kubectx and kubens..."
    brew install kubectx
    log_success "kubectx and kubens installed successfully"
fi

# kubeconform - Kubernetes manifest validator
if ! check_command kubeconform; then
    log_info "Installing kubeconform (K8s manifest validator)..."
    brew install kubeconform
    log_success "kubeconform installed successfully"
fi

# krew - kubectl plugin manager
if ! check_command kubectl-krew; then
    log_info "Installing krew (kubectl plugin manager)..."
    brew install krew
    log_success "krew installed successfully"
fi

# velero - Cluster backup and restore
if ! check_command velero; then
    log_info "Installing velero (cluster backup/restore)..."
    brew install velero
    log_success "velero installed successfully"
fi

# stern - Kubernetes pod log tailing
if ! check_command stern; then
    log_info "Installing stern (Kubernetes log tailer)..."
    brew install stern
    log_success "stern installed successfully"
fi

################################################################################
# Install Git & Repository Management Tools
################################################################################

log_info "=== Installing Git & Repository Management Tools ==="

# git (usually pre-installed, but ensure via brew)
if ! check_command brew || ! brew list git &> /dev/null; then
    log_info "Installing git via Homebrew..."
    brew install git
    log_success "git installed successfully"
else
    check_command git
fi

# tea (Gitea CLI)
if ! check_command tea; then
    log_info "Installing tea (Gitea CLI) via Homebrew..."
    brew tap gitea/tap https://git.shadyknollcave.io/gitea/homebrew-gitea.git 2>/dev/null || brew tap gitea/tap
    brew install tea
    log_success "tea installed successfully"
    log_warning "Don't forget to configure: tea login add"
fi

# gh (GitHub CLI)
if ! check_command gh; then
    log_info "Installing gh (GitHub CLI) via Homebrew..."
    brew install gh
    log_success "gh installed successfully"
    log_warning "Don't forget to authenticate: gh auth login"
fi

################################################################################
# Install Development Tools
################################################################################

log_info "=== Installing Development Tools ==="

# Python 3 (usually pre-installed, but brew version is newer)
if ! brew list python@3 &> /dev/null; then
    log_info "Installing Python 3 via Homebrew..."
    brew install python@3
    log_success "Python 3 installed successfully"
else
    log_success "Python 3 is already installed via Homebrew"
fi

# nvm and Node.js
if ! check_command nvm; then
    log_info "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # Detect shell and add nvm configuration
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [ "$CURRENT_SHELL" = "bash" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    else
        SHELL_CONFIG="$HOME/.profile"
    fi

    # Add nvm to shell config if not already present
    if ! grep -q 'NVM_DIR' "$SHELL_CONFIG" 2>/dev/null; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> "$SHELL_CONFIG"
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$SHELL_CONFIG"
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$SHELL_CONFIG"
    fi

    # Source nvm and install latest LTS
    export NVM_DIR="$HOME/.nvm"
    # Temporarily disable set -u for nvm compatibility
    set +u
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    log_info "Installing latest Node.js LTS via nvm..."
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
    set -u

    log_success "nvm and Node.js $(node --version) installed successfully"
    log_warning "Run 'source $SHELL_CONFIG' or restart your shell to use nvm"
else
    log_success "nvm is already installed"
    if check_command node; then
        log_success "Node.js $(node --version) is available via nvm"
    else
        log_info "Installing Node.js LTS via existing nvm..."
        export NVM_DIR="$HOME/.nvm"
        # Temporarily disable set -u for nvm compatibility
        set +u
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        set -u
        log_success "Node.js $(node --version) installed via nvm"
    fi
fi

# jq
if ! check_command jq; then
    log_info "Installing jq via Homebrew..."
    brew install jq
    log_success "jq installed successfully"
fi

# yq
if ! check_command yq; then
    log_info "Installing yq via Homebrew..."
    brew install yq
    log_success "yq installed successfully"
fi

################################################################################
# Install Code Formatting & Linting Tools
################################################################################

log_info "=== Installing Code Formatting & Linting Tools ==="

# Python tools: black, pylint, flake8
log_info "Installing Python formatting and linting tools..."
pip3 install --upgrade --user black pylint flake8 ruff 2>/dev/null || pip3 install --upgrade black pylint flake8 ruff
log_success "Python formatting tools installed (black, pylint, flake8, ruff)"

# Node.js tools: prettier, eslint
log_info "Installing Node.js formatting and linting tools..."
if check_command nvm; then
    # Source nvm to ensure npm is available
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm install -g prettier eslint
else
    npm install -g prettier eslint
fi
log_success "Node.js formatting tools installed (prettier, eslint)"

# YAML linting
log_info "Installing yamllint..."
pip3 install --upgrade --user yamllint 2>/dev/null || pip3 install --upgrade yamllint
log_success "yamllint installed successfully"

################################################################################
# Install Security & Supply Chain Tools
################################################################################

log_info "=== Installing Security & Supply Chain Tools ==="

# trivy - Container image and K8s manifest vulnerability scanner
if ! check_command trivy; then
    log_info "Installing trivy (vulnerability scanner)..."
    brew install trivy
    log_success "trivy installed successfully"
fi

# grype - Vulnerability scanner (complements trivy)
if ! check_command grype; then
    log_info "Installing grype (vulnerability scanner)..."
    brew install grype
    log_success "grype installed successfully"
fi

# syft - SBOM generator
if ! check_command syft; then
    log_info "Installing syft (SBOM generator)..."
    brew install syft
    log_success "syft installed successfully"
fi

# cosign - Container image signing and verification
if ! check_command cosign; then
    log_info "Installing cosign (container image signing)..."
    brew install cosign
    log_success "cosign installed successfully"
fi

# age - Modern file encryption
if ! check_command age; then
    log_info "Installing age (file encryption)..."
    brew install age
    log_success "age installed successfully"
fi

# sops - Encrypted secrets in Git (works with age)
if ! check_command sops; then
    log_info "Installing sops (encrypted secrets manager)..."
    brew install sops
    log_success "sops installed successfully"
fi

# step-cli - PKI toolkit (for future mTLS and internal CA)
if ! check_command step; then
    log_info "Installing step-cli (PKI toolkit)..."
    brew install step
    log_success "step-cli installed successfully"
fi

# nmap - Network scanner
if ! check_command nmap; then
    log_info "Installing nmap (network scanner)..."
    brew install nmap
    log_success "nmap installed successfully"
fi

log_success "Security & supply chain tools installed"

################################################################################
# Install additional useful tools
################################################################################

log_info "=== Installing additional useful tools ==="

brew install \
    bat \
    direnv \
    entr \
    eza \
    fd \
    ripgrep \
    htop \
    neovim \
    tmux \
    tree \
    watchexec

# Add direnv hook to shell config if not present
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
    DIRENV_CONFIG="$HOME/.zshrc"
else
    DIRENV_CONFIG="$HOME/.bash_profile"
fi
if command -v direnv &> /dev/null; then
    if ! grep -q 'eval "$(direnv hook' "$DIRENV_CONFIG" 2>/dev/null; then
        echo "eval \"\$(direnv hook ${CURRENT_SHELL})\"" >> "$DIRENV_CONFIG"
        log_success "Added direnv hook to $DIRENV_CONFIG"
    fi
fi

# mise - Polyglot version manager
if ! check_command mise; then
    log_info "Installing mise (polyglot version manager)..."
    brew install mise
    if ! grep -q 'mise activate' "$DIRENV_CONFIG" 2>/dev/null; then
        echo "eval \"\$(mise activate ${CURRENT_SHELL})\"" >> "$DIRENV_CONFIG"
    fi
    log_success "mise installed successfully"
fi

log_success "Additional tools installed"

################################################################################
# Install AI-Optimized Development Tools
################################################################################

log_info "=== Installing AI-Optimized Development Tools ==="

# k9s - Kubernetes Terminal UI
if ! check_command k9s; then
    log_info "Installing k9s (Kubernetes TUI)..."
    brew install k9s
    log_success "k9s installed successfully"
fi

# fzf - Fuzzy finder
if ! check_command fzf; then
    log_info "Installing fzf (fuzzy finder)..."
    brew install fzf
    # Install fzf shell extensions
    $(brew --prefix)/opt/fzf/install --all --no-fish 2>/dev/null || true
    log_success "fzf installed successfully"
fi

# tree-sitter - Code parsing (Claude uses this internally)
if ! check_command tree-sitter; then
    log_info "Installing tree-sitter..."
    brew install tree-sitter
    log_success "tree-sitter installed successfully"
fi

# tokei - Code statistics
if ! check_command tokei; then
    log_info "Installing tokei (code statistics)..."
    brew install tokei
    log_success "tokei installed successfully"
fi

# lazygit - Git Terminal UI
if ! check_command lazygit; then
    log_info "Installing lazygit (git TUI)..."
    brew install lazygit
    log_success "lazygit installed successfully"
fi

# kube-score - Kubernetes linter
if ! check_command kube-score; then
    log_info "Installing kube-score (Kubernetes linter)..."
    brew install kube-score
    log_success "kube-score installed successfully"
fi

# just - Command runner
if ! check_command just; then
    log_info "Installing just (command runner)..."
    brew install just
    log_success "just installed successfully"
fi

# dive - Docker image analyzer
if ! check_command dive; then
    log_info "Installing dive (Docker image analyzer)..."
    brew install dive
    log_success "dive installed successfully"
fi

# ollama - Local LLM runner (AI development)
if ! check_command ollama; then
    log_info "Installing ollama (local LLM runner)..."
    brew install ollama
    log_success "ollama installed successfully"
    log_warning "Start ollama service with: ollama serve"
    log_warning "Pull a model: ollama pull codellama"
fi

# shellcheck - Shell script linter
if ! check_command shellcheck; then
    log_info "Installing shellcheck..."
    brew install shellcheck
    log_success "shellcheck installed successfully"
fi

# lazygit - Git Terminal UI
if ! check_command lazygit; then
    log_info "Installing lazygit (git TUI)..."
    brew install lazygit
    log_success "lazygit installed successfully"
fi

# delta - Better git diff viewer
if ! check_command delta; then
    log_info "Installing delta (better git diffs)..."
    brew install git-delta
    log_success "delta installed successfully"
    log_warning "Add to ~/.gitconfig: [core] pager = delta"
fi

# hadolint - Dockerfile/Containerfile linter
if ! check_command hadolint; then
    log_info "Installing hadolint (Dockerfile linter)..."
    brew install hadolint
    log_success "hadolint installed successfully"
fi

# actionlint - GitHub Actions linter
if ! check_command actionlint; then
    log_info "Installing actionlint (GitHub Actions linter)..."
    brew install actionlint
    log_success "actionlint installed successfully"
fi

# tldr - Simplified man pages
if ! check_command tldr; then
    log_info "Installing tldr (simplified man pages)..."
    brew install tldr
    log_success "tldr installed successfully"
fi

# zoxide - Smarter directory navigation
if ! check_command zoxide; then
    log_info "Installing zoxide (smarter cd)..."
    brew install zoxide
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        ZOXIDE_CONFIG="$HOME/.zshrc"
    else
        ZOXIDE_CONFIG="$HOME/.bash_profile"
    fi
    if ! grep -q 'eval "$(zoxide init' "$ZOXIDE_CONFIG" 2>/dev/null; then
        echo "eval \"\$(zoxide init ${CURRENT_SHELL})\"" >> "$ZOXIDE_CONFIG"
    fi
    log_success "zoxide installed successfully"
fi

# btop - Resource monitor
if ! check_command btop; then
    log_info "Installing btop (resource monitor)..."
    brew install btop
    log_success "btop installed successfully"
fi

# gping - Ping with graph
if ! check_command gping; then
    log_info "Installing gping (graphical ping)..."
    brew install gping
    log_success "gping installed successfully"
fi

log_success "AI-optimized tools installed"

################################################################################
# Configure shell
################################################################################
log_info "=== Shell Configuration ==="

# Detect shell
CURRENT_SHELL=$(basename "$SHELL")

if [ "$CURRENT_SHELL" = "zsh" ]; then
    log_info "Configuring zsh..."
    if ! grep -q "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" ~/.zprofile 2>/dev/null; then
        if detect_architecture; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            log_success "Added Homebrew to ~/.zprofile"
        fi
    fi
elif [ "$CURRENT_SHELL" = "bash" ]; then
    log_info "Configuring bash..."
    if ! grep -q "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" ~/.bash_profile 2>/dev/null; then
        if detect_architecture; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
            log_success "Added Homebrew to ~/.bash_profile"
        fi
    fi
fi

################################################################################
# Configure git
################################################################################
log_info "=== Git Configuration ==="
log_warning "Don't forget to configure git:"
echo "  git config --global user.name 'Your Name'"
echo "  git config --global user.email 'your-email@example.com'"
echo "  git config --global init.defaultBranch main"

################################################################################
# Verify installations
################################################################################
log_info "=== Verifying installations ==="

echo ""
log_info "Installed tools:"
echo "-------------------"

tools=(
    "kubectl:kubectl version --client"
    "kubeseal:kubeseal --version"
    "kustomize:kustomize version"
    "helm:helm version"
    "podman:podman --version"
    "cilium:cilium version"
    "hubble:hubble version"
    "kubectx:kubectx --version"
    "kubens:kubens --version"
    "kubeconform:kubeconform -v"
    "krew:kubectl krew version"
    "velero:velero version --client-only"
    "stern:stern --version"
    "git:git --version"
    "tea:tea --version"
    "gh:gh --version"
    "python3:python3 --version"
    "pip3:pip3 --version"
    "node:node --version"
    "npm:npm --version"
    "jq:jq --version"
    "yq:yq --version"
    "black:black --version"
    "pylint:pylint --version"
    "flake8:flake8 --version"
    "ruff:ruff --version"
    "prettier:prettier --version"
    "eslint:eslint --version"
    "yamllint:yamllint --version"
    "trivy:trivy --version"
    "grype:grype version"
    "syft:syft version"
    "cosign:cosign version"
    "age:age --version"
    "sops:sops --version"
    "step:step version"
    "nmap:nmap --version"
    "k9s:k9s version"
    "fzf:fzf --version"
    "tree-sitter:tree-sitter --version"
    "tokei:tokei --version"
    "lazygit:lazygit --version"
    "kube-score:kube-score version"
    "just:just --version"
    "dive:dive --version"
    "ollama:ollama --version"
    "shellcheck:shellcheck --version"
    "direnv:direnv version"
    "entr:entr -h"
    "watchexec:watchexec --version"
    "mise:mise --version"
    "bat:bat --version"
    "fd:fd --version"
    "delta:delta --version"
    "hadolint:hadolint --version"
    "actionlint:actionlint --version"
    "tldr:tldr --version"
    "zoxide:zoxide --version"
    "btop:btop --version"
    "gping:gping --version"
    "rg:rg --version"
)

for tool_info in "${tools[@]}"; do
    IFS=':' read -r tool cmd <<< "$tool_info"
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $tool"
    else
        echo -e "${RED}✗${NC} $tool (not found)"
    fi
done

################################################################################
# Finish
################################################################################
echo ""
log_success "=== Installation Complete ==="
echo ""
log_info "Next steps:"
echo "1. Configure git: git config --global user.name 'Your Name' && git config --global user.email 'your-email@example.com'"
echo "2. Authenticate with Gitea: tea login add"
echo "3. Authenticate with GitHub: gh auth login"
echo "4. Initialize podman (if using): podman machine init && podman machine start"
echo "5. Configure delta as git pager: git config --global core.pager delta"
echo "6. Start ollama for local LLMs (optional): ollama serve && ollama pull codellama"
echo "7. Reload your shell to enable direnv, mise, and zoxide"
echo "8. Start developing!"
echo ""
log_warning "Note: Some tools may require a shell restart. Run: source ~/.zprofile (or ~/.bash_profile)"
echo ""
log_success "All tools installed successfully!"
