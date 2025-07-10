#!/bin/bash
# Ghostshell Auto-Detection and Integration Script
# Automatically detects existing PowerLevel10k, Zsh, Fish, and other shell configurations
# and configures Ghostshell optimally without overriding user settings

set -e

GHOSTSHELL_CONFIG_DIR="$HOME/.config/ghostshell"
GHOSTSHELL_CONFIG="$GHOSTSHELL_CONFIG_DIR/config"

echo "🔍 Auto-detecting your shell configuration..."

# Create config directory if it doesn't exist
mkdir -p "$GHOSTSHELL_CONFIG_DIR"

# Detection functions
detect_powerlevel10k() {
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        echo "✅ Found PowerLevel10k configuration at ~/.p10k.zsh"
        return 0
    elif [[ -n "$POWERLEVEL9K_CONFIG_FILE" && -f "$POWERLEVEL9K_CONFIG_FILE" ]]; then
        echo "✅ Found PowerLevel10k configuration at $POWERLEVEL9K_CONFIG_FILE"
        return 0
    elif [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        echo "✅ Found PowerLevel10k installation (Oh My Zsh)"
        return 0
    fi
    return 1
}

detect_shell() {
    local current_shell=$(basename "$SHELL")
    echo "🐚 Detected shell: $current_shell"
    echo "$current_shell"
}

detect_font() {
    # Check for PowerLevel10k recommended fonts
    local fonts_to_check=(
        "MesloLGS NF"
        "Hack Nerd Font"
        "JetBrainsMono Nerd Font" 
        "FiraCode Nerd Font"
        "Source Code Pro"
    )
    
    local detected_font=""
    for font in "${fonts_to_check[@]}"; do
        if fc-list | grep -i "$font" > /dev/null 2>&1; then
            echo "✅ Found suitable font: $font"
            detected_font="$font"
            break
        fi
    done
    
    if [[ -z "$detected_font" ]]; then
        echo "⚠️  No Nerd Font detected, using system default"
        detected_font="monospace"
    fi
    
    echo "$detected_font"
}

get_terminal_colors() {
    # Try to detect current terminal color scheme
    local theme="dark"
    
    # Check for common theme files
    if [[ -f "$HOME/.Xresources" ]]; then
        if grep -q "background.*#.*[0-9a-fA-F]" "$HOME/.Xresources"; then
            local bg_color=$(grep "background" "$HOME/.Xresources" | head -1 | sed 's/.*#//' | sed 's/[^0-9a-fA-F].*//')
            if [[ ${#bg_color} -eq 6 ]]; then
                # Convert hex to decimal and check brightness
                local r=$((16#${bg_color:0:2}))
                local g=$((16#${bg_color:2:2}))
                local b=$((16#${bg_color:4:2}))
                local brightness=$(( (r + g + b) / 3 ))
                if [[ $brightness -gt 128 ]]; then
                    theme="light"
                fi
            fi
        fi
    fi
    
    echo "$theme"
}

# Detect current configuration
HAS_P10K=false
SHELL_TYPE=$(detect_shell)
DETECTED_FONT=$(detect_font)
THEME=$(get_terminal_colors)

if detect_powerlevel10k; then
    HAS_P10K=true
fi

echo ""
echo "📋 Configuration Summary:"
echo "  Shell: $SHELL_TYPE"
echo "  PowerLevel10k: $([ "$HAS_P10K" = true ] && echo "Yes" || echo "No")"
echo "  Font: $DETECTED_FONT"
echo "  Theme: $theme"
echo ""

# Generate optimized configuration based on detection
echo "⚙️  Generating optimized Ghostshell configuration..."

# Start building config
cat > "$GHOSTSHELL_CONFIG" << EOF
# Ghostshell Auto-Generated Configuration
# Based on detected system configuration
# Generated on $(date)

# Font Configuration (auto-detected)
font-family = "$DETECTED_FONT"
font-size = 12

EOF

# Add PowerLevel10k specific optimizations if detected
if [[ "$HAS_P10K" = true ]]; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# PowerLevel10k Optimizations (auto-detected)
font-feature = +liga
font-feature = +calt
font-feature = +kern
font-thicken = true

# Performance optimizations for PowerLevel10k
fps-cap = 120
scrollback-limit = 100000

EOF
fi

# Add shell-specific optimizations
case "$SHELL_TYPE" in
    "zsh")
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# Zsh Integration (auto-detected)
shell-integration = zsh
shell-integration-features = cursor,sudo,title

EOF
        ;;
    "fish")
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# Fish Shell Integration (auto-detected)  
shell-integration = fish
shell-integration-features = cursor,sudo,title

EOF
        ;;
esac

# Add theme-based colors
if [[ "$THEME" = "dark" ]]; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# Dark Theme Colors (auto-detected)
foreground = #f8f8f2
background = #282a36

# Optimized dark palette
palette = 0=#44475a
palette = 1=#ff5555
palette = 2=#50fa7b
palette = 3=#f1fa8c
palette = 4=#6272a4
palette = 5=#ff79c6
palette = 6=#8be9fd
palette = 7=#f8f8f2
palette = 8=#44475a
palette = 9=#ff5555
palette = 10=#50fa7b
palette = 11=#f1fa8c
palette = 12=#6272a4
palette = 13=#ff79c6
palette = 14=#8be9fd
palette = 15=#ffffff

EOF
else
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# Light Theme Colors (auto-detected)
foreground = #383a42
background = #fafafa

# Optimized light palette  
palette = 0=#383a42
palette = 1=#e45649
palette = 2=#50a14f
palette = 3=#c18401
palette = 4=#4078f2
palette = 5=#a626a4
palette = 6=#0184bc
palette = 7=#fafafa
palette = 8=#4f525e
palette = 9=#e45649
palette = 10=#50a14f
palette = 11=#c18401
palette = 12=#4078f2
palette = 13=#a626a4
palette = 14=#0184bc
palette = 15=#ffffff

EOF
fi

# Add universal optimizations
cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# Universal Optimizations
cursor-style = beam
cursor-style-blink = false
vsync = true
window-inherit-working-directory = true

# Wayland optimizations (if applicable)
wayland-app-id = com.ghostkellz.ghostshell
window-decoration = true
gtk-titlebar = false
EOF

echo "✅ Configuration generated at $GHOSTSHELL_CONFIG"

# Provide setup summary
echo ""
echo "🎉 Ghostshell auto-configuration complete!"
echo ""
echo "📊 What was configured:"
if [[ "$HAS_P10K" = true ]]; then
    echo "  ✅ PowerLevel10k optimizations enabled"
    echo "  ✅ Enhanced font rendering for P10k icons"
fi
echo "  ✅ $SHELL_TYPE shell integration configured"
echo "  ✅ Font set to: $DETECTED_FONT"
echo "  ✅ $THEME theme colors applied"
echo "  ✅ Performance optimizations enabled"
echo ""
echo "💡 Your existing shell configuration (like ~/.p10k.zsh) remains unchanged"
echo "🚀 Start Ghostshell to see the optimized experience!"

# Detect and report any additional recommendations
echo ""
echo "💡 Additional recommendations:"

if [[ "$DETECTED_FONT" = "monospace" ]]; then
    echo "  • Install a Nerd Font for better icon support:"
    echo "    - MesloLGS NF (recommended for PowerLevel10k)"
    echo "    - JetBrainsMono Nerd Font"
    echo "    - Hack Nerd Font"
fi

if [[ "$HAS_P10K" = false && "$SHELL_TYPE" = "zsh" ]]; then
    echo "  • Consider installing PowerLevel10k for enhanced prompts:"
    echo "    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k"
    echo "    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc"
fi

if [[ "$SHELL_TYPE" != "zsh" && "$SHELL_TYPE" != "fish" ]]; then
    echo "  • Consider switching to Zsh or Fish for enhanced features"
fi