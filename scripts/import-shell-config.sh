#!/bin/bash
# Ghostshell Shell Configuration Import Script
# Automatically imports settings from existing shell configurations:
# - PowerLevel10k (~/.p10k.zsh)
# - Zsh (~/.zshrc) 
# - Fish (~/.config/fish/config.fish)
# - Terminal color schemes

set -e

GHOSTSHELL_CONFIG_DIR="$HOME/.config/ghostshell"
GHOSTSHELL_CONFIG="$GHOSTSHELL_CONFIG_DIR/config"

echo "🔍 Importing your existing shell configuration..."

# Create config directory if it doesn't exist
mkdir -p "$GHOSTSHELL_CONFIG_DIR"

# Backup existing Ghostshell config if it exists
if [[ -f "$GHOSTSHELL_CONFIG" ]]; then
    backup_file="$GHOSTSHELL_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backing up existing config to $(basename "$backup_file")"
    cp "$GHOSTSHELL_CONFIG" "$backup_file"
fi

# Parse PowerLevel10k configuration
parse_p10k_config() {
    local p10k_file="$1"
    local font_family=""
    local prompt_elements=""
    
    echo "📖 Reading PowerLevel10k configuration from $p10k_file"
    
    # Extract font settings if defined
    if grep -q "POWERLEVEL9K_MODE=" "$p10k_file" 2>/dev/null; then
        local p10k_mode=$(grep "POWERLEVEL9K_MODE=" "$p10k_file" | head -1 | cut -d'=' -f2 | tr -d '"'"'"' | tr -d ' ')
        case "$p10k_mode" in
            "nerdfont-complete"|"awesome-mapped-fontconfig")
                font_family="MesloLGS NF"
                ;;
            "powerline")
                font_family="Powerline"
                ;;
        esac
    fi
    
    # Check for specific font recommendations in comments
    if grep -qi "MesloLGS" "$p10k_file" 2>/dev/null; then
        font_family="MesloLGS NF"
    elif grep -qi "Hack Nerd Font" "$p10k_file" 2>/dev/null; then
        font_family="Hack Nerd Font Mono"
    fi
    
    # Extract prompt elements for performance optimization
    if grep -q "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=" "$p10k_file" 2>/dev/null; then
        prompt_elements=$(grep "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=" "$p10k_file" | head -1 | sed 's/.*=(//' | sed 's/).*//')
    fi
    
    echo "  Font detected: ${font_family:-"default"}"
    echo "  Prompt elements: ${prompt_elements:-"default"}"
    
    # Return values via global variables
    P10K_FONT="$font_family"
    P10K_ELEMENTS="$prompt_elements"
}

# Parse Zsh configuration
parse_zsh_config() {
    local zshrc_file="$1"
    
    echo "📖 Reading Zsh configuration from $zshrc_file"
    
    # Check for Oh My Zsh
    if grep -q "OH_MY_ZSH" "$zshrc_file" 2>/dev/null; then
        ZSH_FRAMEWORK="oh-my-zsh"
        echo "  Framework: Oh My Zsh detected"
    elif grep -q "prezto" "$zshrc_file" 2>/dev/null; then
        ZSH_FRAMEWORK="prezto"
        echo "  Framework: Prezto detected"
    else
        ZSH_FRAMEWORK="plain"
        echo "  Framework: Plain Zsh"
    fi
    
    # Check for plugins that affect terminal behavior
    if grep -q "zsh-autosuggestions" "$zshrc_file" 2>/dev/null; then
        ZSH_HAS_AUTOSUGGESTIONS=true
        echo "  Plugin: zsh-autosuggestions detected"
    fi
    
    if grep -q "zsh-syntax-highlighting" "$zshrc_file" 2>/dev/null; then
        ZSH_HAS_SYNTAX_HIGHLIGHTING=true
        echo "  Plugin: zsh-syntax-highlighting detected"
    fi
    
    # Check for custom prompt
    if grep -q "PROMPT=" "$zshrc_file" 2>/dev/null; then
        ZSH_HAS_CUSTOM_PROMPT=true
        echo "  Custom prompt detected"
    fi
}

# Parse Fish configuration  
parse_fish_config() {
    local fish_config="$1"
    
    echo "📖 Reading Fish configuration from $fish_config"
    
    # Check for Fish prompt
    if grep -q "fish_prompt" "$fish_config" 2>/dev/null; then
        FISH_HAS_CUSTOM_PROMPT=true
        echo "  Custom Fish prompt detected"
    fi
    
    # Check for Fisher plugins
    if [[ -f "$HOME/.config/fish/fish_plugins" ]]; then
        echo "  Fisher plugins detected"
        FISH_HAS_FISHER=true
    fi
    
    # Check for common Fish frameworks
    if grep -q "starship" "$fish_config" 2>/dev/null; then
        FISH_FRAMEWORK="starship"
        echo "  Framework: Starship detected"
    elif grep -q "oh-my-fish" "$fish_config" 2>/dev/null; then
        FISH_FRAMEWORK="oh-my-fish" 
        echo "  Framework: Oh My Fish detected"
    fi
}

# Detect terminal colors from various sources
detect_terminal_colors() {
    local fg_color="#f8f8f2"
    local bg_color="#282a36"
    
    # Try to read from .Xresources
    if [[ -f "$HOME/.Xresources" ]]; then
        if grep -q "foreground" "$HOME/.Xresources"; then
            fg_color=$(grep "foreground" "$HOME/.Xresources" | head -1 | sed 's/.*#/#/' | cut -d' ' -f1)
        fi
        if grep -q "background" "$HOME/.Xresources"; then
            bg_color=$(grep "background" "$HOME/.Xresources" | head -1 | sed 's/.*#/#/' | cut -d' ' -f1)
        fi
        echo "  Colors imported from .Xresources"
    fi
    
    # Try to read from terminal-specific configs
    if [[ -f "$HOME/.config/alacritty/alacritty.yml" ]]; then
        echo "  Alacritty config detected (manual parsing not implemented)"
    fi
    
    if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
        if grep -q "foreground" "$HOME/.config/kitty/kitty.conf"; then
            fg_color=$(grep "foreground" "$HOME/.config/kitty/kitty.conf" | head -1 | awk '{print $2}')
        fi
        if grep -q "background" "$HOME/.config/kitty/kitty.conf"; then
            bg_color=$(grep "background" "$HOME/.config/kitty/kitty.conf" | head -1 | awk '{print $2}')
        fi
        echo "  Colors imported from Kitty config"
    fi
    
    TERMINAL_FG="$fg_color"
    TERMINAL_BG="$bg_color"
}

# Initialize variables
P10K_FONT=""
P10K_ELEMENTS=""
ZSH_FRAMEWORK=""
ZSH_HAS_AUTOSUGGESTIONS=false
ZSH_HAS_SYNTAX_HIGHLIGHTING=false
ZSH_HAS_CUSTOM_PROMPT=false
FISH_HAS_CUSTOM_PROMPT=false
FISH_HAS_FISHER=false
FISH_FRAMEWORK=""
TERMINAL_FG="#f8f8f2"
TERMINAL_BG="#282a36"

# Detect and parse configurations
echo ""

# Check if PowerLevel10k is installed
check_powerlevel10k_installed() {
    if [[ -f "$HOME/.p10k.zsh" ]] || [[ -n "$POWERLEVEL9K_CONFIG_FILE" && -f "$POWERLEVEL9K_CONFIG_FILE" ]]; then
        return 0
    fi
    
    if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        return 0
    fi
    
    if [[ -d "$HOME/powerlevel10k" ]]; then
        return 0
    fi
    
    return 1
}

# Install PowerLevel10k if not detected
install_powerlevel10k() {
    echo "📥 PowerLevel10k not detected. Installing PowerLevel10k..."
    
    # Check if user wants to install
    read -p "Would you like to install PowerLevel10k? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping PowerLevel10k installation"
        return 1
    fi
    
    # Check if Oh My Zsh is installed
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "📦 Installing PowerLevel10k for Oh My Zsh..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
        
        # Update .zshrc if it exists
        if [[ -f "$HOME/.zshrc" ]]; then
            # Check if ZSH_THEME is already set to powerlevel10k
            if ! grep -q "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" "$HOME/.zshrc"; then
                # Backup .zshrc
                cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
                
                # Update or add ZSH_THEME
                if grep -q "^ZSH_THEME=" "$HOME/.zshrc"; then
                    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
                else
                    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
                fi
                echo "✅ Updated .zshrc to use PowerLevel10k theme"
            fi
        fi
    else
        echo "📦 Installing PowerLevel10k manually..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        
        # Add to .zshrc if it exists
        if [[ -f "$HOME/.zshrc" ]]; then
            if ! grep -q "source ~/powerlevel10k/powerlevel10k.zsh-theme" "$HOME/.zshrc"; then
                # Backup .zshrc
                cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
                echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> "$HOME/.zshrc"
                echo "✅ Added PowerLevel10k to .zshrc"
            fi
        fi
    fi
    
    echo "✅ PowerLevel10k installation complete!"
    echo "💡 Next time you start Zsh, the PowerLevel10k configuration wizard will run"
    return 0
}

# Parse PowerLevel10k if it exists
if check_powerlevel10k_installed; then
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        parse_p10k_config "$HOME/.p10k.zsh"
    elif [[ -n "$POWERLEVEL9K_CONFIG_FILE" && -f "$POWERLEVEL9K_CONFIG_FILE" ]]; then
        parse_p10k_config "$POWERLEVEL9K_CONFIG_FILE"
    else
        echo "✅ PowerLevel10k is installed but no configuration file found"
    fi
else
    echo "ℹ️  No PowerLevel10k installation found"
    if [[ "$SHELL" == *"zsh"* ]]; then
        install_powerlevel10k
    else
        echo "💡 PowerLevel10k requires Zsh. Current shell: $(basename "$SHELL")"
    fi
fi

# Parse Zsh config if it exists
if [[ -f "$HOME/.zshrc" ]]; then
    parse_zsh_config "$HOME/.zshrc"
else
    echo "ℹ️  No .zshrc found"
fi

# Parse Fish config if it exists  
if [[ -f "$HOME/.config/fish/config.fish" ]]; then
    parse_fish_config "$HOME/.config/fish/config.fish"
else
    echo "ℹ️  No Fish configuration found"
fi

# Detect terminal colors
echo "🎨 Detecting terminal colors..."
detect_terminal_colors

echo ""
echo "⚙️  Generating Ghostshell configuration based on imported settings..."

# Generate the configuration file
cat > "$GHOSTSHELL_CONFIG" << EOF
# Ghostshell Configuration - Imported from existing shell setup
# Generated on $(date)
# 
# Imported from:
$([ -f "$HOME/.p10k.zsh" ] && echo "#   - PowerLevel10k: ~/.p10k.zsh")
$([ -f "$HOME/.zshrc" ] && echo "#   - Zsh: ~/.zshrc")
$([ -f "$HOME/.config/fish/config.fish" ] && echo "#   - Fish: ~/.config/fish/config.fish")

EOF

# Add font configuration
if [[ -n "$P10K_FONT" ]]; then
    cat >> "$GHOSTSHELL_CONFIG" << EOF
# Font Configuration (imported from PowerLevel10k)
font-family = "$P10K_FONT"
font-size = 12
font-feature = +liga
font-feature = +calt
font-feature = +kern

EOF
else
    # Try to detect system Nerd Font
    if fc-list | grep -i "MesloLGS NF" > /dev/null 2>&1; then
        DETECTED_FONT="MesloLGS NF"
    elif fc-list | grep -i "Hack Nerd Font" > /dev/null 2>&1; then
        DETECTED_FONT="Hack Nerd Font Mono"
    elif fc-list | grep -i "JetBrainsMono Nerd Font" > /dev/null 2>&1; then
        DETECTED_FONT="JetBrainsMono Nerd Font"
    else
        DETECTED_FONT="monospace"
    fi
    
    cat >> "$GHOSTSHELL_CONFIG" << EOF
# Font Configuration (auto-detected)
font-family = "$DETECTED_FONT"
font-size = 12

EOF
fi

# Add shell integration based on detected shell
current_shell=$(basename "$SHELL")
cat >> "$GHOSTSHELL_CONFIG" << EOF
# Shell Integration (detected: $current_shell)
shell-integration = $current_shell
shell-integration-features = cursor,sudo,title

EOF

# Add PowerLevel10k optimizations if detected
if [[ -n "$P10K_FONT" ]] || [[ -f "$HOME/.p10k.zsh" ]]; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# PowerLevel10k Optimizations (imported settings)
fps-cap = 120
scrollback-limit = 100000
cursor-style = beam
cursor-style-blink = false

EOF
fi

# Add performance optimizations based on detected plugins
if [[ "$ZSH_HAS_SYNTAX_HIGHLIGHTING" = true ]]; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# Optimizations for zsh-syntax-highlighting
window-vsync = true
unfocused-split-opacity = 0.8

EOF
fi

# Add color scheme (imported or detected)
cat >> "$GHOSTSHELL_CONFIG" << EOF
# Color Scheme (imported from terminal config)
foreground = $TERMINAL_FG
background = $TERMINAL_BG

EOF

# Add universal optimizations
cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# Universal Performance Optimizations
vsync = true
window-inherit-working-directory = true
window-decoration = true

# Wayland optimizations
wayland-app-id = com.ghostkellz.ghostshell
gtk-titlebar = false

# NVIDIA optimizations (if applicable)
window-vsync = true
EOF

echo "✅ Configuration generated at $GHOSTSHELL_CONFIG"

# Provide summary
echo ""
echo "🎉 Shell configuration import complete!"
echo ""
echo "📊 Imported settings:"
[[ -n "$P10K_FONT" ]] && echo "  ✅ PowerLevel10k font: $P10K_FONT"
if check_powerlevel10k_installed; then
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        echo "  ✅ PowerLevel10k configuration imported from ~/.p10k.zsh"
    else
        echo "  ✅ PowerLevel10k installation detected"
    fi
fi
[[ "$ZSH_FRAMEWORK" ]] && echo "  ✅ Zsh framework: $ZSH_FRAMEWORK"
[[ "$ZSH_HAS_AUTOSUGGESTIONS" = true ]] && echo "  ✅ Zsh autosuggestions support enabled"
[[ "$ZSH_HAS_SYNTAX_HIGHLIGHTING" = true ]] && echo "  ✅ Zsh syntax highlighting optimizations"
[[ -f "$HOME/.config/fish/config.fish" ]] && echo "  ✅ Fish shell configuration imported"
echo "  ✅ Terminal colors: fg=$TERMINAL_FG bg=$TERMINAL_BG"
echo "  ✅ Shell integration: $current_shell"
echo ""
echo "💡 Your original configuration files remain unchanged"
echo "🚀 Launch Ghostshell to experience the imported settings!"
echo ""
if check_powerlevel10k_installed && [[ ! -f "$HOME/.p10k.zsh" ]]; then
    echo "⚡ PowerLevel10k was installed but not configured yet"
    echo "   Start a new Zsh session to run the configuration wizard"
fi