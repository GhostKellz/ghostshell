#!/bin/bash
# Ghostshell KDE + Wayland Optimization Setup Script
# Automatically detects and configures optimal settings for KDE Plasma + Wayland

set -e

GHOSTSHELL_CONFIG_DIR="$HOME/.config/ghostshell"
GHOSTSHELL_CONFIG="$GHOSTSHELL_CONFIG_DIR/config"
BACKUP_SUFFIX="$(date +%Y%m%d_%H%M%S)"

echo "🔧 Setting up Ghostshell for KDE Plasma + Wayland..."

# Create config directory if it doesn't exist
mkdir -p "$GHOSTSHELL_CONFIG_DIR"

# Backup existing config if it exists
if [[ -f "$GHOSTSHELL_CONFIG" ]]; then
    echo "📦 Backing up existing config to $GHOSTSHELL_CONFIG.backup.$BACKUP_SUFFIX"
    cp "$GHOSTSHELL_CONFIG" "$GHOSTSHELL_CONFIG.backup.$BACKUP_SUFFIX"
fi

# Detect KDE environment
detect_kde() {
    if [[ -n "$KDE_SESSION_VERSION" ]] || [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
        echo "✅ KDE Plasma detected"
        return 0
    fi
    return 1
}

# Detect Wayland
detect_wayland() {
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        echo "✅ Wayland session detected"
        return 0
    fi
    return 1
}

# Detect NVIDIA GPU and driver type
detect_nvidia() {
    if command -v nvidia-smi >/dev/null 2>&1; then
        NVIDIA_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
        
        # Check if using NVIDIA Open driver
        if grep -q "nvidia-open" /proc/driver/nvidia/version 2>/dev/null; then
            echo "✅ NVIDIA Open driver detected"
            echo "   Version: $NVIDIA_VERSION (nvidia-open)"
            NVIDIA_DRIVER_TYPE="open"
        else
            echo "✅ NVIDIA proprietary driver detected"
            echo "   Version: $NVIDIA_VERSION (proprietary)"
            NVIDIA_DRIVER_TYPE="proprietary"
        fi
        return 0
    fi
    return 1
}

# Get KDE Plasma version
get_kde_version() {
    if command -v plasmashell >/dev/null 2>&1; then
        local version=$(plasmashell --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo "$version"
    else
        echo "unknown"
    fi
}

# Check if running on high refresh rate display
detect_high_refresh() {
    if command -v kscreen-doctor >/dev/null 2>&1; then
        local max_refresh=$(kscreen-doctor -o | grep -oE '[0-9]+Hz' | sed 's/Hz//' | sort -nr | head -1)
        if [[ $max_refresh -gt 60 ]]; then
            echo "✅ High refresh rate display detected: ${max_refresh}Hz"
            echo "$max_refresh"
            return 0
        fi
    fi
    echo "60"
}

# Environment detection
echo ""
echo "🔍 Detecting environment..."

if ! detect_kde; then
    echo "⚠️  KDE Plasma not detected. This script is optimized for KDE."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if ! detect_wayland; then
    echo "⚠️  Wayland not detected. You may be running X11."
    echo "   This script is optimized for Wayland, but will still apply useful optimizations."
fi

HAS_NVIDIA=false
NVIDIA_DRIVER_TYPE=""
if detect_nvidia; then
    HAS_NVIDIA=true
fi

KDE_VERSION=$(get_kde_version)
MAX_REFRESH=$(detect_high_refresh)

echo ""
echo "📋 Environment Summary:"
echo "  Desktop: $(echo ${XDG_CURRENT_DESKTOP:-"Unknown"})"
echo "  Session: $(echo ${XDG_SESSION_TYPE:-"Unknown"})"
echo "  KDE Version: $KDE_VERSION"
echo "  Max Refresh Rate: ${MAX_REFRESH}Hz"
echo "  NVIDIA GPU: $([ "$HAS_NVIDIA" = true ] && echo "Yes ($NVIDIA_DRIVER_TYPE)" || echo "No")"

echo ""
echo "⚙️  Generating optimized configuration..."

# Start building the configuration
cat > "$GHOSTSHELL_CONFIG" << EOF
# Ghostshell KDE + Wayland Optimized Configuration
# Generated on $(date) by setup-kde-wayland.sh
# Environment: KDE $KDE_VERSION, $XDG_SESSION_TYPE session

EOF

# Wayland optimizations
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === WAYLAND INTEGRATION ===
wayland-app-id = com.ghostkellz.ghostshell
window-decoration = true
window-theme = auto
gtk-titlebar = false

EOF
fi

# KDE-specific optimizations
if detect_kde; then
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === KDE PLASMA OPTIMIZATIONS ===
background-opacity = 0.95
background-blur = true
window-inherit-working-directory = true
window-step-resize = false
unfocused-split-opacity = 0.8

# KDE integration
gtk-tabs-location = top
window-save-state = default
window-new-tab-position = current

EOF
fi

# Performance optimizations based on refresh rate
if [[ $MAX_REFRESH -gt 60 ]]; then
    cat >> "$GHOSTSHELL_CONFIG" << EOF
# === HIGH REFRESH RATE OPTIMIZATIONS ===
fps-cap = $((MAX_REFRESH * 2))
window-vsync = true
vsync = true

EOF
else
    cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === STANDARD REFRESH RATE OPTIMIZATIONS ===
fps-cap = 120
window-vsync = true
vsync = true

EOF
fi

# NVIDIA-specific optimizations
if [[ "$HAS_NVIDIA" = true ]]; then
    NVIDIA_MAJOR=$(echo $NVIDIA_VERSION | cut -d. -f1)
    
    if [[ "$NVIDIA_DRIVER_TYPE" == "open" && $NVIDIA_MAJOR -ge 575 ]]; then
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === NVIDIA OPEN 575+ OPTIMIZATIONS ===
# Optimized for nvidia-open 575.64.03+
window-vsync = false
vsync = false
sync = false

# Take advantage of hardware scheduling
# Set fps-cap = 0 for maximum performance

EOF
    elif [[ $NVIDIA_MAJOR -ge 550 ]]; then
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === MODERN NVIDIA OPTIMIZATIONS (550+) ===
sync = false
window-sync = false

EOF
    else
        cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === LEGACY NVIDIA OPTIMIZATIONS ===
sync = true
window-sync = true

EOF
    fi
fi

# Font and rendering optimizations
cat >> "$GHOSTSHELL_CONFIG" << 'EOF'
# === FONT RENDERING OPTIMIZATIONS ===
font-thicken = true
font-feature = +liga
font-feature = +calt
font-feature = +kern

# === TERMINAL PERFORMANCE ===
scrollback-limit = 100000
cursor-style = beam
cursor-style-blink = false

# === SHELL INTEGRATION ===
shell-integration = auto
shell-integration-features = cursor,sudo,title,jump

# === KEYBOARD OPTIMIZATIONS ===
copy-on-select = true
click-to-focus = true

# === APPEARANCE ===
window-padding-x = 2
window-padding-y = 2
theme = auto

# === TERMINAL SETTINGS ===
term = xterm-ghostshell
working-directory = inherit
confirm-close-surface = false
quit-after-last-window-closed = true

EOF

echo "✅ Configuration generated at $GHOSTSHELL_CONFIG"

# Provide additional recommendations
echo ""
echo "🎉 Ghostshell KDE + Wayland setup complete!"
echo ""
echo "📊 Applied optimizations:"
echo "  ✅ Wayland integration configured"
if detect_kde; then
    echo "  ✅ KDE Plasma optimizations enabled"
fi
if [[ $MAX_REFRESH -gt 60 ]]; then
    echo "  ✅ High refresh rate support (${MAX_REFRESH}Hz)"
fi
if [[ "$HAS_NVIDIA" = true ]]; then
    if [[ "$NVIDIA_DRIVER_TYPE" == "open" ]]; then
        echo "  ✅ NVIDIA Open driver optimizations applied"
    else
        echo "  ✅ NVIDIA GPU optimizations applied"
    fi
fi
echo "  ✅ Font rendering optimizations"
echo "  ✅ Performance tuning applied"

echo ""
echo "💡 Additional recommendations:"

if [[ "$HAS_NVIDIA" = true ]]; then
    if [[ "$NVIDIA_DRIVER_TYPE" == "proprietary" ]]; then
        echo "  • Consider switching to NVIDIA Open drivers (575+) for better Wayland support"
    elif [[ $NVIDIA_MAJOR -lt 575 ]]; then
        echo "  • Consider updating to NVIDIA Open 575.64.03+ for optimal performance"
    fi
fi

echo "  • For KDE System Settings optimizations:"
echo "    - System Settings > Display > Compositor > Rendering backend: OpenGL 3.1"
echo "    - System Settings > Display > Compositor > Tearing prevention: Never"

if [[ $MAX_REFRESH -gt 120 ]]; then
    echo "  • For gaming/high-performance scenarios, consider setting fps-cap = 0"
fi

echo ""
echo "🚀 Launch Ghostshell to experience the optimized KDE + Wayland setup!"
echo "   Run: ghostshell"