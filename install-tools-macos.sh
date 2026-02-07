#!/bin/bash
################################################################################
# Homelab Development Tools Installation Script for macOS
#
# This script installs all CLI tools from the Claude Code configuration:
# - Kubernetes & Container Tools: kubectl, kubeseal, kustomize, podman, cilium
# - Git & Repository Management: git, tea (Gitea CLI), gh (GitHub CLI)
# - Development Tools: python3, pip, node, npm, jq, yq, black, prettier, yamllint
#
# Requirements: macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)
#               Homebrew package manager
#               Xcode Command Line Tools
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

# Node.js (LTS version)
if ! check_command node; then
    log_info "Installing Node.js LTS via Homebrew..."
    brew install node
    log_success "Node.js and npm installed successfully"
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
pip3 install --upgrade --user black pylint flake8 2>/dev/null || pip3 install --upgrade black pylint flake8
log_success "Python formatting tools installed (black, pylint, flake8)"

# Node.js tools: prettier, eslint
log_info "Installing Node.js formatting and linting tools..."
npm install -g prettier eslint
log_success "Node.js formatting tools installed (prettier, eslint)"

# YAML linting
log_info "Installing yamllint..."
pip3 install --upgrade --user yamllint 2>/dev/null || pip3 install --upgrade yamllint
log_success "yamllint installed successfully"

################################################################################
# Install additional useful tools
################################################################################

log_info "=== Installing additional useful tools ==="

brew install \
    bat \
    eza \
    fd \
    ripgrep \
    htop \
    neovim \
    tmux \
    tree

log_success "Additional tools installed"

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
echo "4. Initialize podman (if using): podman machine init"
echo "5. Start developing!"
echo ""
log_warning "Note: Some tools may require a shell restart. Run: source ~/.zprofile (or ~/.bash_profile)"
echo ""
log_success "All tools installed successfully!"
