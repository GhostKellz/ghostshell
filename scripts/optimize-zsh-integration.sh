#!/bin/bash
# Ghostshell Zsh Integration Optimization Script
# Optimizes Zsh shell integration for PowerLevel10k, Oh My Zsh, and modern features

set -e

GHOSTSHELL_CONFIG_DIR="$HOME/.config/ghostshell"
GHOSTSHELL_CONFIG="$GHOSTSHELL_CONFIG_DIR/config"
ZSH_CONFIG="$HOME/.zshrc"
BACKUP_SUFFIX="$(date +%Y%m%d_%H%M%S)"

echo "🔧 Optimizing Ghostshell Zsh integration..."

# Create config directory if it doesn't exist
mkdir -p "$GHOSTSHELL_CONFIG_DIR"

# Detect Zsh environment and features
detect_zsh_framework() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "oh-my-zsh"
    elif [[ -n "$ZSH_THEME" ]] && [[ "$ZSH_THEME" == *"powerlevel10k"* ]]; then
        echo "powerlevel10k"
    elif grep -q "prezto" "$ZSH_CONFIG" 2>/dev/null; then
        echo "prezto"
    elif grep -q "starship" "$ZSH_CONFIG" 2>/dev/null; then
        echo "starship"
    else
        echo "vanilla"
    fi
}

detect_zsh_plugins() {
    local plugins=()
    
    if [[ -f "$ZSH_CONFIG" ]]; then
        grep -q "zsh-autosuggestions" "$ZSH_CONFIG" && plugins+=("autosuggestions")
        grep -q "zsh-syntax-highlighting" "$ZSH_CONFIG" && plugins+=("syntax-highlighting")
        grep -q "zsh-completions" "$ZSH_CONFIG" && plugins+=("completions")
        grep -q "fast-syntax-highlighting" "$ZSH_CONFIG" && plugins+=("fast-syntax-highlighting")
        grep -q "zsh-history-substring-search" "$ZSH_CONFIG" && plugins+=("history-search")
        grep -q "powerlevel10k" "$ZSH_CONFIG" && plugins+=("powerlevel10k")
    fi
    
    printf '%s\n' "${plugins[@]}"
}

get_zsh_version() {
    if command -v zsh >/dev/null 2>&1; then
        zsh --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
    else
        echo "unknown"
    fi
}

# Environment detection
echo ""
echo "🔍 Detecting Zsh environment..."

if ! command -v zsh >/dev/null 2>&1; then
    echo "❌ Zsh not found. Please install Zsh first."
    exit 1
fi

ZSH_VERSION=$(get_zsh_version)
ZSH_FRAMEWORK=$(detect_zsh_framework)
ZSH_PLUGINS=($(detect_zsh_plugins))

echo "✅ Zsh detected: version $ZSH_VERSION"
echo "✅ Framework: $ZSH_FRAMEWORK"
if [[ ${#ZSH_PLUGINS[@]} -gt 0 ]]; then
    echo "✅ Plugins: ${ZSH_PLUGINS[*]}"
else
    echo "ℹ️  No common plugins detected"
fi

# Create enhanced Zsh configuration for Ghostshell
echo ""
echo "⚙️  Optimizing Ghostshell configuration for Zsh..."

# Backup existing config
if [[ -f "$GHOSTSHELL_CONFIG" ]]; then
    cp "$GHOSTSHELL_CONFIG" "$GHOSTSHELL_CONFIG.backup.$BACKUP_SUFFIX"
    echo "📦 Backed up existing config"
fi

# Generate Zsh-optimized configuration
cat > "$GHOSTSHELL_CONFIG" << EOF
# Ghostshell Zsh-Optimized Configuration
# Generated on $(date) by optimize-zsh-integration.sh
# Zsh version: $ZSH_VERSION, Framework: $ZSH_FRAMEWORK

EOF

# Shell integration settings
cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === ZSH SHELL INTEGRATION ===
shell-integration = zsh
shell-integration-features = cursor,sudo,title,jump

# Terminal identification
term = xterm-ghostshell

EOF

# Framework-specific optimizations
case "$ZSH_FRAMEWORK" in
    "oh-my-zsh"|"powerlevel10k")
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === OH MY ZSH / POWERLEVEL10K OPTIMIZATIONS ===

# Font optimizations for PowerLevel10k
font-family = "MesloLGS NF"
font-size = 12
font-feature = +liga
font-feature = +calt
font-feature = +kern
font-thicken = true

# Performance optimizations for complex prompts
fps-cap = 120
scrollback-limit = 100000
window-vsync = true

# Cursor optimizations for prompt responsiveness
cursor-style = beam
cursor-style-blink = false

EOF
        ;;
    "starship")
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === STARSHIP OPTIMIZATIONS ===

# Nerd Font for Starship symbols
font-family = "JetBrainsMono Nerd Font"
font-size = 12
font-feature = +liga

# Performance for Starship prompt
fps-cap = 60
scrollback-limit = 50000

EOF
        ;;
    *)
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === VANILLA ZSH OPTIMIZATIONS ===

# Standard font configuration
font-family = "monospace"
font-size = 12

# Basic performance settings
fps-cap = 60
scrollback-limit = 50000

EOF
        ;;
esac

# Plugin-specific optimizations
if printf '%s\n' "${ZSH_PLUGINS[@]}" | grep -q "syntax-highlighting\|fast-syntax-highlighting"; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === SYNTAX HIGHLIGHTING OPTIMIZATIONS ===

# Performance tweaks for syntax highlighting
window-vsync = true
unfocused-split-opacity = 0.8

# Reduce input latency
keyboard-layout = "auto"

EOF
fi

if printf '%s\n' "${ZSH_PLUGINS[@]}" | grep -q "autosuggestions"; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === AUTOSUGGESTIONS OPTIMIZATIONS ===

# Clear display for suggestion text
foreground = #f8f8f2
background = #282a36

# Ensure good contrast for suggestions
palette = 8=#44475a

EOF
fi

# Universal Zsh optimizations
cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === UNIVERSAL ZSH OPTIMIZATIONS ===

# Working directory integration
working-directory = inherit
window-inherit-working-directory = true

# Copy/paste enhancements
copy-on-select = true
click-to-focus = true

# Window behavior
window-decoration = true
window-theme = auto

# Performance settings
vsync = true
window-padding-x = 2
window-padding-y = 2

# Terminal features
confirm-close-surface = false
quit-after-last-window-closed = true

EOF

# Create Zsh integration enhancement script
echo ""
echo "📝 Creating Zsh integration enhancements..."

cat > "$GHOSTSHELL_CONFIG_DIR/zsh-enhancements.zsh" << 'EOF'
# Ghostshell Zsh Integration Enhancements
# Add this to your .zshrc for enhanced Ghostshell integration

# Enhanced Ghostshell integration if available
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostshell-integration"
fi

# PowerLevel10k optimization
if [[ "$ZSH_THEME" == *"powerlevel10k"* ]] || [[ -f "$HOME/.p10k.zsh" ]]; then
    # Optimize prompt rendering
    export POWERLEVEL9K_INSTANT_PROMPT=quiet
    export POWERLEVEL9K_DISABLE_GITSTATUS=false
    
    # Terminal integration
    export POWERLEVEL9K_TERM_SHELL_INTEGRATION=true
fi

# Enhanced history for Ghostshell
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE="$HOME/.zsh_history"

# Ghostshell-specific aliases
alias gs='ghostshell'
alias gsc='ghostshell --config'
alias gst='ghostshell --theme'

# Enhanced directory navigation with Ghostshell integration
if command -v ghostshell >/dev/null 2>&1; then
    # Function to open new Ghostshell window in current directory
    gshere() {
        ghostshell --working-directory="$PWD" &
    }
    
    # Function to open new Ghostshell tab
    gstab() {
        printf '\e]0;ghostshell\a'
    }
fi

# Performance optimizations for large directories
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS

# Enhanced completion for better performance
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

EOF

# Create installation instructions
echo ""
echo "📋 Creating integration setup..."

cat > "$GHOSTSHELL_CONFIG_DIR/INSTALL_ZSH_INTEGRATION.md" << 'EOF'
# Ghostshell Zsh Integration Setup

## Automatic Integration

Add this line to your `.zshrc` for automatic Ghostshell integration:

```bash
# Ghostshell integration
[[ -f "$HOME/.config/ghostshell/zsh-enhancements.zsh" ]] && source "$HOME/.config/ghostshell/zsh-enhancements.zsh"
```

## Manual Integration Steps

1. **Copy configuration**:
   ```bash
   cp ~/.config/ghostshell/config.backup.* ~/.config/ghostshell/config
   ```

2. **Enable shell integration** in your `.zshrc`:
   ```bash
   # Add to ~/.zshrc
   if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
     source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostshell-integration"
   fi
   ```

3. **PowerLevel10k users** - add to `.zshrc`:
   ```bash
   export POWERLEVEL9K_TERM_SHELL_INTEGRATION=true
   export POWERLEVEL9K_INSTANT_PROMPT=quiet
   ```

4. **Reload Zsh**:
   ```bash
   source ~/.zshrc
   ```

## Features Enabled

- ✅ OSC 133 semantic markup
- ✅ Working directory tracking  
- ✅ Window title updates
- ✅ PowerLevel10k optimizations
- ✅ Enhanced copy/paste
- ✅ Performance optimizations
- ✅ Plugin compatibility

## Troubleshooting

If you experience issues:

1. Check Zsh version: `zsh --version` (5.8+ recommended)
2. Verify integration: `echo $GHOSTTY_RESOURCES_DIR`
3. Test shell features: `ghostshell --list-features`

EOF

echo "✅ Zsh integration optimization complete!"

# Provide summary
echo ""
echo "📊 Optimization Summary:"
echo "  ✅ Zsh version: $ZSH_VERSION"
echo "  ✅ Framework: $ZSH_FRAMEWORK optimizations applied"
if [[ ${#ZSH_PLUGINS[@]} -gt 0 ]]; then
    echo "  ✅ Plugin optimizations: ${ZSH_PLUGINS[*]}"
fi
echo "  ✅ Shell integration features enabled"
echo "  ✅ Performance optimizations applied"

echo ""
echo "📁 Files created:"
echo "  • $GHOSTSHELL_CONFIG (optimized configuration)"
echo "  • $GHOSTSHELL_CONFIG_DIR/zsh-enhancements.zsh (integration script)"
echo "  • $GHOSTSHELL_CONFIG_DIR/INSTALL_ZSH_INTEGRATION.md (setup guide)"

echo ""
echo "🚀 Next steps:"
echo "1. Add to your .zshrc:"
echo "   [[ -f \"\$HOME/.config/ghostshell/zsh-enhancements.zsh\" ]] && source \"\$HOME/.config/ghostshell/zsh-enhancements.zsh\""
echo ""
echo "2. Reload Zsh: source ~/.zshrc"
echo ""
echo "3. Launch Ghostshell to test: ghostshell"

# Offer to automatically add to .zshrc
if [[ -f "$ZSH_CONFIG" ]]; then
    echo ""
    read -p "Would you like to automatically add integration to ~/.zshrc? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup .zshrc
        cp "$ZSH_CONFIG" "$ZSH_CONFIG.backup.$BACKUP_SUFFIX"
        
        # Add integration if not already present
        if ! grep -q "ghostshell/zsh-enhancements.zsh" "$ZSH_CONFIG"; then
            echo "" >> "$ZSH_CONFIG"
            echo "# Ghostshell integration" >> "$ZSH_CONFIG"
            echo "[[ -f \"\$HOME/.config/ghostshell/zsh-enhancements.zsh\" ]] && source \"\$HOME/.config/ghostshell/zsh-enhancements.zsh\"" >> "$ZSH_CONFIG"
            echo "✅ Added integration to ~/.zshrc"
            echo "💡 Restart your terminal or run: source ~/.zshrc"
        else
            echo "ℹ️  Integration already present in ~/.zshrc"
        fi
    fi
fi