#!/usr/bin/env bash
#
# setup.sh — Install OpenCode config guardrails and AgentMemory service
#
# Usage: ./scripts/setup.sh [-y|--yes]
#
# This script:
#   1. Checks prerequisites (opencode, agentmemory/npx)
#   2. Backs up existing ~/.config/opencode/ config (with confirmation)
#   3. Copies repo files to ~/.config/opencode/ (asks before overwriting)
#   4. Installs npm dependencies for plugins
#   5. Optionally sets up AgentMemory as a systemd user service
#   6. Configures AgentMemory LLM provider (optional)
#
# Idempotent: safe to run multiple times.
set -euo pipefail

# ─── Sourcing Guard ────────────────────────────────────────────────────────────
# Prevent the script from exiting the user's shell if sourced.

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "Error: This script must be executed, not sourced." >&2
    echo "Usage: ./scripts/setup.sh [-y|--yes]" >&2
    return 1
fi

# ─── Constants ───────────────────────────────────────────────────────────────

readonly CONFIG_DIR="$HOME/.config/opencode"
readonly SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"

# ─── Sudo Guard ────────────────────────────────────────────────────────────────

if [[ $EUID -eq 0 ]] && [[ -n "$SUDO_USER" ]]; then
    echo -e "\033[1;31m✗  Do not run this script with sudo.\033[0m" >&2
    echo -e "\033[0;36mℹ  Run it as your normal user without sudo.\033[0m"
    echo -e "\033[0;36mℹ  The script only modifies files in \$HOME and uses systemctl --user.\033[0m"
    exit 1
fi

# ─── Color Output ────────────────────────────────────────────────────────────

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

info()    { echo -e "${CYAN}ℹ  $*${RESET}"; }
success() { echo -e "${GREEN}✓  $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠  $*${RESET}"; }
error()   { echo -e "${RED}✗  $*${RESET}" >&2; }
header()  { echo -e "\n${BOLD}━━━ $* ━━━${RESET}\n"; }

# ─── CLI Options ──────────────────────────────────────────────────────────────

ASSUME_YES=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            ASSUME_YES=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            info "Usage: $0 [-y|--yes]"
            exit 1
            ;;
    esac
done

# ─── Summary Tracking ────────────────────────────────────────────────────────

SUMMARY_LINES=()

record_summary() {
    SUMMARY_LINES+=("$*")
}

# ─── check_prereqs ───────────────────────────────────────────────────────────
# Verify all required tools are available before proceeding.

check_prereqs() {
    header "Checking Prerequisites"

    local has_error=0

    # Check opencode
    if command -v opencode >/dev/null 2>&1; then
        success "opencode found: $(command -v opencode)"
        record_summary "opencode: $(command -v opencode)"
    else
        error "opencode is not installed or not in PATH"
        info "Install from https://opencode.ai"
        has_error=1
    fi

    # Check agentmemory availability (direct command or via npx)
    if command -v agentmemory >/dev/null 2>&1; then
        success "agentmemory found: $(command -v agentmemory)"
        record_summary "agentmemory: $(command -v agentmemory)"
    elif command -v npx >/dev/null 2>&1; then
        success "npx found (can run agentmemory via npx): $(command -v npx)"
        record_summary "agentmemory: available via npx ($(command -v npx))"
    else
        error "Neither agentmemory nor npx found in PATH"
        info "Install Node.js to use npx, or install agentmemory directly"
        has_error=1
    fi

    # Check bash version (need 4+ for arrays)
    local bash_version
    bash_version="${BASH_VERSION%%.*}"
    if (( bash_version < 4 )); then
        error "Bash 4+ required, found $BASH_VERSION"
        has_error=1
    else
        success "Bash version: $BASH_VERSION"
    fi

    if (( has_error )); then
        echo ""
        error "Prerequisites not met. Please install missing tools and try again."
        exit 1
    fi

    success "All prerequisites satisfied"
}

# ─── backup_existing ─────────────────────────────────────────────────────────
# If ~/.config/opencode/ exists, create a timestamped backup.

backup_existing() {
    header "Backing Up Existing Config"

    if [[ ! -d "$CONFIG_DIR" ]]; then
        info "No existing config at $CONFIG_DIR — nothing to back up"
        record_summary "backup: none needed (no existing config)"
        return 0
    fi

    # Skip prompt if --yes flag was passed
    if [[ "$ASSUME_YES" != "true" ]]; then
        echo -ne "${YELLOW}⚠  Existing config found at $CONFIG_DIR${RESET}\n"
        echo -ne "${YELLOW}   Back it up before overwriting? [Y/n]: ${RESET}"
        read -r response || true
        if [[ ! "$response" =~ ^[Yy]$ ]] && [[ -n "$response" ]]; then
            info "Skipping backup"
            record_summary "backup: skipped (user declined)"
            return 0
        fi
    fi

    local backup_dir="${CONFIG_DIR}.bak.${TIMESTAMP}"
    info "Creating backup at $backup_dir"

    if cp -a "$CONFIG_DIR" "$backup_dir"; then
        # Remove .git and node_modules from backup to keep it lean
        rm -rf "$backup_dir/.git" "$backup_dir/node_modules" 2>/dev/null || true
        success "Backup created: $backup_dir"
        record_summary "backup: $backup_dir"
    else
        error "Failed to create backup at $backup_dir"
        exit 1
    fi
}

# ─── copy_files ──────────────────────────────────────────────────────────────
# Copy repo files to ~/.config/opencode/, asking before overwriting conflicts.

copy_files() {
    header "Copying Files"

    # Ensure target directory exists
    mkdir -p "$CONFIG_DIR"

    local copied=0
    local skipped=0
    local overwritten=0
    local conflicts=0

    # Build list of files to copy (everything except .git, node_modules, scripts/)
    while IFS= read -r -d '' source_file; do
        # Compute relative path from repo root
        local relative_path="${source_file#$REPO_ROOT/}"

        # Skip the setup script itself — no need to copy it into config
        if [[ "$relative_path" == "scripts/setup.sh" ]]; then
            continue
        fi

        # Skip .git directory
        if [[ "$relative_path" == .git || "$relative_path" == .git/* ]]; then
            continue
        fi

        # Skip node_modules
        if [[ "$relative_path" == node_modules || "$relative_path" == node_modules/* ]]; then
            continue
        fi

        # Skip PLAN.md (internal implementation plan)
        if [[ "$relative_path" == "PLAN.md" ]]; then
            continue
        fi

        # Skip bun.lock, package-lock.json (build artifacts)
        if [[ "$relative_path" == "bun.lock" || "$relative_path" == "package-lock.json" ]]; then
            continue
        fi

        local target_file="$CONFIG_DIR/$relative_path"
        local target_dir
        target_dir="$(dirname "$target_file")"

        # Ensure target subdirectory exists
        mkdir -p "$target_dir"

        if [[ -f "$target_file" ]]; then
            # File exists — check if identical
            if cmp -s "$source_file" "$target_file"; then
                info "Identical, skipping: $relative_path"
                skipped=$(( skipped + 1 ))
                continue
            fi

            # File differs — overwrite (with prompt unless -y)
            conflicts=$(( conflicts + 1 ))
            if [[ "$ASSUME_YES" == "true" ]]; then
                # Non-interactive mode — auto-overwrite
                if cp -f "$source_file" "$target_file"; then
                    success "Overwritten: $relative_path"
                    overwritten=$(( overwritten + 1 ))
                else
                    error "Failed to overwrite: $relative_path"
                    exit 1
                fi
            else
                echo -ne "${YELLOW}⚠  File exists and differs: ${BOLD}$relative_path${RESET}\n"
                echo -ne "${YELLOW}   Overwrite? [Y/n]: ${RESET}"
                read -r response || true

                if [[ ! "$response" =~ ^[Nn]$ ]]; then
                    if cp -f "$source_file" "$target_file"; then
                        success "Overwritten: $relative_path"
                        overwritten=$(( overwritten + 1 ))
                    else
                        error "Failed to overwrite: $relative_path"
                        exit 1
                    fi
                else
                    info "Skipped: $relative_path"
                    skipped=$(( skipped + 1 ))
                fi
            fi
        else
            # File doesn't exist — copy it
            if cp -p "$source_file" "$target_file"; then
                success "Copied: $relative_path"
                copied=$(( copied + 1 ))
            else
                error "Failed to copy: $relative_path"
                exit 1
            fi
        fi
    done < <(find "$REPO_ROOT" -type f \
        -not -path '*/.git/*' \
        -not -path '*/node_modules/*' \
        -print0 | sort -z)

    echo ""
    success "Copy complete: $copied new, $overwritten overwritten, $skipped skipped ($conflicts conflicts)"
    record_summary "files: $copied new, $overwritten overwritten, $skipped skipped"
}

# ─── install_dependencies ────────────────────────────────────────────────────
# Install npm dependencies for plugins to work.

install_dependencies() {
    header "Installing Plugin Dependencies"

    local ran_install=0

    # Root package.json
    if [[ -f "$CONFIG_DIR/package.json" ]]; then
        info "Installing root dependencies..."
        if command -v yarn >/dev/null 2>&1; then
            if (cd "$CONFIG_DIR" && yarn install --frozen-lockfile 2>/dev/null); then
                success "Root dependencies installed (yarn)"
                ran_install=1
            elif (cd "$CONFIG_DIR" && yarn install 2>/dev/null); then
                success "Root dependencies installed (yarn)"
                ran_install=1
            fi
        elif command -v npm >/dev/null 2>&1; then
            if (cd "$CONFIG_DIR" && npm install 2>&1); then
                success "Root dependencies installed (npm)"
                ran_install=1
            fi
        fi

        if (( ran_install == 0 )); then
            if command -v yarn >/dev/null 2>&1 || command -v npm >/dev/null 2>&1; then
                warn "Dependency installation failed — check permissions and network"
                info "Run 'yarn install' manually in $CONFIG_DIR"
            else
                warn "Could not install dependencies — no yarn or npm found"
                info "Install yarn or npm, then run 'yarn install' in $CONFIG_DIR"
            fi
        fi
    fi

    # profiles/ws/package.json
    local ws_pkg="$CONFIG_DIR/profiles/ws/package.json"
    if [[ -f "$ws_pkg" ]]; then
        info "Installing workspace profile dependencies..."
        if command -v yarn >/dev/null 2>&1; then
            if (cd "$CONFIG_DIR/profiles/ws" && yarn install 2>/dev/null); then
                success "Workspace profile dependencies installed (yarn)"
                ran_install=1
            fi
        elif command -v npm >/dev/null 2>&1; then
            if (cd "$CONFIG_DIR/profiles/ws" && npm install 2>&1); then
                success "Workspace profile dependencies installed (npm)"
                ran_install=1
            fi
        else
            # No warning needed — root block already warned about missing package manager
            :
        fi
    fi

    if (( ran_install == 0 )); then
        if [[ ! -f "$CONFIG_DIR/package.json" ]] && [[ ! -f "$CONFIG_DIR/profiles/ws/package.json" ]]; then
            warn "No package.json found — skipping dependency installation"
            record_summary "dependencies: none to install"
        else
            # Package.json exists but install failed or no package manager
            record_summary "dependencies: not installed (no package manager or install failed)"
        fi
    else
        record_summary "dependencies: installed"
    fi
}

# ─── setup_systemd ───────────────────────────────────────────────────────────
# Set up AgentMemory as a systemd user service using the template.

setup_systemd() {
    header "AgentMemory Systemd Service"

    # Detect if systemd --user is actually running
    local systemd_available=false
    if systemctl --user status >/dev/null 2>&1; then
        systemd_available=true
    fi

    if [[ "$systemd_available" != "true" ]]; then
        warn "systemd --user is not currently available"
        info "The service file can still be created for future use."
        info "This is normal on WSL, containers, macOS, or non-systemd systems."
    fi

    # In non-interactive mode, skip
    if [[ "$ASSUME_YES" == "true" ]]; then
        info "Non-interactive mode — skipping systemd setup"
        record_summary "systemd: skipped (non-interactive mode)"
        return 0
    fi

    # Ask user if they want to set up the service
    echo -ne "${CYAN}ℹ  Set up AgentMemory as a systemd user service? [y/N]: ${RESET}"
    read -r response || true

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Skipping systemd setup"
        record_summary "systemd: skipped (user declined)"
        return 0
    fi

    local template_file="$REPO_ROOT/templates/agentmemory.service.tmpl"

    # Check template exists
    if [[ ! -f "$template_file" ]]; then
        error "Service template not found: $template_file"
        exit 1
    fi

    # Resolve agentmemory binary path
    local agentmemory_path
    local agentmemory_extra_env=""
    if command -v agentmemory >/dev/null 2>&1; then
        agentmemory_path="$(command -v agentmemory)"
    elif command -v npx >/dev/null 2>&1; then
        local npx_bin
        npx_bin="$(command -v npx)"
        agentmemory_path="$npx_bin @agentmemory/agentmemory"

        # npx is a Node.js script (shebang: #!/usr/bin/env node).
        # systemd --user has a minimal PATH that typically doesn't
        # include NVM/npm/node installation directories. Inject the
        # node bin directory so the shebang resolves correctly.
        local node_bin_dir
        node_bin_dir="$(dirname "$npx_bin")"
        agentmemory_extra_env="Environment=PATH=$node_bin_dir:/usr/local/bin:/usr/bin:/bin"
    else
        error "agentmemory binary not found — cannot generate service file"
        exit 1
    fi

    # Replace {{HOME}}, {{AGENTMEMORY_PATH}}, and {{AGENTMEMORY_EXTRA_ENV}} placeholders and write service file
    info "Generating service file with:"
    info "  HOME: $HOME"
    info "  AGENTMEMORY_PATH: $agentmemory_path"

    # Ensure systemd user directory exists
    mkdir -p "$SYSTEMD_USER_DIR"

    local service_file="$SYSTEMD_USER_DIR/agentmemory.service"

    sed \
        -e "s|{{HOME}}|$HOME|g" \
        -e "s|{{AGENTMEMORY_PATH}}|$agentmemory_path|g" \
        -e "s|{{AGENTMEMORY_EXTRA_ENV}}|$agentmemory_extra_env|g" \
        "$template_file" > "$service_file"

    success "Service file created: $service_file"

    # Reload systemd and enable/start the service (if systemd is available)
    if [[ "$systemd_available" == "true" ]]; then
        info "Reloading systemd daemon..."
        if systemctl --user daemon-reload; then
            success "Daemon reloaded"
        else
            error "Failed to reload systemd daemon"
            exit 1
        fi

        info "Enabling and starting agentmemory service..."
        if systemctl --user enable --now agentmemory.service; then
            success "AgentMemory service enabled and started"
            record_summary "systemd: service enabled and running"
        else
            warn "Failed to start service — you may need to start it manually:"
            info "  systemctl --user start agentmemory.service"
            record_summary "systemd: service file created but failed to start"
        fi

        # Show service status
        echo ""
        info "Service status:"
        systemctl --user status agentmemory.service --no-pager -l || true
    else
        success "Service file created at $service_file"
        info "To enable it later when systemd is available, run:"
        info "  systemctl --user daemon-reload"
        info "  systemctl --user enable --now agentmemory.service"
        record_summary "systemd: service file created (systemd not available to start)"
    fi
}

# ─── configure_agentmemory_env ───────────────────────────────────────────────
# Prompt to create ~/.config/agentmemory/.env with an API key.

configure_agentmemory_env() {
    header "AgentMemory Environment Configuration"

    local env_dir="$HOME/.config/agentmemory"
    local env_file="$env_dir/.env"

    # Skip if already configured and --yes not set
    if [[ -f "$env_file" ]] && [[ "$ASSUME_YES" != "true" ]]; then
        info "AgentMemory config already exists at $env_file"
        echo -ne "${CYAN}ℹ  Override? [y/N]: ${RESET}"
        read -r response || true
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            info "Skipping agentmemory configuration"
            record_summary "agentmemory: skipped (existing config kept)"
            return 0
        fi
    fi

    # In non-interactive mode, skip
    if [[ "$ASSUME_YES" == "true" ]]; then
        info "Non-interactive mode — skipping agentmemory .env setup"
        info "Create $env_file manually with your LLM API key"
        record_summary "agentmemory: skipped (non-interactive mode)"
        return 0
    fi

    echo -ne "${CYAN}ℹ  Configure AgentMemory with an LLM API key? [y/N]: ${RESET}"
    read -r response || true
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Skipping agentmemory configuration"
        record_summary "agentmemory: skipped (user declined)"
        return 0
    fi

    # Show provider choices
    echo ""
    info "Select your LLM provider:"
    echo "  1) OpenAI  (OPENAI_API_KEY)"
    echo "  2) Anthropic (ANTHROPIC_API_KEY)"
    echo "  3) Google  (GOOGLE_API_KEY)"
    echo "  4) Ollama  (OLLAMA_BASE_URL — local, no key needed)"
    echo -ne "${CYAN}   Choice [1-4]: ${RESET}"
    read -r choice || true

    mkdir -p "$env_dir"

    case "$choice" in
        1)
            echo -ne "${CYAN}   Enter your OpenAI API key: ${RESET}"
            read -r api_key || true
            if [[ -n "$api_key" ]]; then
                echo "OPENAI_API_KEY=$api_key" > "$env_file"
                chmod 600 "$env_file"
                success "AgentMemory configured with OpenAI"
                record_summary "agentmemory: configured with OpenAI"
            else
                warn "No key entered — skipping"
                record_summary "agentmemory: skipped (no key)"
            fi
            ;;
        2)
            echo -ne "${CYAN}   Enter your Anthropic API key: ${RESET}"
            read -r api_key || true
            if [[ -n "$api_key" ]]; then
                echo "ANTHROPIC_API_KEY=$api_key" > "$env_file"
                chmod 600 "$env_file"
                success "AgentMemory configured with Anthropic"
                record_summary "agentmemory: configured with Anthropic"
            else
                warn "No key entered — skipping"
                record_summary "agentmemory: skipped (no key)"
            fi
            ;;
        3)
            echo -ne "${CYAN}   Enter your Google API key: ${RESET}"
            read -r api_key || true
            if [[ -n "$api_key" ]]; then
                echo "GOOGLE_API_KEY=$api_key" > "$env_file"
                chmod 600 "$env_file"
                success "AgentMemory configured with Google"
                record_summary "agentmemory: configured with Google"
            else
                warn "No key entered — skipping"
                record_summary "agentmemory: skipped (no key)"
            fi
            ;;
        4)
            echo -ne "${CYAN}   Enter your Ollama base URL [http://localhost:11434]: ${RESET}"
            read -r ollama_url || true
            if [[ -z "$ollama_url" ]]; then
                ollama_url="http://localhost:11434"
            fi
            echo "OLLAMA_BASE_URL=$ollama_url" > "$env_file"
            chmod 600 "$env_file"
            success "AgentMemory configured with Ollama: $ollama_url"
            record_summary "agentmemory: configured with Ollama"
            ;;
        *)
            warn "Invalid choice — skipping"
            record_summary "agentmemory: skipped (invalid choice)"
            ;;
    esac
}

# ─── print_summary ───────────────────────────────────────────────────────────
# Print a summary of everything that was done.

print_summary() {
    header "Setup Summary"

    echo -e "${BOLD}What was done:${RESET}"
    for line in "${SUMMARY_LINES[@]}"; do
        echo -e "  ${CYAN}•${RESET} $line"
    done

    echo ""
    echo -e "${BOLD}Next steps:${RESET}"
    echo -e "  1. Review config at ${CYAN}$CONFIG_DIR${RESET}"
    echo -e "  2. Launch opencode to use the new guardrails"
    echo -e "  3. If dependencies were skipped, run 'cd $CONFIG_DIR && yarn install' (needed for plugins)"
    echo -e "  4. If systemd was skipped, run agentmemory manually when needed"
    echo -e "  5. If AgentMemory LLM was not configured, run agentmemory configure or edit $HOME/.config/agentmemory/.env"
    echo ""
    success "Setup complete!"
}

# ─── main ────────────────────────────────────────────────────────────────────

main() {
    header "OpenCode Config Setup"
    info "Repository: $REPO_ROOT"
    info "Target: $CONFIG_DIR"
    info "Timestamp: $TIMESTAMP"
    echo ""

    check_prereqs
    backup_existing
    copy_files
    install_dependencies
    setup_systemd
    configure_agentmemory_env
    print_summary

    exit 0
}

main "$@"
