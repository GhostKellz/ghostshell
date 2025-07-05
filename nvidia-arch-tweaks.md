# NVIDIA & Arch Linux Specific Optimizations

## Build Configuration
For optimal NVIDIA performance on Arch Linux, build with:
```bash
zig build -Doptimize=ReleaseFast -Drenderer=opengl
```

## Runtime Configuration (~/.config/ghostty/config)

### NVIDIA GPU Performance
```
# Disable VSync for better input latency on NVIDIA
window-vsync = false

# Force discrete GPU (for laptops with hybrid graphics)
gpu-api = opengl

# NVIDIA-specific OpenGL optimizations
opengl-triple-buffering = true
opengl-swap-interval = 0

# Better performance for high refresh rate displays
refresh-rate = auto
```

### Arch Linux Optimizations
```
# Use system fonts (better with Arch font packages)
font-family = "JetBrains Mono"
font-size = 12

# Better compatibility with Arch package managers
shell-integration = detect

# Optimize for Linux terminal workflows
working-directory = follow

# KDE Plasma integration
window-decoration = false
window-title-font-family = system
```

### Wayland Specific (for KDE Plasma Wayland)
```
# Force Wayland backend on KDE
window-backend = wayland

# KDE-specific window management
window-save-state = never
window-inherit-working-directory = true
window-inherit-font-size = true

# Better HiDPI handling on KDE
window-theme = auto
```

## Environment Variables
Add to your shell profile (`~/.bashrc`, `~/.zshrc`):

```bash
# Force NVIDIA GPU for Ghostty (hybrid graphics)
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# Wayland NVIDIA optimizations  
export GBM_BACKEND=nvidia-drm
export __GL_GSYNC_ALLOWED=1
export __GL_VRR_ALLOWED=1

# KDE integration
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
```

## Arch Packages to Install
```bash
# NVIDIA drivers
sudo pacman -S nvidia nvidia-utils nvidia-settings

# Wayland support
sudo pacman -S wayland wayland-protocols

# KDE integration
sudo pacman -S plasma-wayland-session kde-gtk-config

# Font rendering
sudo pacman -S ttf-jetbrains-mono ttf-liberation noto-fonts

# Terminal integration
sudo pacman -S kitty-terminfo
```

## Performance Testing
Test NVIDIA optimizations:
```bash
# Check GPU usage
nvidia-smi

# Monitor refresh rate
wayland-info | grep refresh

# Test input latency
ghostty --benchmark
```

## Troubleshooting

### NVIDIA Issues
- If screen tearing occurs: Enable `window-vsync = true`
- For input lag: Ensure `refresh-rate = auto`
- Blank screen: Try `gpu-api = opengl` explicitly

### KDE Wayland Issues  
- Window decorations: Set `window-decoration = true`
- Font issues: Install `ttf-jetbrains-mono`
- Clipboard problems: Ensure `wl-clipboard` is installed