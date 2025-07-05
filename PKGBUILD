# Maintainer: Christopher Kelley <ckelley@ghostkellz.sh>
pkgname=ghostshell
pkgver=0.1.0
pkgrel=1
pkgdesc="Ghostshell - Enhanced terminal emulator based on Ghostty with Zig 0.15 and NVIDIA optimizations"
arch=('x86_64')
url="https://github.com/ghostkellz/ghostshell"
license=('MIT')
depends=(
    'gtk4'
    'libadwaita'
    'vulkan-driver'
    'fontconfig'
    'freetype2'
    'harfbuzz'
    'libpng'
    'zlib'
    'oniguruma'
    'gtk4-layer-shell'
    'wayland'
    'libx11'
)
makedepends=(
    'zig>=0.15.0'
    'git'
    'pandoc'
    'pkgconf'
)
optdepends=(
    'nvidia-utils: For NVIDIA GPU acceleration'
    'vulkan-intel: For Intel GPU support'
    'vulkan-radeon: For AMD GPU support'
    'mesa-vulkan-drivers: For Mesa Vulkan support'
)
provides=('ghostshell')
conflicts=('ghostty' 'ghostty-git' 'ghostshell-git')
source=("git+file://$(realpath .)")
sha256sums=('SKIP')

pkgver() {
    cd "$srcdir/$(basename $(realpath .))"
    echo "0.1.0.r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)"
}

prepare() {
    cd "$srcdir/$(basename $(realpath .))"
    
    # Ensure we're using the current directory with our fixes
    echo "Building Ghostshell v0.1.0 with Zig 0.15 compatibility and NVIDIA optimizations"
    
    # Verify our key optimization files are present
    if [[ ! -f "nvidia-optimizations.md" ]]; then
        echo "Warning: nvidia-optimizations.md not found"
    fi
    
    # Check that our Zig 0.15 fixes are applied
    if ! grep -q "conditional import" src/config/Config.zig; then
        echo "Warning: Zig 0.15 compatibility fixes may not be applied"
    fi
}

build() {
    cd "$srcdir/$(basename $(realpath .))"
    
    # Set build flags for optimization
    export CFLAGS="$CFLAGS -O3 -march=native"
    export CXXFLAGS="$CXXFLAGS -O3 -march=native"
    
    # Build with Zig 0.15
    echo "Building with Zig $(zig version)"
    zig build -Doptimize=ReleaseFast
}

check() {
    cd "$srcdir/$(basename $(realpath .))"
    
    # Verify the binary was built
    if [[ ! -f "zig-out/bin/ghostty" ]]; then
        echo "Error: ghostty binary not found"
        return 1
    fi
    
    # Basic functionality test
    ./zig-out/bin/ghostty --version
    echo "Build verification passed"
}

package() {
    cd "$srcdir/$(basename $(realpath .))"
    
    # Install binary
    install -Dm755 zig-out/bin/ghostty "$pkgdir/usr/bin/ghostshell"
    
    # Install desktop file
    if [[ -f "zig-out/share/applications/com.mitchellh.ghostty.desktop" ]]; then
        install -Dm644 zig-out/share/applications/com.mitchellh.ghostty.desktop \
            "$pkgdir/usr/share/applications/com.mitchellh.ghostty.desktop"
    fi
    
    # Install icons
    if [[ -d "zig-out/share/icons" ]]; then
        cp -r zig-out/share/icons "$pkgdir/usr/share/"
    fi
    
    # Install man pages if they exist
    if [[ -d "zig-out/share/man" ]]; then
        cp -r zig-out/share/man "$pkgdir/usr/share/"
    fi
    
    # Install completion files if they exist
    if [[ -d "zig-out/share/bash-completion" ]]; then
        install -Dm644 zig-out/share/bash-completion/completions/ghostty \
            "$pkgdir/usr/share/bash-completion/completions/ghostty"
    fi
    
    if [[ -d "zig-out/share/zsh" ]]; then
        install -Dm644 zig-out/share/zsh/site-functions/_ghostty \
            "$pkgdir/usr/share/zsh/site-functions/_ghostty"
    fi
    
    if [[ -d "zig-out/share/fish" ]]; then
        install -Dm644 zig-out/share/fish/vendor_completions.d/ghostty.fish \
            "$pkgdir/usr/share/fish/vendor_completions.d/ghostty.fish"
    fi
    
    # Install license
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    
    # Install our optimization documentation
    install -Dm644 nvidia-optimizations.md "$pkgdir/usr/share/doc/$pkgname/nvidia-optimizations.md"
    
    # Install example configuration showing NVIDIA optimizations
    mkdir -p "$pkgdir/usr/share/doc/$pkgname/examples"
    cat > "$pkgdir/usr/share/doc/$pkgname/examples/nvidia-config" << 'EOF'
# Ghostty NVIDIA Optimizations Configuration
# Copy to ~/.config/ghostty/config

# NVIDIA GPU optimizations
vsync = true
sync = false

# Performance settings for NVIDIA
window-decoration = false
macos-option-as-alt = false

# Font rendering optimizations
font-feature = -calt
font-feature = -liga

# Colors optimized for NVIDIA displays
theme = "dark"

# Terminal performance
scrollback-limit = 100000
EOF
    
    echo "Installation complete!"
    echo "NVIDIA optimizations documentation: /usr/share/doc/$pkgname/nvidia-optimizations.md"
    echo "Example NVIDIA config: /usr/share/doc/$pkgname/examples/nvidia-config"
}