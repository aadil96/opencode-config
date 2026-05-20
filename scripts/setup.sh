#!/usr/bin/env bash
#
# setup.sh — Install OpenCode config guardrails and AgentMemory service
#
# Usage: ./scripts/setup.sh
#
# This script:
#   1. Checks prerequisites (opencode, agentmemory/npx)
#   2. Backs up existing ~/.config/opencode/ config
#   3. Copies repo files to ~/.config/opencode/ (asks before overwriting)
#   4. Optionally sets up AgentMemory as a systemd user service
#
# Idempotent: safe to run multiple times.
set -euo pipefail

# ─── Constants ───────────────────────────────────────────────────────────────

readonly CONFIG_DIR="$HOME/.config/opencode"
readonly SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"

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

    local backup_dir="${CONFIG_DIR}.bak.${TIMESTAMP}"

    info "Existing config found at $CONFIG_DIR"
    info "Creating backup at $backup_dir"

    if cp -a "$CONFIG_DIR" "$backup_dir"; then
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
                (( skipped++ ))
                continue
            fi

            # File differs — ask before overwriting
            (( conflicts++ ))
            echo -ne "${YELLOW}⚠  File exists and differs: ${BOLD}$relative_path${RESET}\n"
            echo -ne "${YELLOW}   Overwrite? [y/N]: ${RESET}"
            read -r response || true

            if [[ "$response" =~ ^[Yy]$ ]]; then
                if cp -f "$source_file" "$target_file"; then
                    success "Overwritten: $relative_path"
                    (( overwritten++ ))
                else
                    error "Failed to overwrite: $relative_path"
                    exit 1
                fi
            else
                info "Skipped: $relative_path"
                (( skipped++ ))
            fi
        else
            # File doesn't exist — copy it
            if cp -p "$source_file" "$target_file"; then
                success "Copied: $relative_path"
                (( copied++ ))
            else
                error "Failed to copy: $relative_path"
                exit 1
            fi
        fi
    done < <(find "$REPO_ROOT" -type f -not -path '*/.git/*' -print0 | sort -z)

    echo ""
    success "Copy complete: $copied new, $overwritten overwritten, $skipped skipped ($conflicts conflicts)"
    record_summary "files: $copied new, $overwritten overwritten, $skipped skipped"
}

# ─── setup_systemd ───────────────────────────────────────────────────────────
# Set up AgentMemory as a systemd user service using the template.

setup_systemd() {
    header "AgentMemory Systemd Service"

    # Check if systemd --user is available
    if ! systemctl --user status >/dev/null 2>&1; then
        warn "systemd --user is not available"
        info "This is normal on WSL, containers, or non-systemd systems"
        info "You can skip this step and run agentmemory manually when needed"
        record_summary "systemd: not available (skipped)"
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
    if command -v agentmemory >/dev/null 2>&1; then
        agentmemory_path="$(command -v agentmemory)"
    elif command -v npx >/dev/null 2>&1; then
        agentmemory_path="$(command -v npx) @agentmemory/agentmemory"
    else
        error "agentmemory binary not found — cannot generate service file"
        exit 1
    fi

    # Replace {{HOME}} and {{AGENTMEMORY_PATH}} placeholders and write service file
    info "Generating service file with:"
    info "  HOME: $HOME"
    info "  AGENTMEMORY_PATH: $agentmemory_path"

    # Ensure systemd user directory exists
    mkdir -p "$SYSTEMD_USER_DIR"

    local service_file="$SYSTEMD_USER_DIR/agentmemory.service"

    sed \
        -e "s|{{HOME}}|$HOME|g" \
        -e "s|{{AGENTMEMORY_PATH}}|$agentmemory_path|g" \
        "$template_file" > "$service_file"

    success "Service file created: $service_file"

    # Reload systemd and enable/start the service
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
    echo -e "  3. If systemd was skipped, run agentmemory manually when needed"
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
    setup_systemd
    print_summary

    exit 0
}

main "$@"
