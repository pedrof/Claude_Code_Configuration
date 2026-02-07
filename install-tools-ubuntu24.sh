#!/bin/bash
################################################################################
# Homelab Development Tools Installation Script for Ubuntu 24.04
#
# This script installs all CLI tools from the Claude Code configuration:
# - Kubernetes & Container Tools: kubectl, kubeseal, kustomize, podman, cilium
# - Git & Repository Management: git, tea (Gitea CLI), gh (GitHub CLI)
# - Development Tools: python3, pip, node, npm, jq, yq, black, prettier, yamllint
#
# Author: Pedro Fernandez (microreal@shadyknollcave.io)
# Version: 1.0.0
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

# Python tools: black, pylint, flake8
log_info "Installing Python formatting and linting tools..."
sudo pip3 install --break-system-packages black pylint flake8
log_success "Python formatting tools installed (black, pylint, flake8)"

# Node.js tools: prettier, eslint
log_info "Installing Node.js formatting and linting tools..."
sudo npm install -g prettier eslint
log_success "Node.js formatting tools installed (prettier, eslint)"

# YAML linting
log_info "Installing yamllint..."
sudo apt install -y yamllint || sudo pip3 install --break-system-packages yamllint
log_success "yamllint installed successfully"

################################################################################
# Install additional useful tools
################################################################################

log_info "=== Installing additional useful tools ==="

# Additional helpful tools
sudo apt install -y \
    bat \
    exa \
    fd-find \
    ripgrep \
    htop \
    neovim \
    tmux \
    tree \
    unzip \
    zip

log_success "Additional tools installed"

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
    "prettier:prettier --version"
    "eslint:eslint --version"
    "yamllint:yamllint --version"
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
echo "5. Start developing!"
echo ""
log_success "All tools installed successfully!"
