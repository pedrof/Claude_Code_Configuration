#!/bin/bash
################################################################################
# Homelab Development Tools Installation Script for Ubuntu 24.04
#
# This script installs all CLI tools from the Claude Code configuration:
# - Kubernetes & Container Tools: kubectl, kubeseal, kustomize, helm, podman, cilium, k9s, stern,
#   kubectx, kubens, kubeconform, hubble, krew, velero
# - Git & Repository Management: git, tea (Gitea CLI), gh (GitHub CLI), lazygit, delta
# - Development Tools: python3, pip, node, npm, jq, yq, black, prettier, yamllint, ruff, mise
# - Security & Supply Chain: trivy, cosign, grype, syft, sops, age, step-cli, nmap
# - AI-Optimized Tools: fzf, tree-sitter, tokei, kube-score, just, dive, ollama, shellcheck
# - Productivity Enhancers: bat, eza, fd-find, ripgrep, btop, gping, tldr, zoxide, direnv, entr,
#   watchexec
# - Linting & Validation: hadolint, actionlint
#
# Author: Pedro Fernandez (microreal@shadyknollcave.io)
# Version: 2.3.0
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

################################################################################
# Check if running as root
################################################################################
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root. Use sudo instead."
    exit 1
fi

################################################################################
# Start installation
################################################################################
log_info "Starting installation of homelab development tools..."
log_info "This script requires sudo privileges for package installation."

# Update package lists
log_info "Updating package lists..."
sudo apt update

################################################################################
# Install basic dependencies
################################################################################
log_info "Installing basic dependencies..."
sudo apt install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    gnupg2 \
    pass

################################################################################
# Install Kubernetes & Container Tools
################################################################################

log_info "=== Installing Kubernetes & Container Tools ==="

# kubectl
if ! check_command kubectl; then
    log_info "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    log_success "kubectl installed successfully"
fi

# kubeseal
if ! check_command kubeseal; then
    log_info "Installing kubeseal..."
    KUBESEAL_VERSION="0.24.0"
    curl -LO "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
    tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
    sudo install -m 755 kubeseal /usr/local/bin/
    rm -f kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
    log_success "kubeseal installed successfully"
fi

# kustomize
if ! check_command kustomize; then
    log_info "Installing kustomize..."
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/
    log_success "kustomize installed successfully"
fi

# helm
if ! check_command helm; then
    log_info "Installing helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    log_success "helm installed successfully"
fi

# podman
if ! check_command podman; then
    log_info "Installing podman..."
    sudo apt install -y podman
    log_success "podman installed successfully"
fi

# cilium-cli
if ! check_command cilium; then
    log_info "Installing cilium-cli..."
    CILIUM_VERSION="0.16.10"
    curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/v${CILIUM_VERSION}/cilium-linux-amd64.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
    rm -f cilium-linux-amd64.tar.gz*
    log_success "cilium-cli installed successfully"
fi

# hubble - Cilium network observability CLI
if ! check_command hubble; then
    log_info "Installing hubble (Cilium observability CLI)..."
    HUBBLE_VERSION="1.18.5"
    curl -L --remote-name-all https://github.com/cilium/hubble/releases/download/v${HUBBLE_VERSION}/hubble-linux-amd64.tar.gz{,.sha256sum}
    sha256sum --check hubble-linux-amd64.tar.gz.sha256sum
    sudo tar xzvfC hubble-linux-amd64.tar.gz /usr/local/bin
    rm -f hubble-linux-amd64.tar.gz*
    log_success "hubble installed successfully"
fi

# kubectx and kubens - Fast context and namespace switching
if ! check_command kubectx; then
    log_info "Installing kubectx and kubens..."
    KUBECTX_VERSION="0.9.5"
    curl -sSLO "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz"
    tar -xzf kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz
    sudo install -m 755 kubectx /usr/local/bin/
    rm -f kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz LICENSE
    curl -sSLO "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubens_v${KUBECTX_VERSION}_linux_x86_64.tar.gz"
    tar -xzf kubens_v${KUBECTX_VERSION}_linux_x86_64.tar.gz
    sudo install -m 755 kubens /usr/local/bin/
    rm -f kubens_v${KUBECTX_VERSION}_linux_x86_64.tar.gz LICENSE
    log_success "kubectx and kubens installed successfully"
fi

# kubeconform - Kubernetes manifest validator
if ! check_command kubeconform; then
    log_info "Installing kubeconform (K8s manifest validator)..."
    KUBECONFORM_VERSION="0.7.0"
    curl -sSLO "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz"
    tar -xzf kubeconform-linux-amd64.tar.gz
    sudo install -m 755 kubeconform /usr/local/bin/
    rm -f kubeconform-linux-amd64.tar.gz LICENSE
    log_success "kubeconform installed successfully"
fi

# krew - kubectl plugin manager
if ! check_command kubectl-krew; then
    log_info "Installing krew (kubectl plugin manager)..."
    KREW_VERSION="0.4.5"
    cd "$(mktemp -d)"
    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')"
    KREW="krew-${OS}_${ARCH}"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/${KREW}.tar.gz"
    tar zxvf "${KREW}.tar.gz"
    ./"${KREW}" install krew
    cd -
    # Add krew to PATH if not already present
    if ! grep -q 'krew' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
    fi
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    log_success "krew installed successfully"
    log_warning "Run 'source ~/.bashrc' to add krew to PATH"
fi

# velero - Cluster backup and restore
if ! check_command velero; then
    log_info "Installing velero (cluster backup/restore)..."
    VELERO_VERSION="1.17.2"
    curl -sSLO "https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz"
    tar -xzf velero-v${VELERO_VERSION}-linux-amd64.tar.gz
    sudo install -m 755 velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin/
    rm -rf velero-v${VELERO_VERSION}-linux-amd64*
    log_success "velero installed successfully"
fi

################################################################################
# Install Git & Repository Management Tools
################################################################################

log_info "=== Installing Git & Repository Management Tools ==="

# git (usually pre-installed, but ensure it's there)
if ! check_command git; then
    log_info "Installing git..."
    sudo apt install -y git
    log_success "git installed successfully"
fi

# tea (Gitea CLI)
if ! check_command tea; then
    log_info "Installing tea (Gitea CLI)..."
    TEA_VERSION="0.9.0"
    curl -L "https://dl.gitea.io/tea/${TEA_VERSION}/tea-${TEA_VERSION}-linux-amd64" -o tea
    chmod +x tea
    sudo mv tea /usr/local/bin/
    log_success "tea installed successfully"
    log_warning "Don't forget to configure: tea login add"
fi

# gh (GitHub CLI)
if ! check_command gh; then
    log_info "Installing gh (GitHub CLI)..."
    type -p curl >/dev/null || sudo apt install -y curl
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
    log_success "gh installed successfully"
    log_warning "Don't forget to authenticate: gh auth login"
fi

################################################################################
# Install Development Tools
################################################################################

log_info "=== Installing Development Tools ==="

# Python 3 and pip
if ! check_command python3; then
    log_info "Installing Python 3 and pip..."
    sudo apt install -y python3 python3-pip python3-venv
    log_success "Python 3 installed successfully"
fi

# nvm and Node.js
if ! check_command nvm; then
    log_info "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # Install latest LTS version of Node.js
    log_info "Installing latest Node.js LTS via nvm..."
    export NVM_DIR="$HOME/.nvm"
    # Temporarily disable set -u for nvm compatibility
    set +u
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
    set -u

    # Add nvm to shell if not already present
    if ! grep -q 'NVM_DIR' ~/.bashrc 2>/dev/null; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
    fi

    log_success "nvm and Node.js $(node --version) installed successfully"
    log_warning "Run 'source ~/.bashrc' or restart your shell to use nvm"
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
    log_info "Installing jq..."
    sudo apt install -y jq
    log_success "jq installed successfully"
fi

# yq
if ! check_command yq; then
    log_info "Installing yq..."
    YQ_VERSION="v4.40.5"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O yq
    chmod +x yq
    sudo mv yq /usr/local/bin/
    log_success "yq installed successfully"
fi

################################################################################
# Install Code Formatting & Linting Tools
################################################################################

log_info "=== Installing Code Formatting & Linting Tools ==="

# Python tools: black, pylint, flake8, ruff
log_info "Installing Python formatting and linting tools..."
sudo pip3 install --break-system-packages --ignore-installed black pylint flake8 ruff
log_success "Python formatting tools installed (black, pylint, flake8, ruff)"

# Node.js tools: prettier, eslint
log_info "Installing Node.js formatting and linting tools..."
if check_command nvm; then
    # Source nvm to ensure npm is available
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm install -g prettier eslint
else
    sudo npm install -g prettier eslint
fi
log_success "Node.js formatting tools installed (prettier, eslint)"

# YAML linting
log_info "Installing yamllint..."
sudo apt install -y yamllint || sudo pip3 install --break-system-packages --ignore-installed yamllint
log_success "yamllint installed successfully"

################################################################################
# Install Security & Supply Chain Tools
################################################################################

log_info "=== Installing Security & Supply Chain Tools ==="

# trivy - Container image and K8s manifest vulnerability scanner
if ! check_command trivy; then
    log_info "Installing trivy (vulnerability scanner)..."
    TRIVY_VERSION="0.69.1"
    curl -sSLO "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
    tar -xzf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz
    sudo install -m 755 trivy /usr/local/bin/
    rm -f trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz LICENSE contrib/
    log_success "trivy installed successfully"
fi

# grype - Vulnerability scanner (complements trivy)
if ! check_command grype; then
    log_info "Installing grype (vulnerability scanner)..."
    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin
    log_success "grype installed successfully"
fi

# syft - SBOM generator
if ! check_command syft; then
    log_info "Installing syft (SBOM generator)..."
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin
    log_success "syft installed successfully"
fi

# cosign - Container image signing and verification
if ! check_command cosign; then
    log_info "Installing cosign (container image signing)..."
    COSIGN_VERSION="3.0.4"
    curl -sSLO "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64"
    sudo install -m 755 cosign-linux-amd64 /usr/local/bin/cosign
    rm -f cosign-linux-amd64
    log_success "cosign installed successfully"
fi

# age - Modern file encryption
if ! check_command age; then
    log_info "Installing age (file encryption)..."
    AGE_VERSION="1.3.1"
    curl -sSLO "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz"
    tar -xzf age-v${AGE_VERSION}-linux-amd64.tar.gz
    sudo install -m 755 age/age /usr/local/bin/
    sudo install -m 755 age/age-keygen /usr/local/bin/
    rm -rf age-v${AGE_VERSION}-linux-amd64.tar.gz age/
    log_success "age installed successfully"
fi

# sops - Encrypted secrets in Git (works with age)
if ! check_command sops; then
    log_info "Installing sops (encrypted secrets manager)..."
    SOPS_VERSION="3.11.0"
    curl -sSLO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
    sudo install -m 755 sops-v${SOPS_VERSION}.linux.amd64 /usr/local/bin/sops
    rm -f sops-v${SOPS_VERSION}.linux.amd64
    log_success "sops installed successfully"
fi

# step-cli - PKI toolkit (for future mTLS and internal CA)
if ! check_command step; then
    log_info "Installing step-cli (PKI toolkit)..."
    STEP_VERSION="0.29.0"
    curl -sSLO "https://github.com/smallstep/cli/releases/download/v${STEP_VERSION}/step_linux_${STEP_VERSION}_amd64.tar.gz"
    tar -xzf step_linux_${STEP_VERSION}_amd64.tar.gz
    sudo install -m 755 step_${STEP_VERSION}/bin/step /usr/local/bin/
    rm -rf step_linux_${STEP_VERSION}_amd64.tar.gz step_${STEP_VERSION}/
    log_success "step-cli installed successfully"
fi

# nmap - Network scanner
if ! check_command nmap; then
    log_info "Installing nmap (network scanner)..."
    sudo apt install -y nmap
    log_success "nmap installed successfully"
fi

log_success "Security & supply chain tools installed"

################################################################################
# Install additional useful tools
################################################################################

log_info "=== Installing additional useful tools ==="

# Additional helpful tools
sudo apt install -y \
    bat \
    btop \
    direnv \
    entr \
    eza \
    fd-find \
    gping \
    htop \
    neovim \
    nmap \
    ripgrep \
    tmux \
    tree \
    unzip \
    zip

# Create symlinks for bat and fd (Ubuntu renames these)
if [ -f /usr/bin/batcat ] && [ ! -f /usr/local/bin/bat ]; then
    sudo ln -s /usr/bin/batcat /usr/local/bin/bat
    log_success "Created bat symlink (batcat -> bat)"
fi
if [ -f /usr/bin/fdfind ] && [ ! -f /usr/local/bin/fd ]; then
    sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
    log_success "Created fd symlink (fdfind -> fd)"
fi

# Add direnv hook to bashrc if not present
if command -v direnv &> /dev/null; then
    if ! grep -q 'eval "$(direnv hook' ~/.bashrc 2>/dev/null; then
        echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
        log_success "Added direnv hook to ~/.bashrc"
    fi
fi

# watchexec - File watcher and command runner
if ! check_command watchexec; then
    log_info "Installing watchexec (file watcher)..."
    WATCHEXEC_VERSION="2.3.3"
    curl -sSLO "https://github.com/watchexec/watchexec/releases/download/v${WATCHEXEC_VERSION}/watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.tar.xz"
    tar -xJf watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu.tar.xz
    sudo install -m 755 watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu/watchexec /usr/local/bin/
    rm -rf watchexec-${WATCHEXEC_VERSION}-x86_64-unknown-linux-gnu*
    log_success "watchexec installed successfully"
fi

# mise - Polyglot version manager (replaces nvm/pyenv/asdf)
if ! check_command mise; then
    log_info "Installing mise (polyglot version manager)..."
    curl https://mise.run | sh
    # Add mise to bashrc if not present
    if ! grep -q 'mise activate' ~/.bashrc 2>/dev/null; then
        echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
    fi
    log_success "mise installed successfully"
    log_warning "Run 'source ~/.bashrc' to activate mise"
fi

log_success "Additional tools installed"

################################################################################
# Install AI-Optimized Development Tools
################################################################################

log_info "=== Installing AI-Optimized Development Tools ==="

# k9s - Kubernetes Terminal UI
if ! check_command k9s; then
    log_info "Installing k9s (Kubernetes TUI)..."
    K9S_VERSION="v0.32.5"
    curl -sSLO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    tar -xzf k9s_Linux_amd64.tar.gz
    sudo install -m 755 k9s /usr/local/bin/
    rm -f k9s_Linux_amd64.tar.gz LICENSE.md
    log_success "k9s installed successfully"
fi

# fzf - Fuzzy finder
if ! check_command fzf; then
    log_info "Installing fzf (fuzzy finder)..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null || true
    ~/.fzf/install --all --no-bash --no-zsh 2>/dev/null || true
    sudo cp ~/.fzf/bin/fzf /usr/local/bin/
    log_success "fzf installed successfully"
fi

# tree-sitter - Code parsing (Claude uses this internally)
if ! check_command tree-sitter; then
    log_info "Installing tree-sitter..."
    sudo apt install -y tree-sitter-cli
    log_success "tree-sitter installed successfully"
fi

# tokei - Code statistics
if ! check_command tokei; then
    log_info "Installing tokei (code statistics)..."
    TOKEI_VERSION="v12.1.2"
    curl -sSLO "https://github.com/XAMPPRocky/tokei/releases/download/${TOKEI_VERSION}/tokei-x86_64-unknown-linux-gnu.tar.gz"
    tar -xzf tokei-x86_64-unknown-linux-gnu.tar.gz
    sudo mv tokei /usr/local/bin/
    rm -f tokei-x86_64-unknown-linux-gnu.tar.gz
    log_success "tokei installed successfully"
fi

# lazygit - Git Terminal UI
if ! check_command lazygit; then
    log_info "Installing lazygit (git TUI)..."
    LAZYGIT_VERSION="0.44.1"
    wget https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
    tar -xzf lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz
    sudo mv lazygit /usr/local/bin/
    rm -f lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz LICENSE
    log_success "lazygit installed successfully"
fi

# kube-score - Kubernetes linter
if ! check_command kube-score; then
    log_info "Installing kube-score (Kubernetes linter)..."
    KUBE_SCORE_VERSION="v1.19.0"
    curl -sSLO "https://github.com/zegl/kube-score/releases/download/${KUBE_SCORE_VERSION}/kube-score_${KUBE_SCORE_VERSION}_linux_amd64"
    chmod +x kube-score_${KUBE_SCORE_VERSION}_linux_amd64
    sudo mv kube-score_${KUBE_SCORE_VERSION}_linux_amd64 /usr/local/bin/kube-score
    log_success "kube-score installed successfully"
fi

# just - Command runner
if ! check_command just; then
    log_info "Installing just (command runner)..."
    JUST_VERSION="1.33.0"
    curl -sSLO "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    tar -xzf just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz
    sudo mv just /usr/local/bin/
    rm -f just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz
    log_success "just installed successfully"
fi

# dive - Docker image analyzer
if ! check_command dive; then
    log_info "Installing dive (Docker image analyzer)..."
    DIVE_VERSION="0.13.1"
    wget https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.tar.gz
    tar -xzf dive_${DIVE_VERSION}_linux_amd64.tar.gz
    sudo mv dive /usr/local/bin/
    rm -f dive_${DIVE_VERSION}_linux_amd64.tar.gz
    log_success "dive installed successfully"
fi

# ollama - Local LLM runner (AI development)
if ! check_command ollama; then
    log_info "Installing ollama (local LLM runner)..."
    curl -fsSL https://ollama.com/install.sh | sh
    log_success "ollama installed successfully"
    log_warning "Start ollama service with: ollama serve"
    log_warning "Pull a model: ollama pull codellama"
fi

# shellcheck - Shell script linter
if ! check_command shellcheck; then
    log_info "Installing shellcheck..."
    sudo apt install -y shellcheck
    log_success "shellcheck installed successfully"
fi

log_success "AI-optimized tools installed"

################################################################################
# Install Additional Development Tools
################################################################################

log_info "=== Installing Additional Development Tools ==="

# tldr - Simplified man pages
if ! check_command tldr; then
    log_info "Installing tldr (simplified man pages)..."
    curl -s https://raw.githubusercontent.com/tldr-pages/tldr/main/pages-sh/c/tldr -o tldr
    sudo install -m 755 tldr /usr/local/bin/
    rm -f tldr
    log_success "tldr installed successfully"
fi

# zoxide - Smarter directory navigation
if ! check_command zoxide; then
    log_info "Installing zoxide (smarter cd)..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    # Add to shell initialization if not already present
    if ! grep -q 'eval "$(zoxide init' ~/.bashrc 2>/dev/null; then
        echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
    fi
    log_success "zoxide installed successfully"
    log_warning "Run 'source ~/.bashrc' or restart your shell to use zoxide"
fi

# delta - Better git diff viewer
if ! check_command delta; then
    log_info "Installing delta (better git diffs)..."
    DELTA_VERSION="0.18.0"
    wget https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz
    tar -xzf delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu.tar.gz
    sudo mv delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu/delta /usr/local/bin/
    rm -rf delta-${DELTA_VERSION}-x86_64-unknown-linux-gnu*
    log_success "delta installed successfully"
    log_warning "Add to ~/.gitconfig: [core] pager = delta"
fi

# stern - Kubernetes pod log tailing
if ! check_command stern; then
    log_info "Installing stern (Kubernetes log tailer)..."
    STERN_VERSION="1.31.0"
    curl -LO "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz"
    tar -xzf stern_${STERN_VERSION}_linux_amd64.tar.gz
    sudo mv stern /usr/local/bin/
    rm -f stern_${STERN_VERSION}_linux_amd64.tar.gz
    log_success "stern installed successfully"
fi

# hadolint - Dockerfile linter
if ! check_command hadolint; then
    log_info "Installing hadolint (Dockerfile linter)..."
    HADOLINT_VERSION="2.12.0"
    wget https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64
    sudo mv hadolint-Linux-x86_64 /usr/local/bin/hadolint
    sudo chmod +x /usr/local/bin/hadolint
    log_success "hadolint installed successfully"
fi

# actionlint - GitHub Actions linter
if ! check_command actionlint; then
    log_info "Installing actionlint (GitHub Actions linter)..."
    ACTIONLINT_VERSION="1.7.10"
    wget https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz
    tar -xzf actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz
    sudo mv actionlint /usr/local/bin/
    rm -f actionlint_${ACTIONLINT_VERSION}_linux_amd64.tar.gz
    log_success "actionlint installed successfully"
fi

log_success "Additional development tools installed"

################################################################################
# Configure git
################################################################################
log_info "=== Git Configuration ==="
log_warning "Don't forget to configure git:"
echo "  git config --global user.name 'Your Name'"
echo "  git config --global user.email 'your-email@example.com'"
echo "  git config --global init.defaultBranch main"
echo "  git config --global core.autocrlf input"

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
    "tldr:tldr --version"
    "zoxide:zoxide --version"
    "delta:delta --version"
    "stern:stern --version"
    "hadolint:hadolint --version"
    "actionlint:actionlint --version"
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
echo "4. Configure kubectl for your K3s cluster"
echo "5. Reload your shell: source ~/.bashrc (to enable zoxide)"
echo "6. Configure delta as git pager: git config --global core.pager delta"
echo "7. Start ollama for local LLMs (optional): ollama serve && ollama pull codellama"
echo "8. Start developing!"
echo ""
log_success "All tools installed successfully!"
