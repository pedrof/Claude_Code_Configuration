#!/bin/bash
################################################################################
# Homelab Development Tools Installation Script for Ubuntu 24.04
#
# This script installs all CLI tools from the Claude Code configuration:
# - Kubernetes & Container Tools: kubectl, kubeseal, kustomize, helm, podman, cilium, k9s, stern
# - Git & Repository Management: git, tea (Gitea CLI), gh (GitHub CLI), lazygit, delta
# - Development Tools: python3, pip, node, npm, jq, yq, black, prettier, yamllint, ruff
# - AI-Optimized Tools: fzf, tree-sitter, tokei, kube-score, just, dive, ollama, shellcheck
# - Productivity Enhancers: bat, eza, fd-find, ripgrep, btop, gping, tldr, zoxide
# - Linting & Validation: hadolint, actionlint
#
# Author: Pedro Fernandez (microreal@shadyknollcave.io)
# Version: 2.1.0
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

# Node.js and npm
if ! check_command node; then
    log_info "Installing Node.js and npm..."
    # Install Node.js 20.x LTS from NodeSource
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    log_success "Node.js and npm installed successfully"
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
sudo npm install -g prettier eslint
log_success "Node.js formatting tools installed (prettier, eslint)"

# YAML linting
log_info "Installing yamllint..."
sudo apt install -y yamllint || sudo pip3 install --break-system-packages --ignore-installed yamllint
log_success "yamllint installed successfully"

################################################################################
# Install additional useful tools
################################################################################

log_info "=== Installing additional useful tools ==="

# Additional helpful tools
sudo apt install -y \
    bat \
    btop \
    eza \
    fd-find \
    gping \
    htop \
    neovim \
    ripgrep \
    tmux \
    tree \
    unzip \
    zip

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
