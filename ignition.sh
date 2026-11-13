#!/bin/bash

# Ignition Script - Kali Linux Configuration
# Automates system prep, package installation, shell customization, and more.

set -e  # Exit immediately if a command exits with a non-zero status.

# --- Global Variables ---
USER="kali"
HOME="/home/${USER}"
NEO4J_PASS="bloodhound"

# --- Colours for Output ---
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
NC="\033[0m" # No Colour

# --- Logging Badges ---
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Check for sudo ---
if [ "$EUID" -ne 0 ]; then
  log_error "Please run as root (sudo ./ignition.sh)"
  exit 1
fi

# --- Banner ---
banner() {
    echo ""
    echo "Kali Linux Configuration Script"
    echo ""
}

## --- Package Installs ---

# --- System Prep & Utility Packages ---
system_prep() {
    log_info "System Preparation & Package Installation..."

    log_info "Updating package lists..."
    apt update

    log_info "Installing utility packages (grc, colorize, bat)..."
    apt install -y grc colorize bat

    log_success "Task Complete: Utility packages installed."
}

# --- GRC Configuration Setup ---
grc_config() {
    log_info "grc configuration setup..."
    log_info "Creating required directory..."

    TARGET_DIR="${HOME}/.grc"

    mkdir -p "$TARGET_DIR"

    log_info "Copying configurations..."

    # base grc config
    cat "configs/grc/grc.conf" >> "$TARGET_DIR/grc.conf"

    # ffuf config
    cp "configs/grc/conf.ffuf" "$TARGET_DIR/"

    log_success "Task Complete: grc configuration complete."
}

# --- Git Install ---
git_install() {
    log_info "Installing Git..."
    if command -v git &> /dev/null; then
        log_warn "Git is already installed. Skipping..."
    else
        apt install -y git
        log_success "Task Complete: Git installed."
    fi
}

# --- Eza Install ---
eza_install() {
    if command -v eza &> /dev/null; then
        log_warn "eza is already installed. Skipping..."
        return
    fi

    log_info "Installing eza dependencies and setting up repository..."
    apt install -y gpg sudo
    
    mkdir -p /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/gierens.gpg ]; then
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    fi
    
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    
    apt update
    apt install -y eza

    log_success "Task Complete: Eza installed."
}

# --- Oh My Zsh Install ---
omz_install() {
    log_info "Oh My Zsh Installation..."
    
    # Check if ZSH is installed
    if ! command -v zsh &> /dev/null; then
        apt install -y zsh
    fi

    # Check if OMZ is already installed
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        log_warn "Oh My Zsh is already installed. Skipping..."
    else
        # Unattended install
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    log_success "Task Complete: Oh-My-Zsh installed."
}

# --- Zsh Plugins ---
zsh_plugins() {
    log_info "Installing Zsh Plugins..."
    
    ZSH_CUSTOM=${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}
    
    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    else
        log_warn "zsh-autosuggestions already exists. Skipping clone."
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    else
        log_warn "zsh-syntax-highlighting already exists. Skipping clone."
    fi

    log_success "Task Complete: Zsh plugins installed."
}

# --- Zsh Configuration ---
zshrc_config() {
    log_info "Configuring .zshrc..."
    
    CONFIG_ZSHRC="$(dirname "$0")/configs/.zshrc"

    if [ ! -f "$CONFIG_ZSHRC" ]; then
        log_error "Configuration file not found: $CONFIG_ZSHRC"
        exit 1
    fi

    # Back up existing .zshrc
    if [ -f "${HOME}/.zshrc" ]; then
        cp --force "${HOME}/.zshrc" "${HOME}/.zshrc.bak.$(date +%F-%T)"
        log_info "Backed up existing .zshrc"
    fi

    cp --force "$CONFIG_ZSHRC" "${HOME}/.zshrc"

    log_success "Task Complete: .zshrc copied from configs."
}

# --- TMUX Configuration ---
tmux_config() {
    log_info "Configuring .tmux.conf..."
    
    CONFIG_TMUX="$(dirname "$0")/configs/.tmux.conf"

    if [ ! -f "$CONFIG_TMUX" ]; then
        log_error "Configuration file not found: $CONFIG_TMUX"
        exit 1
    fi

    cp --force "$CONFIG_TMUX" "${HOME}/.tmux.conf"

    log_success "Task Complete: .tmux.conf copied from configs."
}

# --- TMUX PLugins ---
tmux_plugins() {
    log_info "Installing tmux plugins..."

    # Install Tmux Package Manager
    if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        log_success "tpm plugin installed."
    else
        log_warn "tpm already installed. Skipping..."
    fi

    log_info "Fetching plugins..."
    
    # Start a detached session to ensure the server stays alive
    tmux new-session -d -s "temp_install"
    
    # Run the TPM installer
    "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
    
    # Source the config file
    tmux source-file "${HOME}/.tmux.conf"
    
    # Kill the temp session
    tmux kill-session -t "temp_install"

    log_success "All tmux plugins installed and sourced."
}

# --- Shell Setup ---
shell_setup() {
    log_info "Changing default shell to zsh..."
    chsh -s $(which zsh)
    log_success "Task Complete: Default shell changed to zsh."
}

# --- OpenVPN Install ---
openvpn_install() {
    log_info "Installing OpenVPN..."
    if command -v openvpn &> /dev/null; then
        log_warn "OpenVPN is already installed. Skipping..."
    else
        apt install -y openvpn
        log_success "Task Complete: OpenVPN installed."
    fi
}

# --- Flameshot Install ---
flameshot_install() {
    log_info "Installing Flameshot..."
    if command -v flameshot &> /dev/null; then
        log_warn "Flameshot is already installed. Skipping..."
    else
        apt install -y flameshot
        log_success "Task Complete: Flameshot installed."
    fi
}

# --- Bloodhound Install ---
bloodhound_install() {
    log_info "Installing Bloodhound..."
    if command -v bloodhound &> /dev/null; then
        log_warn "Bloodhound is already installed. Skipping..."
    else
        apt install -y bloodhound
        log_success "Task Complete: Bloodhound installed."
    fi
}

# --- Bloodhound Setup ---
bloodhound_setup() {
    log_info "Bloodhound setup..."

    # Neo4j must be running to change the default credentials
    log_info "Starting neo4j (first start initialises the database and is slow)..."
    systemctl start neo4j

    log_info "Waiting for neo4j to be ready..."
    for i in $(seq 1 36); do
        if curl -s -o /dev/null http://localhost:7474; then
            break
        fi
        if [ "$i" -eq 36 ]; then
            log_error "Timed out waiting for neo4j."
            exit 1
        fi
        sleep 5
    done

    # Change default neo4j credentials (a 401 means they have already been changed)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -u neo4j:neo4j \
        -H "Content-Type: application/json" \
        -X POST http://localhost:7474/user/neo4j/password \
        -d "{\"password\":\"${NEO4J_PASS}\"}")

    if [ "$HTTP_CODE" = "200" ]; then
        log_info "neo4j password changed."
    elif [ "$HTTP_CODE" = "401" ]; then
        log_warn "neo4j password already changed. Skipping..."
    else
        log_error "Failed to change neo4j password (HTTP ${HTTP_CODE})."
        exit 1
    fi

    # Credentials are already set, so answer any prompts with enter
    printf '\n\n\n' | bloodhound-setup

    # Reflect the new neo4j password in the bhapi config (neo4j block only)
    log_info "Updating /etc/bhapi/bhapi.json..."
    sed -i '/"neo4j": {/,/}/ s/"secret": "[^"]*"/"secret": "'"${NEO4J_PASS}"'"/' /etc/bhapi/bhapi.json

    if ! grep -A4 '"neo4j": {' /etc/bhapi/bhapi.json | grep -q "\"secret\": \"${NEO4J_PASS}\""; then
        log_error "Failed to update neo4j secret in /etc/bhapi/bhapi.json."
        exit 1
    fi

    log_success "Task Complete: Bloodhound installed and configured."
    log_info "Neo4j password: ${NEO4J_PASS} | Bloodhound login: admin / admin"
}

## --- Wordlist Downloads ---

# --- Rockyou Download ---
rockyou_download() {
    log_info "Downloading Rockyou..."
    if [ -f "/usr/share/wordlists/rockyou.txt" ]; then
        log_warn "Rockyou is already downloaded. Skipping..."
    elif [ -f "/usr/share/wordlists/rockyou.txt.gz" ]; then
        log_warn "Rockyou is already downloaded. Unzipping..."
        gunzip "/usr/share/wordlists/rockyou.txt.gz"
        log_success "Task Complete: Rockyou unzipped."
    else
        wget -O "/usr/share/wordlists/rockyou.txt.gz" https://weakpass.com/download/90/rockyou.txt.gz
        log_success "Task Complete: Rockyou downloaded."
        gunzip "/usr/share/wordlists/rockyou.txt.gz"
        log_success "Task Complete: Rockyou unzipped."
    fi
}

# --- SecLists Download ---
seclists_download() {
    log_info "Downloading SecLists..."
    if [ -d "/usr/share/wordlists/SecLists" ]; then
        log_warn "SecLists is already downloaded. Skipping..."
    else
        git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/SecLists
        log_success "Task Complete: SecLists downloaded."
    fi
}

# --- Complete Banner ---
end_banner() {
    log_success "INSTALLATION COMPLETE!"
    log_info "Killing tmux server... "
    log_warn "3"
    sleep 1
    log_warn "2"
    sleep 1
    log_warn "1"
    sleep 1
    tmux kill-server
    log_info "Closing terminal... "
    log_warn "3"
    sleep 1
    log_warn "2"
    sleep 1
    log_warn "1"
    sleep 1
    exit
}

# --- Main Execution ---
main() {
    # --- Banner ---
    banner
    # --- Package Installs ---
    system_prep
    grc_config
    git_install
    eza_install
    omz_install
    zsh_plugins
    zshrc_config
    tmux_config
    tmux_plugins
    shell_setup
    openvpn_install
    flameshot_install
    bloodhound_install
    bloodhound_setup
    # --- Wordlist Downloads ---
    rockyou_download
    seclists_download
    # --- Complete Banner ---
    end_banner
}

main
