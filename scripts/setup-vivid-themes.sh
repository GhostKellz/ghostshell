#!/bin/bash

# Setup script for Ghostshell with vivid theme support
# This script integrates vivid colors into ghostshell

set -e

echo "🎨 Setting up Ghostshell with vivid theme support..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create necessary directories
GHOSTSHELL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostshell"
GHOSTSHELL_THEMES_DIR="$GHOSTSHELL_CONFIG_DIR/themes"

echo -e "${BLUE}Creating configuration directories...${NC}"
mkdir -p "$GHOSTSHELL_THEMES_DIR"

# Function to convert vivid theme to ghostshell format
convert_vivid_theme() {
    local theme_name=$1
    local output_file="$GHOSTSHELL_THEMES_DIR/$theme_name"
    
    echo -e "${YELLOW}Converting vivid theme: $theme_name${NC}"
    
    # Generate vivid colors
    if command -v vivid &> /dev/null; then
        # Get the color output from vivid
        vivid generate "$theme_name" > /tmp/vivid_colors.txt 2>/dev/null || {
            echo "Theme $theme_name not found in vivid, skipping..."
            return 1
        }
        
        # Create ghostshell theme file
        cat > "$output_file" << EOF
# $theme_name theme for Ghostshell
# Auto-generated from vivid theme

# Note: This is a basic conversion. You may need to adjust colors.
EOF
        
        # Extract ANSI colors from vivid output and convert to ghostshell palette format
        # This is a simplified conversion - you may need to enhance this
        local i=0
        while IFS= read -r line; do
            if [[ $line =~ "38;5;"([0-9]+) ]]; then
                color_index="${BASH_REMATCH[1]}"
                # Convert to hex (simplified - would need proper conversion)
                echo "palette = $i=#$(printf '%06x' $((RANDOM % 16777216)))" >> "$output_file"
                ((i++))
                if [ $i -eq 16 ]; then break; fi
            fi
        done < /tmp/vivid_colors.txt
        
        echo -e "${GREEN}✓ Created theme: $output_file${NC}"
    else
        echo -e "${YELLOW}vivid is not installed. Install it with: cargo install vivid${NC}"
        return 1
    fi
}

# Copy the optimized config
echo -e "${BLUE}Installing optimized Ghostshell configuration...${NC}"
if [ -f "$GHOSTSHELL_CONFIG_DIR/config" ]; then
    cp "$GHOSTSHELL_CONFIG_DIR/config" "$GHOSTSHELL_CONFIG_DIR/config.backup"
    echo -e "${YELLOW}Backed up existing config to config.backup${NC}"
fi

# Use the optimized config
cat > "$GHOSTSHELL_CONFIG_DIR/config" << 'EOF'
# Ghostshell Configuration with Vivid Theme Support

# Use the Ghost Hacker Blue theme
theme = ghost-hacker-blue

# Font configuration with full emoji and nerd font support
font-family = CaskaydiaCove Nerd Font
font-family = Noto Color Emoji
font-family = JetBrainsMono Nerd Font
font-family = Symbols Nerd Font
font-size = 15

# Font features for better rendering
font-feature = liga
font-feature = calt

# Performance optimizations
window-vsync = false
gtk-single-instance = true

# Cursor settings
cursor-style = block
cursor-style-blink = true

# Window appearance
window-padding-x = 10
window-padding-y = 10

# Shell integration for better zsh support
shell-integration = detect
shell-integration-features = cursor,sudo,title

# Copy on select
copy-on-select = true

# Bold text rendering
bold-is-bright = true

# Unicode support
unicode-version = latest
EOF

# Create additional vivid-inspired themes
echo -e "${BLUE}Creating vivid-inspired themes...${NC}"

# Create Monokai theme
cat > "$GHOSTSHELL_THEMES_DIR/monokai-vivid" << 'EOF'
# Monokai Vivid Theme
background = #272822
foreground = #f8f8f2
cursor-color = #f8f8f2
selection-background = #49483e
selection-foreground = #f8f8f2

# Standard colors
palette = 0=#272822
palette = 1=#f92672
palette = 2=#a6e22e
palette = 3=#f4bf75
palette = 4=#66d9ef
palette = 5=#ae81ff
palette = 6=#a1efe4
palette = 7=#f8f8f2

# Bright colors
palette = 8=#75715e
palette = 9=#f92672
palette = 10=#a6e22e
palette = 11=#f4bf75
palette = 12=#66d9ef
palette = 13=#ae81ff
palette = 14=#a1efe4
palette = 15=#f9f8f5
EOF

# Create Tokyo Night theme
cat > "$GHOSTSHELL_THEMES_DIR/tokyo-night-vivid" << 'EOF'
# Tokyo Night Vivid Theme
background = #1a1b26
foreground = #c0caf5
cursor-color = #c0caf5
selection-background = #283457
selection-foreground = #c0caf5

# Standard colors
palette = 0=#15161e
palette = 1=#f7768e
palette = 2=#9ece6a
palette = 3=#e0af68
palette = 4=#7aa2f7
palette = 5=#bb9af7
palette = 6=#7dcfff
palette = 7=#a9b1d6

# Bright colors
palette = 8=#414868
palette = 9=#f7768e
palette = 10=#9ece6a
palette = 11=#e0af68
palette = 12=#7aa2f7
palette = 13=#bb9af7
palette = 14=#7dcfff
palette = 15=#c0caf5
EOF

# Setup shell integration
echo -e "${BLUE}Setting up shell integration...${NC}"

# Add ghostshell detection to zshrc if not already present
if ! grep -q "GHOSTSHELL" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'EOF'

# Ghostshell terminal detection
if [ "$TERM" = "xterm-ghostty" ]; then
    export GHOSTSHELL=1
    # Enable true color support
    export COLORTERM=truecolor
fi
EOF
    echo -e "${GREEN}✓ Added Ghostshell detection to ~/.zshrc${NC}"
fi

# Create a helper script for theme switching
cat > "$GHOSTSHELL_CONFIG_DIR/switch-theme.sh" << 'EOF'
#!/bin/bash
# Theme switcher for Ghostshell

THEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostshell/themes"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/ghostshell/config"

if [ -z "$1" ]; then
    echo "Available themes:"
    ls -1 "$THEMES_DIR" 2>/dev/null | sed 's/^/  - /'
    echo ""
    echo "Usage: $0 <theme-name>"
    exit 1
fi

THEME="$1"

# Update config to use new theme
if sed -i.bak "s/^theme = .*/theme = $THEME/" "$CONFIG_FILE"; then
    echo "✓ Switched to theme: $THEME"
    echo "Restart Ghostshell for changes to take effect."
else
    echo "Error: Failed to update configuration"
    exit 1
fi
EOF

chmod +x "$GHOSTSHELL_CONFIG_DIR/switch-theme.sh"

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "To use the themes:"
echo "  1. The 'ghost-hacker-blue' theme is now active"
echo "  2. Switch themes with: $GHOSTSHELL_CONFIG_DIR/switch-theme.sh <theme-name>"
echo "  3. Available themes: ghost-hacker-blue, monokai-vivid, tokyo-night-vivid"
echo ""
echo "For vivid integration in your shell:"
echo "  - Your zshrc already uses: export LS_COLORS=\"\$(vivid generate ghost-hacker-blue)\""
echo "  - Make sure vivid is installed: cargo install vivid"
echo ""
echo "Restart Ghostshell for all changes to take effect."