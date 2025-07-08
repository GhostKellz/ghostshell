#!/bin/bash

# Test Setup Script for Ghostshell - Home Environment with Vivid
# For systems that already have vivid installed and configured
# Designed for KDE/Plasma with Wayland support

set -e

echo "🚀 Ghostshell v1.0.1 Test Setup - Home Environment"
echo "====================================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration paths
GHOSTSHELL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostshell"
GHOSTSHELL_THEMES_DIR="$GHOSTSHELL_CONFIG_DIR/themes"
GHOSTSHELL_BINARY="${1:-/data/projects/ghostshell/src/ghostshell/zig-out/bin/ghostshell}"

# Check if vivid is installed
check_vivid() {
    if command -v vivid &> /dev/null; then
        echo -e "${GREEN}✓ Vivid is installed${NC}"
        echo -e "  Version: $(vivid --version)"
        return 0
    else
        echo -e "${RED}✗ Vivid not found${NC}"
        echo -e "${YELLOW}  Install with: cargo install vivid${NC}"
        return 1
    fi
}

# Test vivid theme generation
test_vivid_themes() {
    echo -e "\n${BLUE}Testing vivid theme generation...${NC}"
    
    # Test if ghost-hacker-blue theme exists in vivid
    if vivid themes | grep -q "ghost-hacker-blue" 2>/dev/null; then
        echo -e "${GREEN}✓ ghost-hacker-blue theme found in vivid${NC}"
        
        # Generate and display sample
        echo -e "\n${YELLOW}Sample LS_COLORS output:${NC}"
        vivid generate ghost-hacker-blue | head -c 200
        echo "..."
    else
        echo -e "${YELLOW}! ghost-hacker-blue theme not found in vivid${NC}"
        echo -e "  You may need to add it to: ~/.config/vivid/themes/"
        
        # Create vivid theme if it doesn't exist
        VIVID_THEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vivid/themes"
        mkdir -p "$VIVID_THEMES_DIR"
        
        cat > "$VIVID_THEMES_DIR/ghost-hacker-blue.yml" << 'EOF'
# Ghost Hacker Blue theme for vivid
colors:
  black: "0d1117"
  red: "ff5c57"
  green: "5af78e"
  yellow: "f3f99d"
  blue: "57c7ff"
  purple: "ff6ac1"
  cyan: "9aedfe"
  white: "f1f1f0"
  
  bright_black: "686868"
  bright_red: "ff5c57"
  bright_green: "5af78e"
  bright_yellow: "f3f99d"
  bright_blue: "57c7ff"
  bright_purple: "ff6ac1"
  bright_cyan: "9aedfe"
  bright_white: "eff0eb"

core:
  regular_file: {}
  directory: {foreground: blue, font-style: bold}
  executable_file: {foreground: green, font-style: bold}
  symlink: {foreground: cyan}
  broken_symlink: {foreground: red, background: black}
  fifo: {foreground: yellow, background: black}
  socket: {foreground: purple, font-style: bold}
  block_device: {foreground: yellow, background: black}
  character_device: {foreground: yellow, background: black}
  normal_text: {foreground: white}
  sticky: {}
  sticky_other_writable: {}
  other_writable: {}
  setuid: {foreground: red, font-style: bold}
  setgid: {foreground: yellow, font-style: bold}
  capability: {foreground: red}

text:
  readme: {foreground: yellow, font-style: underline}
  licenses: {foreground: white, font-style: italic}

programming:
  source: {foreground: green}
  header: {foreground: blue}

media:
  image: {foreground: purple}
  video: {foreground: purple, font-style: bold}
  audio: {foreground: cyan}

archives:
  archive: {foreground: red, font-style: bold}
  compressed: {foreground: red}

documents:
  document: {foreground: white}
  
markup:
  markup: {foreground: yellow}

unimportant:
  unimportant: {foreground: bright_black}
EOF
        echo -e "${GREEN}✓ Created vivid theme: $VIVID_THEMES_DIR/ghost-hacker-blue.yml${NC}"
    fi
}

# Test current shell environment
test_shell_env() {
    echo -e "\n${BLUE}Testing shell environment...${NC}"
    
    # Check TERM
    echo -e "TERM: $TERM"
    
    # Check desktop environment
    if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
        echo -e "${GREEN}✓ KDE/Plasma desktop detected${NC}"
    elif [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
        echo -e "${GREEN}✓ GNOME desktop detected${NC}"
    else
        echo -e "${YELLOW}Desktop: $XDG_CURRENT_DESKTOP${NC}"
    fi
    
    # Check Wayland
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        echo -e "${GREEN}✓ Wayland session detected${NC}"
    else
        echo -e "${YELLOW}X11 session: $XDG_SESSION_TYPE${NC}"
    fi
    
    # Check if LS_COLORS is using vivid
    if [[ "$LS_COLORS" == *"38;5"* ]]; then
        echo -e "${GREEN}✓ LS_COLORS appears to be using extended colors${NC}"
    else
        echo -e "${YELLOW}! LS_COLORS may not be using vivid${NC}"
    fi
    
    # Check for terminal features
    if [[ "$COLORTERM" == "truecolor" ]] || [[ "$COLORTERM" == "24bit" ]]; then
        echo -e "${GREEN}✓ True color support detected${NC}"
    else
        echo -e "${YELLOW}! True color support not detected${NC}"
        echo -e "  Set: export COLORTERM=truecolor"
    fi
}

# Setup ghostshell configuration
setup_ghostshell_config() {
    echo -e "\n${BLUE}Setting up Ghostshell configuration...${NC}"
    
    # Backup existing config
    if [ -f "$GHOSTSHELL_CONFIG_DIR/config" ]; then
        cp "$GHOSTSHELL_CONFIG_DIR/config" "$GHOSTSHELL_CONFIG_DIR/config.test-backup"
        echo -e "${YELLOW}Backed up existing config${NC}"
    fi
    
    # Create test configuration
    mkdir -p "$GHOSTSHELL_CONFIG_DIR"
    cat > "$GHOSTSHELL_CONFIG_DIR/config" << 'EOF'
# Ghostshell Test Configuration - Home Setup with Vivid

# Theme
theme = ghost-hacker-blue

# Fonts - adjust based on what you have installed
font-family = CaskaydiaCove Nerd Font
font-family = JetBrainsMono Nerd Font  
font-family = Noto Color Emoji
font-family = Symbols Nerd Font
font-size = 15

# Performance - test with vsync on/off
window-vsync = false

# Cursor
cursor-style = block
cursor-style-blink = true
cursor-blink-interval = 500

# Window
window-padding-x = 10
window-padding-y = 10

# Shell integration  
shell-integration = detect
shell-integration-features = cursor,sudo,title

# Features
copy-on-select = true
bold-is-bright = true
unicode-version = latest

# Debug mode for testing
# debug = true
EOF
    
    echo -e "${GREEN}✓ Test configuration created${NC}"
}

# Test ghostshell binary
test_ghostshell() {
    echo -e "\n${BLUE}Testing Ghostshell binary...${NC}"
    
    if [ -x "$GHOSTSHELL_BINARY" ]; then
        echo -e "${GREEN}✓ Ghostshell binary found: $GHOSTSHELL_BINARY${NC}"
        
        # Get version
        if $GHOSTSHELL_BINARY --version &>/dev/null; then
            echo -e "  Version: $($GHOSTSHELL_BINARY --version)"
        fi
        
        # Test config validation
        echo -e "\n${YELLOW}Validating configuration...${NC}"
        if $GHOSTSHELL_BINARY +validate-config; then
            echo -e "${GREEN}✓ Configuration is valid${NC}"
        else
            echo -e "${RED}✗ Configuration validation failed${NC}"
        fi
    else
        echo -e "${RED}✗ Ghostshell binary not found at: $GHOSTSHELL_BINARY${NC}"
        echo -e "  Build with: cd /data/projects/ghostshell && zig build"
    fi
}

# Quick test launch
quick_test() {
    echo -e "\n${BLUE}Quick test commands:${NC}"
    echo "1. Test with current config:"
    echo "   $GHOSTSHELL_BINARY"
    echo ""
    echo "2. Test with debug output:"
    echo "   $GHOSTSHELL_BINARY --debug"
    echo ""
    echo "3. Test specific theme:"
    echo "   $GHOSTSHELL_BINARY --config-file theme=ghost-hacker-blue"
    echo ""
    echo "4. Test without vsync:"
    echo "   $GHOSTSHELL_BINARY --config-file window-vsync=false"
    echo ""
    echo "5. Show current config:"
    echo "   $GHOSTSHELL_BINARY +show-config"
}

# Main execution
main() {
    echo -e "${YELLOW}Starting test setup...${NC}\n"
    
    # Run all tests
    check_vivid
    test_vivid_themes
    test_shell_env
    setup_ghostshell_config
    test_ghostshell
    
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Test setup complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    quick_test
    
    echo -e "\n${YELLOW}Notes:${NC}"
    echo "- Config location: $GHOSTSHELL_CONFIG_DIR/config"
    echo "- Themes location: $GHOSTSHELL_CONFIG_DIR/themes/"
    echo "- Your zshrc should have: export LS_COLORS=\"\$(vivid generate ghost-hacker-blue)\""
    echo ""
    echo -e "${BLUE}To test emoji/Arch logo support:${NC}"
    echo "echo '🚀 👻 🎨  '"
    echo "echo $'\\uf303' # Arch logo (if using Nerd Font)"
}

# Run main
main "$@"