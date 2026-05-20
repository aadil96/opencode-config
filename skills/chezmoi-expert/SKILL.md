---
name: chezmoi-expert
description: Expert chezmoi dotfiles manager skill. Handles Go templates (.tmpl), hooks (chezmoi.toml), secrets via promptString, and multi-machine config (WSL2, Pi K3s clusters). Idempotent by design.
keywords: ["chezmoi", "dotfiles", "templates", "hooks", "sprig", "multi-machine"]
---

# Chezmoi Expert

Comprehensive skill for managing dotfiles with chezmoi. All operations are idempotent and safe.

## Safety Rules

**ABSOLUTE REQUIREMENTS — NEVER SKIP:**

| Rule | Why | Exception |
|------|-----|-----------|
| `chezmoi status` before ANY apply | Preview exact changes before modification | None |
| `chezmoi diff` before apply | See precise file changes line-by-line | None |
| **NEVER use `--force`** | Overwrites without preview, destroys work | Never ever |
| **NEVER use `--force`** | See above | Seriously, never |
| Test on single machine first | `.chezmoi.*` templates vary by host | Use `chezmoi execute-template` |
| Backup before bulk changes | `chezmoi archive` creates restore point | `tar czf chezmoi-backup-$(date +%Y%m%d).tar.gz ~/.local/share/chezmoi` |

**Safe Workflow:**
```bash
# 1. Preview what would change
chezmoi status

# 2. See exact diff
chezmoi diff

# 3. Apply only if diff looks correct
chezmoi apply

# 4. On new machine, always init first
chezmoi init --source=$HOME/.local/share/chezmoi
chezmoi apply
```

## Command Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `chezmoi init` | Initialize chezmoi on a new machine | `chezmoi init --source=$HOME/.local/share/chezmoi` |
| `chezmoi apply` | Apply all dotfiles to `$HOME` | `chezmoi apply` |
| `chezmoi status` | Show what would change (always run first) | `chezmoi status` |
| `chezmoi diff` | Show exact changes as unified diff | `chezmoi diff` |
| `chezmoi add <file>` | Add existing file to source state | `chezmoi add ~/.bashrc` |
| `chezmoi edit <file>` | Edit file in source state | `chezmoi edit ~/.zshrc` |
| `chezmoi remove <file>` | Remove file from source state | `chezmoi remove ~/.obsolete` |
| `chezmoi archive` | Create tar archive of managed files | `chezmoi archive -o backup.tar.gz` |
| `chezmoi cat <file>` | Print file content from source state | `chezmoi cat ~/.bashrc` |
| `chezmoi execute-template` | Render template without applying | `chezmoi execute-template < ~/.config/template.tmpl` |
| `chezmoi dump-config` | Print parsed configuration | `chezmoi dump-config` |
| `chezmoi data` | Print template data as JSON | `chezmoi data` |
| `chezmoi doctor` | Check for common issues | `chezmoi doctor` |
| `chezmoi update` | Pull latest changes from git and apply | `chezmoi update` |

### Useful Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `--dry-run` | Preview without applying (same as `status`) | `chezmoi apply --dry-run` |
| `--source=<path>` | Use custom source directory | `chezmoi apply --source=/path/to/dotfiles` |
| `--destination=<path>` | Apply to custom destination | `chezmoi apply --destination=/tmp/test` |
| `-v` / `--verbose` | Verbose output | `chezmoi apply -v` |
| `-n` / `--dry-run` | Dry run (combine with `-v` for details) | `chezmoi apply -nv` |

## Templates Deep Dive

Chezmoi uses **Go text/template** with **Sprig v3 functions**. All `.tmpl` files are rendered at apply time.

### Template Directives

```tmpl
{{ .chezmoi.os }}              # Current OS: linux, darwin, windows
{{ .chezmoi.arch }}            # CPU arch: amd64, arm64
{{ .chezmoi.hostname }}       # Current hostname
{{ .chezmoi.username }}       # Current username
{{ .chezmoi.homeDir }}        # User home directory
{{ .chezmoi.homeDir }}        # Alias for homeDir
{{ .chezmoi.sourceDir }}     # Source directory
{{ .chezmoi.cacheDir }}       # Cache directory
{{ .chezmoi.config }}        # Config directory

{{/* Comment (removed from output) */}}
{{- "text" }}                  # Trim leading/trailing whitespace
{{ "text" -}}                  # Trim trailing whitespace
{{ printf "%s" "value" }}      # Printf-style formatting
```

### Common Sprig Functions

```tmpl
# String functions
{{ .chezmoi.hostname | upper }}
{{ .chezmoi.hostname | lower }}
{{ .chezmoi.username | title }}

# Math
{{ add 1 2 }}                 # → 3
{{ sub 10 3 }}                # → 7
{{ mul 6 7 }}                # → 42

# Date/time
{{ now | date "2006-01-02" }}
{{ now | date "2006-01-02T15:04:05Z07:00" }}

# Encoding
{{ "secret" | b64enc }}        # Base64 encode
{{ "c2VjcmV0" | b64dec }}     # Base64 decode

# Cryptographic
{{ "password" | sha256sum }}

# Encoding (hex)
{{ "text" | toJson }}
{{ "text" | toYaml }}

# Default value
{{ .chezmoi.hostname | default "unknown-hostname" }}

# Lookup environment
{{ lookPath "bash" }}          # Returns path or empty string
{{ lookPath "zsh" | quote }}   # Returns quoted path

# Conditionals
{{ if eq .chezmoi.os "linux" }}
  # Linux-specific content
{{ else if eq .chezmoi.os "darwin" }}
  # macOS-specific content
{{ end }}

{{ if contains "foo" .chezmoi.hostname }}
  # Hostname contains "foo"
{{ end }}
```

### Host-Specific Files

```tmpl
# dot_zshrc.tmpl — works on all machines
export HISTSIZE=10000
export SAVEHIST=10000

# dot_zshrc.tmpl file exists alongside:
#   dot_zshrc-windows.tmpl
#   dot_zshrc-linux.tmpl
#   dot_zshrc-darwin.tmpl
#   dot_zshrc-hostname-worker1.tmpl
```

### Machine Stanzas Example

```tmpl
# ~/.config/zsh/env.zsh.tmpl

# Shared config for all machines
export EDITOR={{ if lookPath "nvim" }}"nvim"{{ else }}"vi"{{ end }}
export VISUAL=$EDITOR
export PAGER={{ if lookPath "less" }}"less"{{ else }}"more"{{ end }}

# WSL2-specific configuration
{{- if contains "wsl" .chezmoi.hostname }}
export WSL=1
export DISPLAY=:0
export LIBGL_ALWAYS_INDIRECT=1
# Windows-mounted home has performance quirks
export ZDOTDIR=$HOME/.config/zsh
{{- end }}

# Raspberry Pi K3s cluster nodes
{{- if or (hasPrefix "k3s-" .chezmoi.hostname) (hasPrefix "pi" .chezmoi.hostname) }}
export K3S_NODE=1
export KUBECONFIG=$HOME/.kube/config
export KUBECTL_CONTEXT=k3s-{{ .chezmoi.hostname }}
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
{{- end }}

# Development workstation
{{- if eq .chezmoi.hostname "workstation" }}
export DEV_MODE=1
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
{{- end }}
```

### Directives in Files

Place these at the very top of source files (before any content):

```tmpl
{{- /* archlinux */}}
Install on Arch Linux only.

{{- /* localizable */}}
Include in archive but don't apply.
```

## Hooks Configuration

Hooks are defined in `.chezmoi.toml.tmpl` (or `chezmoi.toml` in config directory).

### TOML Format

```toml
{{- if .chezmoi.os }}
[hooks]
{{ end }}

# Run after every apply
apply.post = [
  "echo '✅ chezmoi apply complete'",
  "systemctl --user daemon-reload 2>/dev/null || true",
]

# Run before init
init.before = [
  "echo '🔧 Initializing chezmoi...'",
]

# Run after init completes
init.after = [
  "echo '🎉 chezmoi initialized!'",
  "{{ lookPath "git" }} config --global core.editor {{ if lookPath "nvim" }}nvim{{ else }}vim{{ end }}",
]

# On new machine setup
init.promptString = [
  "email: 'Enter your git email: '",
  "github_token: 'GitHub Personal Access Token (leave empty to skip): '",
]

# Specific file apply hooks
[fileFetcher]
# Hook when extracting archives
archive.extract.pre = ["echo '📦 Extracting archive...'"]

# Cleanup hooks
remove.before = [
  "echo '⚠️  Removing managed file...'",
]

# Update hooks (chezmoi update)
update.before = [
  "echo '📥 Pulling latest dotfiles...'",
]
```

### Template Variables for Secrets

```toml
{{- if .email | default "" | ne "" }}
[git]
email = "{{ .email }}"
name = "{{ .chezmoi.username }}"
{{- end }}

{{- /* Example: github_token placeholder for demo purposes */}}
{{- if .github_token | default "" | ne "" }}
[url "https://{{ .github_token }}@github.com/"]
  insteadOf = https://github.com/
{{- end }}
```

## Advanced Configuration

### Multi-Machine with Git

```tmpl
# In .chezmoi.toml.tmpl
[git]
  autoCommit = true
  autoPush = false   # Always review before push!
```

### External Tools Integration

```tmpl
# Use chezmoi with mise (runtime version manager)
{{- if lookPath "mise" }}
# Run commands through mise to ensure correct versions
alias shfmt="mise exec -- shfmt@latest -- --diff"
alias lua-format="mise exec -- lua-language-server@latest -- format"
{{- end }}

# Use chezmoi with devbox
{{- if lookPath "devbox" }}
eval "$(devbox generate gitignore --pure)"
{{- end }}
```

### Secrets with promptString

In `.chezmoi.toml.tmpl`:

```toml
[prompt]
{{ if not .email }}
email = { type = "string", prompt = "Git email address" }
{{ end }}
{{ if not .github_token }}
github_token = { type = "string", prompt = "GitHub Personal Access Token" }
{{ end }}
```

In templates, reference prompt values:

```tmpl
{{- if .email }}
[url "https://{{ .email }}@github.com/"]
  insteadOf = https://github.com/
{{- end }}
```

### K3s Cluster Node Setup

```tmpl
# dot_config/mise/mise.toml.tmpl
{{- if hasPrefix "k3s-" .chezmoi.hostname }}

[settings]
experimental = true

[tools]
kubectl = "latest"
helm = "latest"
k9s = "latest"
flux = "latest"

{{ else if eq .chezmoi.hostname "dev-workstation" }}

[tools]
node = "lts"
go = "latest"
python = "3.12"

{{- end }}
```

### WSL2 Specific Configuration

```tmpl
# dot_bashrc.tmpl
{{- if contains "wsl" .chezmoi.hostname }}

# WSL2 specific
export WSL=1
export WSL_DISTRO_NAME={{ .chezmoi.hostname }}

# Faster file watching for development
export CHOKIDAR_USEPOLLING=1

# Use Windows PATH additions
export PATH=$PATH:/mnt/c/Windows:/mnt/c/Program\ Files/Git/cmd

# Clipboard integration
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -c "Get-Clipboard"'

# Windows-mounted workspace
export WORKSPACE=/mnt/c/Users/$USER/workspace

{{- end }}
```

## Quick Reference

| What | How |
|------|-----|
| Check what would change | `chezmoi status` |
| See exact diff | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Render template preview | `chezmoi execute-template < file.tmpl` |
| List all template vars | `chezmoi data \| jq` |
| Initialize new machine | `chezmoi init --source=$HOME/.local/share/chezmoi` |
| Update from git | `chezmoi update` |
| Backup managed files | `chezmoi archive -o backup.tar.gz` |

## References

- [Command Overview](https://www.chezmoi.io/user-guide/command-overview/)
- [Configuration Reference](https://www.chezmoi.io/reference/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
