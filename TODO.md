# Ghostshell TODO

This document outlines planned features and enhancements for future versions of Ghostshell.

## Version 1.1.0 - Security & Tab Management

### ⚡ Core Dependencies Optimization

#### TokioZ Async Runtime Enhancement
- **TokioZ Dependency Optimization**
  - Optimize TokioZ as core async runtime dependency
  - Enhanced async I/O for terminal operations
  - Improved event loop performance
  - Better memory management for async operations
  - Configuration option: `tokioz-optimizations = true`

- **Async Performance Features**
  - Zero-copy async operations where possible
  - Optimized async networking for SSH connections
  - Efficient async file I/O for configuration and logging
  - Background task scheduling optimization
  - Async-aware garbage collection

- **Dependency Configuration Options**
  ```
  # Core dependency optimizations
  zcrypto-optimizations = true
  tokioz-optimizations = true
  
  # Performance tuning
  async-pool-size = auto  # or specific number
  crypto-hardware-accel = true
  async-gc-threshold = 10MB
  
  # Monitoring
  dependency-profiling = false  # Enable for development
  performance-metrics = false
  ```

### 🔐 Security Features

#### SSH/GPG Keychain Integration
- **SSH Agent Integration**
  - Native SSH agent support with keychain management
  - Configuration option: `ssh-agent-integration = true`
  - Automatic key loading on terminal startup
  - Support for multiple SSH keys with selection UI
  - Integration with system keyring (GNOME Keyring, KDE Wallet)

- **GPG Key Management**
  - GPG agent integration for cryptographic operations
  - Automatic GPG key discovery and management
  - Configuration option: `gpg-agent-integration = true`
  - Support for signing commits and operations within terminal
  - Secure key passphrase caching

- **Keychain Configuration Options**
  ```
  # Enable keychain functionality
  keychain-integration = true
  ssh-agent-integration = true
  gpg-agent-integration = true
  
  # Keychain behavior
  keychain-auto-load = true
  keychain-timeout = 3600  # seconds
  keychain-prompt-style = native
  ```

### 📑 Tab Management (Pure Zig Implementation)

#### Native Tab Support
- **Pure Zig Tab Implementation**
  - Native tab bar implementation without GTK tab dependencies
  - Custom tab rendering with Zig graphics pipeline
  - Hardware-accelerated tab switching and animations
  - Memory-efficient tab management

- **Tab Features**
  - Configurable tab position: `tab-position = top|bottom|left|right`
  - Tab styling: `tab-style = minimal|full|compact`
  - Tab close buttons and keyboard shortcuts
  - Drag-and-drop tab reordering
  - Tab context menu (right-click options)

- **Tab Configuration Options**
  ```
  # Tab management
  tabs-enabled = true
  tab-position = top
  tab-style = minimal
  tab-close-button = true
  tab-auto-hide = false  # Hide when single tab
  
  # Tab appearance
  tab-width = auto
  tab-height = 32
  tab-font-size = 11
  tab-padding = 8
  
  # Tab colors
  tab-active-bg = #3c3c3c
  tab-active-fg = #ffffff
  tab-inactive-bg = #2c2c2c
  tab-inactive-fg = #a0a0a0
  ```

#### TMux Integration (Pure Zig)
- **Native TMux Support**
  - Built-in terminal multiplexing without external tmux dependency
  - Pure Zig implementation of session management
  - Seamless integration with Ghostshell tab system
  - Session persistence and restoration

- **TMux-Style Features**
  - Window and pane management
  - Session detach/attach functionality
  - Copy mode with vi/emacs key bindings
  - Status bar integration
  - Session sharing and collaboration

- **Configuration Options**
  ```
  # Built-in multiplexing
  multiplexer-enabled = true
  multiplexer-style = tmux  # tmux|screen|native
  
  # Session management
  session-auto-save = true
  session-restore = true
  session-directory = ~/.config/ghostshell/sessions
  
  # Pane management
  pane-border-style = solid
  pane-border-color = #444444
  pane-active-border-color = #00ff00
  ```

## Version 1.2.0 - Extended Platform Support

### 🐧 Additional Linux Support
- **Desktop Environment Support**
  - GNOME Shell optimization and integration
  - XFCE desktop environment support
  - i3/Sway tiling window manager integration
  - Hyprland compositor optimizations

- **Additional GPU Support**
  - AMD GPU optimizations (AMDGPU/RadeonSI)
  - Intel GPU support and optimizations
  - Multi-GPU system support

### 🎨 Advanced Theming
- **Theme Engine**
  - Custom theme format (.gst files)
  - Theme marketplace integration
  - Live theme switching without restart
  - Theme inheritance and composition

- **Visual Enhancements**
  - Custom cursor shapes and animations
  - Background image support with blending
  - Advanced transparency and blur effects
  - Custom scrollbar styling

## Version 1.3.0 - Developer Tools

### 🛠 Development Integration
- **Git Integration**
  - In-terminal git status and diff display
  - Branch information in prompt
  - Commit signing with integrated GPG
  - Visual git log and tree view

- **Language Server Integration**
  - LSP client for code highlighting and completion
  - Inline error display and diagnostics
  - Jump-to-definition functionality
  - Code formatting integration

### 🔌 Plugin System
- **Zig Plugin API**
  - Pure Zig plugin development framework
  - Hot-reloadable plugins
  - Plugin marketplace and distribution
  - Community plugin ecosystem

## Version 2.0.0 - Advanced Features

### 🌐 Network Features
- **Remote Terminal Support**
  - SSH connection management UI
  - Mosh protocol support
  - Connection profiles and bookmarks
  - Automatic reconnection handling

- **Collaborative Features**
  - Shared terminal sessions
  - Real-time collaboration
  - Screen sharing within terminal
  - Multi-user session management

### 🧠 AI Integration
- **AI-Powered Features**
  - Command completion using AI
  - Error explanation and suggestions
  - Code generation assistance
  - Natural language command translation

### 📱 Cross-Platform
- **Platform Expansion**
  - macOS native port (using Metal)
  - Windows WSL2 optimization
  - Android terminal app
  - Web-based terminal (WASM)

## Implementation Priorities

### High Priority (v1.1.0)
1. SSH/GPG keychain integration - Essential for developer workflow (view assets termius folder for references and ideas for how we may implemenet this, keep ghostty style default but enabled via config)
2. Pure Zig tab implementation - Core feature differentiator (this will be able to be controlled via config true is on. See assets screenshot termius folder for references)
3. TMux-style multiplexing - Replace external dependencies

### Medium Priority (v1.2.0)
1. Extended desktop environment support
2. Advanced theming system
3. Additional GPU optimizations

### Low Priority (v2.0.0+)
1. AI integration features
2. Cross-platform support
3. Collaborative features

## Technical Considerations

### Architecture Requirements
- **Pure Zig Implementation**: Minimize dependencies, maximize performance
- **Security First**: All keychain and security features must be audited
- **Performance**: Maintain sub-frame rendering times even with new features
- **Memory Efficiency**: Tab system must scale to 100+ tabs without performance loss

### Compatibility Goals
- **Backward Compatibility**: New features should not break existing configurations
- **Migration Path**: Provide clear upgrade paths for configuration changes
- **API Stability**: Plugin API should remain stable within major versions

## Community Contributions

We welcome contributions in the following areas:
- **Tab System**: Pure Zig UI implementation
- **Security Features**: SSH/GPG integration expertise
- **Platform Support**: Additional Linux distribution support
- **Documentation**: User guides and developer documentation
- **Testing**: Automated testing for new features

---

*This TODO is a living document and will be updated as features are implemented and new requirements are identified.*
