# Installing Ghostshell v0.1.0 on Arch Linux

This guide covers installing Ghostshell - an enhanced terminal emulator based on Ghostty with Zig 0.15 compatibility and NVIDIA GPU optimizations on Arch Linux.

**Created by:** Christopher Kelley <ckelley@ghostkellz.sh>  
**Repository:** https://github.com/ghostkellz/ghostshell

## Installation Methods

### Method 1: Local Build with PKGBUILD (Recommended)

1. **Install dependencies:**
   ```bash
   sudo pacman -S base-devel zig git pandoc pkgconf
   sudo pacman -S gtk4 libadwaita vulkan-driver fontconfig freetype2 harfbuzz libpng zlib oniguruma gtk4-layer-shell wayland libx11
   ```

2. **For NVIDIA users, also install:**
   ```bash
   sudo pacman -S nvidia-utils vulkan-icd-loader
   ```

3. **Build and install:**
   ```bash
   # From the ghostshell directory
   makepkg -si
   ```

### Method 2: Manual Build

1. **Install Zig 0.15+:**
   ```bash
   # Install from AUR or download from ziglang.org
   yay -S zig-dev-bin  # or zig-git
   ```

2. **Build Ghostshell:**
   ```bash
   zig build -Doptimize=ReleaseFast
   ```

3. **Install manually:**
   ```bash
   sudo cp zig-out/bin/ghostty /usr/local/bin/ghostshell
   sudo cp zig-out/share/applications/com.ghostkellz.ghostshell.desktop /usr/share/applications/
   sudo cp -r zig-out/share/icons/* /usr/share/icons/
   ```

## Configuration for NVIDIA Optimization

Create `~/.config/ghostty/config` with NVIDIA-optimized settings for Ghostshell:

```ini
# NVIDIA GPU optimizations
vsync = true
sync = false

# Performance settings
window-decoration = false
scrollback-limit = 100000

# Font rendering optimizations
font-feature = -calt
font-feature = -liga

# Theme and appearance
theme = "dark"
background-opacity = 0.95

# NVIDIA-specific tweaks
macos-option-as-alt = false
```

## Verification

1. **Check Ghostshell version:**
   ```bash
   ghostshell --version
   ```

2. **Verify NVIDIA acceleration:**
   ```bash
   # Check that Vulkan is working with NVIDIA
   vulkaninfo | grep -i nvidia
   
   # Test NVIDIA GPU usage (install nvtop if needed)
   nvtop
   ```

3. **Test terminal functionality:**
   ```bash
   ghostshell --help
   ghostshell +list-fonts
   ```

## Troubleshooting

### Build Issues

- **Zig version error:** Ensure you have Zig 0.15 or later
- **Missing dependencies:** Install all packages listed in the PKGBUILD depends array
- **GTK4 errors:** Make sure you have the latest GTK4 and libadwaita

### NVIDIA Issues

- **No GPU acceleration:** Install `nvidia-utils` and ensure your driver is up to date
- **Poor performance:** Check that `vsync = true` and `sync = false` in your config
- **Display artifacts:** Try adjusting `background-opacity` or disabling compositing

### General Issues

- **Font rendering problems:** Install the `ttf-jetbrains-mono` package or configure font-family
- **Wayland issues:** Make sure `gtk4-layer-shell` is installed
- **X11 issues:** Ensure `libx11` is installed

## Advanced Configuration

### KDE/Wayland Optimizations

For KDE Plasma users, add these to your config:

```ini
# KDE Wayland optimizations
window-decoration = false
window-theme = "dark"
gtk-single-instance = false

# Plasma integration
desktop-notifications = true
confirm-close-surface = false
```

### Multiple GPU Setup

If you have multiple GPUs, you may need to force NVIDIA usage:

```bash
# Force NVIDIA GPU
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia ghostty

# Or set permanently in .desktop file
```

## Package Information

- **Package name:** `ghostshell`
- **Version:** 0.1.0 (based on Ghostty 1.1.4 with Zig 0.15 compatibility patches)
- **Provides:** `ghostshell`
- **Conflicts:** `ghostty`, `ghostty-git`, `ghostshell-git`
- **Maintainer:** Christopher Kelley <ckelley@ghostkellz.sh>

## What's Included

This build includes:

✅ **Zig 0.15 Compatibility**
- Fixed all API breaking changes
- Updated z2d graphics library
- Resolved circular dependencies

✅ **NVIDIA Optimizations**
- Conditional VSync for NVIDIA GPUs
- Triple buffering support
- Optimized rendering pipeline

✅ **Arch Linux Integration**
- Proper package structure
- Desktop file and icons
- Shell completions
- Man pages

## Support

For issues specific to this Zig 0.15 + NVIDIA build, create an issue with:
- Your Zig version (`zig version`)
- NVIDIA driver version (`nvidia-smi`)
- Ghostty config file
- Steps to reproduce

Original Ghostty issues should be reported to the [official repository](https://github.com/ghostty-org/ghostty).