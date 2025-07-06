<!-- LOGO -->
<h1>
<p align="center">
  <img src="assets/icons/ghostshell_icon_128.png" alt="Ghostshell Logo" width="128">
  <br>Ghostshell
</h1>
  <p align="center">
    Pure Zig. Pure Speed. Pure NVIDIA. Home Lab Dream Shell.
    <br />
    <br />
    <img src="https://img.shields.io/badge/zig-v0.15.0-orange?style=for-the-badge&logo=zig" alt="Zig v0.15.0">
    <img src="https://img.shields.io/badge/wayland-compatible-blue?style=for-the-badge&logo=wayland" alt="Wayland Compatible">
    <img src="https://img.shields.io/badge/arch_linux-optimized-1793d1?style=for-the-badge&logo=archlinux" alt="Arch Linux Optimized">
    <img src="https://img.shields.io/badge/nvidia-accelerated-76b900?style=for-the-badge&logo=nvidia" alt="NVIDIA Accelerated">
    <img src="https://img.shields.io/badge/TokioZ-async_ready-green?style=for-the-badge" alt="TokioZ Async">
    <img src="https://img.shields.io/badge/powerlevel10k-compatible-ff6a00?style=for-the-badge&logo=powershell" alt="PowerLevel10k">
    <br />
    <br />
    <a href="#about">About</a>
    ·
    <a href="#installation">Installation</a>
    ·
    <a href="#nvidia-optimizations">NVIDIA Optimizations</a>
    ·
    <a href="#developing-ghostshell">Developing</a>
  </p>
</p>

## About

**Ghostshell** is a fork of [Ghostty Terminal Emulator](https://github.com/ghostty-org/ghostty) created on **July 5, 2025** as an experimental project for **Arch Linux + NVIDIA + Wayland** users. This fork differentiates itself by being optimized for **NVIDIA GPUs**, built with **Zig 0.15**, and designed for **home lab environments**.

This is an **experimental fork** that focuses specifically on maximum performance for NVIDIA users and power users who demand cutting-edge speed. While there are many excellent terminal emulators available, Ghostshell serves as a testing ground for specialized optimizations.

**Fork Maintainer:** Christopher Kelley (GhostKellz) <ckelley@ghostkellz.sh>  
**Organization:** CK Technology  
**Original Project:** [Ghostty](https://github.com/ghostty-org/ghostty) by Mitchell Hashimoto (@mitchellh)

> **⚠️ Important**: This is an independent experimental fork. For production use, consider the original [Ghostty project](https://github.com/ghostty-org/ghostty). See [FORK.md](FORK.md) for complete attribution details.

Ghostshell provides:
- **Pure Zig**: Built with Zig 0.15 for maximum performance and memory safety
- **Pure Speed**: NVIDIA GPU-accelerated rendering with conditional VSync and triple buffering
- **Pure NVIDIA**: First-class support for GeForce and Quadro graphics cards
- **Home Lab Ready**: Optimized for server monitoring, SSH sessions, and system administration
- **PowerLevel10k Compatible**: Out-of-the-box support for PowerLevel10k prompt with optimized rendering
- **Shell Optimized**: Enhanced Zsh and Fish shell integration with Wayland + KDE optimizations
- **TokioZ Async**: Built-in async runtime for non-blocking terminal operations

Ghostshell pushes the boundaries of terminal performance by implementing NVIDIA-specific
optimizations and leveraging the latest Zig compiler features. It's designed as a drop-in
replacement for existing terminal emulators while providing significant performance improvements
for NVIDIA users.

For technical implementation details, see [NVIDIA Optimizations](#nvidia-optimizations).

## Installation

### Arch Linux (Recommended)

```bash
# Clone the repository
git clone https://github.com/ghostkellz/ghostshell.git
cd ghostshell

# Build and install with PKGBUILD
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

For detailed installation instructions, see [INSTALL-ARCH.md](INSTALL-ARCH.md).

## NVIDIA Optimizations

Ghostshell includes several NVIDIA-specific optimizations for maximum performance:

### Conditional VSync
- Automatically enables VSync only when using NVIDIA OpenGL drivers
- Reduces input latency on non-NVIDIA systems
- Prevents screen tearing on NVIDIA GPUs

### Triple Buffering Support
- Smart triple buffering implementation for NVIDIA cards
- Maintains smooth 60+ FPS rendering under heavy load
- Optimized frame pacing for high-refresh displays

### GPU Memory Optimization
- Efficient texture and buffer management
- Optimized for GeForce and Quadro graphics cards
- Reduced VRAM usage while maintaining performance

See [nvidia-optimizations.md](nvidia-optimizations.md) for technical details.

## Shell Integration & PowerLevel10k

Ghostshell is optimized for modern shell environments with first-class support for popular prompts and shell frameworks:

### PowerLevel10k Compatibility
- **Out-of-the-box support** for PowerLevel10k without configuration
- **Optimized rendering** for complex prompt elements and icons
- **Fast glyph rendering** for Nerd Font icons and symbols
- **Smooth animations** for transient prompts and loading indicators

### Zsh Integration
- Enhanced completion support with async rendering
- Optimized for Oh My Zsh and Prezto frameworks
- Fast syntax highlighting with GPU acceleration
- Seamless integration with zsh-autosuggestions

### Fish Shell Support
- Native Fish shell integration with optimized rendering
- Enhanced autocomplete with real-time suggestions
- Fast syntax highlighting for Fish syntax
- Optimized for Fisher and Oh My Fish frameworks

### Wayland + KDE Optimizations
- **Native Wayland support** with hardware acceleration
- **KDE Plasma integration** for consistent theming
- **Optimized clipboard handling** for Wayland security model
- **Multi-monitor support** with per-monitor DPI scaling
- **Touch and gesture support** for convertible devices

### Configuration Example

Create `~/.config/ghostshell/config` for optimal shell integration:

```ini
# PowerLevel10k optimizations
font-family = "MesloLGS NF"
font-size = 12
font-feature = +liga
font-feature = +calt

# Shell integration
shell-integration = zsh
shell-integration-features = cursor,sudo,title

# Wayland + KDE optimizations
window-decoration = true
gtk-titlebar = false
wayland-app-id = com.ghostkellz.ghostshell

# Performance for complex prompts
scrollback-limit = 100000
fps-cap = 120
vsync = true
```

## Roadmap and Status

Ghostshell development roadmap focusing on NVIDIA optimization, shell integration, and home lab features:

|  #  | Step                                                      | Status |
| :-: | --------------------------------------------------------- | :----: |
|  1  | Zig 0.15 compatibility and build system                   |   ✅   |
|  2  | NVIDIA GPU optimizations (VSync, triple buffering)        |   ✅   |
|  3  | Arch Linux packaging and distribution                     |   ✅   |
|  4  | Home lab optimizations (SSH, monitoring, performance)     |   ✅   |
|  5  | PowerLevel10k out-of-the-box compatibility                |   🚧   |
|  6  | Wayland + KDE native integration and optimizations        |   🚧   |
|  7  | Enhanced Zsh/Fish shell integration                       |   🚧   |
|  8  | TokioZ async runtime integration                          |   🚧   |
|  9  | Advanced NVIDIA features (HDR, G-SYNC, custom shaders)    |   ❌   |
| 10  | Built-in monitoring dashboard and system tools            |   ❌   |
| 11  | CUDA integration for compute workloads                    |   ❌   |
| 12  | Multi-server management interface                         |   ❌   |
|  N  | Ray-traced terminal effects and advanced rendering        |   ❌   |

Additional details for each step in the big roadmap below:

#### Zig 0.15 Compatibility and Build System

Ghostshell has been completely updated to work with Zig 0.15, requiring extensive
modifications to handle breaking API changes:

- **z2d Graphics Library**: Updated from legacy DoublyLinkedList/SinglyLinkedList to custom structures
- **Circular Dependencies**: Resolved help_strings issues with conditional imports
- **Memory Management**: Fixed arena allocator and alignment API changes
- **Signal Handling**: Updated POSIX signal handling APIs
- **Type System**: Fixed Target, Alignment, and other type system changes

This ensures Ghostshell benefits from the latest Zig compiler optimizations and features.

#### NVIDIA GPU Optimizations

Ghostshell implements several NVIDIA-specific performance enhancements:

- **Conditional VSync**: Automatically detects NVIDIA OpenGL drivers and enables VSync only when beneficial
- **Triple Buffering**: Smart buffering implementation for smooth 60+ FPS rendering
- **GPU Memory Management**: Optimized texture and buffer handling for GeForce/Quadro cards
- **High-Refresh Support**: Optimized for 144Hz+ displays with G-SYNC/FreeSync compatibility

These optimizations provide measurable performance improvements for NVIDIA users
while maintaining compatibility with other GPU vendors.

#### Home Lab and Performance Focus

Ghostshell is optimized for power users and home lab environments:

- **SSH Performance**: Optimized rendering for remote connections
- **System Monitoring**: Great performance for log monitoring and analysis
- **Multiple Sessions**: Efficient handling of many concurrent terminal sessions
- **Server Administration**: Ideal for managing multiple servers and services

The focus on pure performance makes Ghostshell excellent for intensive
terminal workloads common in home lab and server environments.

#### Advanced NVIDIA Features (In Progress)

Future enhancements will include:

- **HDR Display Support**: True HDR rendering for compatible monitors
- **Custom Shader Support**: User-defined rendering effects and optimizations
- **Advanced G-SYNC Integration**: Better variable refresh rate handling
- **Ray-Traced Effects**: Experimental terminal rendering effects using RTX cores

## Configuration

Create `~/.config/ghostty/config` to customize Ghostshell:

### NVIDIA Optimized Configuration
```ini
# NVIDIA GPU optimizations
vsync = true
sync = false

# Performance settings
scrollback-limit = 100000
window-decoration = false

# Font rendering optimizations
font-feature = -calt
font-feature = -liga

# Home lab optimizations
theme = "dark"
background-opacity = 0.95
```

### Home Lab Configuration
```ini
# Perfect for server monitoring
cursor-style = "block"
shell-integration = "fish"
confirm-close-surface = false

# Multi-monitor setup
window-save-state = "always"

# SSH session optimization  
working-directory = ~
mouse-hide-while-typing = true
```

## Performance Verification

### Test NVIDIA Acceleration
```bash
# Check Vulkan support
vulkaninfo | grep -i nvidia

# Monitor GPU usage during terminal operations
nvidia-smi dmon

# Performance test with high throughput
ghostshell +list-fonts
time seq 1 100000
```

### Verify Ghostshell Features
```bash
# Check version
ghostshell --version

# Test available commands
ghostshell --help
ghostshell +list-colors
```

## Developing Ghostshell

Building Ghostshell from source requires Zig 0.15+ and system dependencies:

### Quick Development Setup
```bash
# Install Zig 0.15+
curl -L https://ziglang.org/download/0.15.0/zig-linux-x86_64-0.15.0.tar.xz | tar -xJ
export PATH=$PWD/zig-linux-x86_64-0.15.0:$PATH

# Build debug version
zig build

# Build optimized version
zig build -Doptimize=ReleaseFast

# Run tests
zig build test
```

### Development Commands

- `zig build` - Build debug version for development
- `zig build -Doptimize=ReleaseFast` - Build optimized release version
- `zig build test` - Run all unit tests
- `zig build test -Dtest-filter=<filter>` - Run specific test subset
- `zig build run -Dconformance=<name>` - Run conformance tests
- `ghostshell --version` - Verify build works correctly

### System Dependencies

Building Ghostshell on Linux requires:

**Arch Linux:**
```bash
sudo pacman -S base-devel zig git pandoc pkgconf
sudo pacman -S gtk4 libadwaita vulkan-driver fontconfig freetype2 harfbuzz libpng zlib oniguruma gtk4-layer-shell wayland libx11
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install build-essential git pandoc pkg-config
sudo apt install libgtk-4-dev libadwaita-1-dev libvulkan-dev libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libpng-dev zlib1g-dev libonig-dev libwayland-dev libx11-dev
```

**For NVIDIA users (recommended):**
```bash
# Arch Linux
sudo pacman -S nvidia-utils vulkan-icd-loader

# Ubuntu/Debian  
sudo apt install nvidia-driver-535 nvidia-utils-535
```

### NVIDIA Development Setup

For optimal development experience with NVIDIA GPUs:

```bash
# Install NVIDIA development tools
sudo pacman -S cuda nvidia-profiling-tools-meta

# Enable NVIDIA persistence mode for consistent performance
sudo nvidia-persistenced

# Monitor GPU usage during development
watch nvidia-smi

# Profile GPU usage (optional)
sudo pacman -S nvtop
nvtop
```

### Performance Testing
```bash
# Terminal throughput test
time find /usr -type f | head -50000

# GPU acceleration verification
ghostshell +list-fonts | head -100

# Memory usage test
ghostshell -e 'seq 1 100000'
```

## Contributing to Ghostshell

Ghostshell is developed with a focus on:
- **NVIDIA GPU optimization** and performance
- **Zig 0.15+** compatibility and modern features  
- **Home lab environments** and power user workflows
- **Pure performance** without compromising functionality

### Development Philosophy
- Pure Zig implementation for maximum performance
- NVIDIA-first approach to GPU acceleration
- Home lab and server administration focused
- Performance over compatibility when trade-offs are necessary

### Code Quality
- Follow Zig coding conventions
- Maintain NVIDIA optimization compatibility
- Test with various GPU configurations
- Performance regression testing required

### Reporting Issues
For Ghostshell-specific issues:
- Include `ghostshell --version` output
- Include `nvidia-smi` output for GPU-related issues
- Include system configuration (Arch/Ubuntu, GPU model, driver version)
- Performance issues should include benchmarks

## Community and Support

**Created by:** Christopher Kelley <ckelley@ghostkellz.sh>  
**Repository:** https://github.com/ghostkellz/ghostshell  
**Focus:** NVIDIA users, home lab enthusiasts, performance optimization

**Acknowledgments:**

We extend our deepest gratitude to the original [Ghostty project](https://github.com/ghostty-org/ghostty) and its contributors:
- **Mitchell Hashimoto (@mitchellh)** - Original creator and project lead
- **Ghostty Contributors** - For building an exceptional terminal emulator foundation
- **Ghostty Community** - For fostering innovation in terminal technology

Additional thanks to:
- **Zig Community** - Modern systems programming language and tooling
- **NVIDIA** - GPU acceleration capabilities and developer tools  
- **Arch Linux** - Excellent development environment and packaging ecosystem

> **Note**: Ghostshell is an independent experimental fork and is not affiliated with or endorsed by the original Ghostty project.

---

<p align="center">
  <strong>Pure Zig. Pure Speed. Pure NVIDIA. 👻</strong>
</p>
