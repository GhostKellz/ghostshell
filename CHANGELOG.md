# Changelog

All notable changes to Ghostshell will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-05

### Initial Release
This is the first release of Ghostshell - an enhanced terminal emulator based on Ghostty with optimizations for modern Linux environments.

### Added
- **Complete Ghostshell Branding**
  - Rebranded from Ghostty to Ghostshell throughout codebase
  - Updated application ID from `com.ghostkellz.ghostshell` to `com.ghostkellz.ghostshell`
  - New Ghostshell icons and branding assets
  - Updated configuration path from `~/.config/ghostty` to `~/.config/ghostshell`
  - Binary renamed from `ghostty` to `ghostshell`

- **Zig 0.15 Compatibility**
  - Updated build system for Zig 0.15.0 support
  - Fixed conditional imports and build configuration
  - Updated all package managers to use Zig 0.15.0

- **NVIDIA Open Driver Optimizations**
  - Optimized for nvidia-open 575.64.03+ drivers
  - Hardware scheduling optimization with `fps-cap = 0`
  - Explicit sync support for tear-free Wayland experience
  - GSP firmware optimizations
  - Variable refresh rate and high refresh display support
  - Environment variables for NVIDIA Open driver compatibility

- **KDE Plasma + Wayland Integration**
  - Native Wayland application ID support
  - KDE Plasma-specific optimizations (background blur, window decorations)
  - High refresh rate display detection and optimization
  - Automated setup script (`scripts/setup-kde-wayland.sh`)
  - KDE-optimized configuration template (`configs/kde-wayland-optimized.conf`)

- **PowerLevel10k Integration**
  - Out-of-the-box PowerLevel10k compatibility
  - Automatic detection of existing `.p10k.zsh` configuration
  - MesloLGS NF font installation and configuration
  - PowerLevel10k auto-installation when not detected
  - Shell configuration import script (`scripts/import-shell-config.sh`)

- **Enhanced Zsh Shell Integration**
  - Framework detection (Oh My Zsh, PowerLevel10k, Prezto, Starship)
  - Plugin-specific optimizations (autosuggestions, syntax highlighting)
  - Performance tuning for complex prompts
  - Automated optimization script (`scripts/optimize-zsh-integration.sh`)
  - Enhanced shell integration with OSC 133 sequences

- **Configuration Management**
  - Auto-detection scripts for optimal configuration
  - Environment-specific setup tools
  - Configuration import from existing terminal setups
  - Backup and restore functionality

- **Package Manager Support**
  - **Flatpak**: Updated manifests with NVIDIA and Wayland optimizations
  - **Snap**: Enhanced metadata and environment variables
  - **NixOS**: Complete Nix flake and package configuration
  - **Arch Linux**: PKGBUILD with shell integration scripts

- **Documentation and Setup**
  - Comprehensive NVIDIA optimizations guide
  - KDE + Wayland setup instructions
  - PowerLevel10k integration documentation
  - Shell optimization guides
  - README with technology badges (Zig 0.15, Wayland, Arch, NVIDIA, TokioZ)

### Technical Improvements
- **TokioZ Async Integration**: Enhanced async runtime for improved performance
- **ZCrypto Integration**: Cryptographic functionality integration
- **Performance Optimizations**: FPS capping, VSync control, hardware acceleration
- **Font Rendering**: Enhanced font feature support (+liga, +calt, +kern)
- **Terminal Features**: Improved scrollback, cursor optimization, color management

### Build System
- Updated build configuration for Ghostshell branding
- Zig 0.15.0 compatibility across all build targets
- Enhanced resource installation and shell integration
- Version updated to 1.0.0 across all package managers

### Platform Support
- **Primary Target**: Arch Linux + KDE Plasma + Wayland
- **GPU Support**: NVIDIA Open drivers 575.64.03+
- **Shell Support**: Zsh with PowerLevel10k optimization
- **Package Formats**: Flatpak, Snap, NixOS, native packages

---

## Development Notes

This initial release represents a complete fork and enhancement of Ghostty with focus on:
- Modern NVIDIA GPU support (Open drivers)
- KDE Plasma desktop environment integration
- PowerLevel10k terminal prompt framework
- Zig 0.15 language compatibility
- Linux-first optimization approach

### Migration from Ghostty
Users migrating from Ghostty should note:
- Configuration location changed to `~/.config/ghostshell/`
- Binary name changed from `ghostty` to `ghostshell`
- Application ID updated for proper desktop integration
- All shell integrations updated for Ghostshell branding

### Performance Focus
Ghostshell 1.0.0 prioritizes performance on modern hardware:
- NVIDIA RTX series GPU optimization
- High refresh rate display support (120Hz+)
- Wayland compositor efficiency
- PowerLevel10k prompt rendering optimization