# 👻 Ghostshell v0.1.0

**Pure Zig. Pure Speed. Pure NVIDIA. Home Lab Dream Shell.**

<p align="center">
  <img src="https://github.com/user-attachments/assets/fe853809-ba8b-400b-83ab-a9a0da25be8a" alt="Ghostshell Logo" width="128">
</p>

<p align="center">
  Enhanced terminal emulator optimized for NVIDIA GPUs and home lab environments
  <br />
  <a href="#about">About</a>
  ·
  <a href="#installation">Installation</a>
  ·
  <a href="#nvidia-optimizations">NVIDIA Optimizations</a>
  ·
  <a href="#configuration">Configuration</a>
</p>

---

## About

**Ghostshell** is a high-performance terminal emulator built from Ghostty with aggressive optimizations for NVIDIA GPUs and modern home lab environments. Created by **Christopher Kelley** for enthusiasts who demand maximum performance.

### 🎯 Core Philosophy

- **Pure Zig**: Built with Zig 0.15 for maximum performance and memory safety
- **Pure Speed**: Optimized rendering pipeline with NVIDIA-specific enhancements  
- **Pure NVIDIA**: First-class support for NVIDIA GPU acceleration
- **Home Lab Ready**: Perfect for server management, monitoring, and automation

### ⚡ Key Features

🚀 **Performance First**
- NVIDIA GPU-accelerated rendering with conditional VSync
- Triple buffering for smooth visual experience
- Optimized for high-refresh displays (144Hz+)
- Minimal input latency for real-time monitoring

🎮 **NVIDIA Optimizations**
- Conditional sync specifically tuned for NVIDIA drivers
- Vulkan rendering pipeline optimized for GeForce/Quadro cards
- Smart VSync management to prevent screen tearing
- GPU memory optimizations for large terminal outputs

🏠 **Home Lab Focused**
- Perfect for monitoring dashboards and logs
- Excellent performance over SSH connections
- Optimized for multiple terminal sessions
- Great for server administration tasks

💻 **Modern Terminal Features**
- Full 24-bit color support
- Ligature support with optimized font rendering
- Image support for terminal graphics
- Comprehensive Unicode support

---

## Installation

### Arch Linux (PKGBUILD)

```bash
# Clone the repository
git clone https://github.com/ghostkellz/ghostshell.git
cd ghostshell

# Build and install
makepkg -si
```

### Manual Build (Any Linux)

**Requirements:**
- Zig 0.15.0 or later
- NVIDIA drivers (proprietary recommended)
- GTK4 and libadwaita

```bash
# Install Zig 0.15+
curl -L https://ziglang.org/download/0.15.0/zig-linux-x86_64-0.15.0.tar.xz | tar -xJ
export PATH=$PWD/zig-linux-x86_64-0.15.0:$PATH

# Build Ghostshell
zig build -Doptimize=ReleaseFast

# Install
sudo cp zig-out/bin/ghostty /usr/local/bin/ghostshell
```

---

## NVIDIA Optimizations

Ghostshell includes several NVIDIA-specific optimizations:

### 🎯 Conditional VSync
Automatically enables VSync only when using NVIDIA OpenGL drivers, reducing input latency on other systems while preventing screen tearing on NVIDIA GPUs.

### ⚡ Triple Buffering
Implements smart triple buffering for NVIDIA cards to maintain smooth 60+ FPS rendering even under heavy terminal load.

### 🖥️ Display Optimization
- Optimized for high-refresh NVIDIA displays (144Hz, 240Hz)
- Reduced frame pacing variance
- Better handling of G-SYNC/FreeSync displays

### 📊 Performance Monitoring
Use `nvtop` or `nvidia-smi` to monitor GPU usage:
```bash
# Monitor GPU usage while using Ghostshell
watch nvidia-smi

# Or install nvtop for better monitoring
sudo pacman -S nvtop
nvtop
```

---

## Configuration

Create `~/.config/ghostty/config` with optimized settings:

### 🚀 Performance Configuration
```ini
# NVIDIA GPU optimizations
vsync = true
sync = false

# High-performance settings
scrollback-limit = 100000
window-decoration = false

# Font optimizations for speed
font-feature = -calt
font-feature = -liga

# Memory optimizations
working-directory = ~
```

### 🏠 Home Lab Configuration
```ini
# Perfect for monitoring and server admin
theme = "dark"
background-opacity = 0.95
font-size = 12
cursor-style = "block"

# Better for long SSH sessions
confirm-close-surface = false
shell-integration = "fish"

# Multi-monitor setup
window-save-state = "always"
```

### 🎮 Gaming/High-Refresh Setup
```ini
# Optimized for high-refresh NVIDIA displays
vsync = true
sync = false
window-decoration = false

# Reduce input latency
cursor-click-to-move = false
mouse-hide-while-typing = true

# Performance
font-size = 14
scrollback-limit = 50000
```

---

## Performance Verification

### ✅ Test NVIDIA Acceleration
```bash
# Check Vulkan support
vulkaninfo | grep -i nvidia

# Monitor GPU usage
nvidia-smi dmon

# Test high-throughput scenarios
cat large_log_file.txt
yes | head -100000
```

### 📊 Benchmark Performance
```bash
# Terminal rendering benchmark
time seq 1 100000

# I/O performance test  
time find /usr -type f | head -50000

# Color rendering test
ghostshell +list-colors
```

---

## Troubleshooting

### 🔧 NVIDIA Issues
- **No acceleration**: Install `nvidia-utils` and ensure drivers are loaded
- **Screen tearing**: Verify `vsync = true` in config
- **Poor performance**: Check `sync = false` and monitor GPU usage

### ⚡ Performance Issues
- **High latency**: Disable desktop compositing or enable VRR
- **Memory usage**: Reduce `scrollback-limit` for better performance
- **Font rendering**: Try different font families or disable ligatures

---

## Development Status

Ghostshell v0.1.0 Status:

| Feature | Status | Notes |
|---------|--------|-------|
| Zig 0.15 Compatibility | ✅ | Fully updated and tested |
| NVIDIA Optimizations | ✅ | Conditional VSync, triple buffering |
| Home Lab Features | ✅ | SSH optimization, monitoring ready |
| Arch Linux Support | ✅ | PKGBUILD available |
| Performance Tuning | ✅ | GPU memory and rendering optimized |
| Advanced Features | 🚧 | Future: custom shaders, themes |

---

## Roadmap

### v0.2.0 - Advanced NVIDIA
- [ ] Custom NVIDIA shader support
- [ ] Ray-traced terminal effects
- [ ] HDR display support
- [ ] Advanced G-SYNC integration

### v0.3.0 - Home Lab Pro
- [ ] Built-in system monitoring
- [ ] SSH connection manager
- [ ] Log analysis tools
- [ ] Multi-server dashboards

### v0.4.0 - Pure Performance
- [ ] Custom memory allocators
- [ ] NVIDIA CUDA integration
- [ ] Advanced font rasterization
- [ ] Sub-pixel rendering

---

## Contributing

Ghostshell is developed by **Christopher Kelley** with a focus on:
- Pure performance optimization
- NVIDIA GPU excellence  
- Home lab workflow enhancement
- Zig 0.15+ compatibility

**Contact**: ckelley@ghostkellz.sh  
**Repository**: https://github.com/ghostkellz/ghostshell

---

## License

Based on Ghostty (MIT License) with NVIDIA optimizations and enhancements.
Copyright © 2024 Christopher Kelley

## Acknowledgments

- **Ghostty Project** - Original terminal emulator foundation
- **NVIDIA** - GPU acceleration capabilities  
- **Zig Community** - Modern systems programming language
- **Home Lab Community** - Performance testing and feedback

---

<p align="center">
  <strong>Pure Zig. Pure Speed. Pure NVIDIA. 👻</strong>
</p>