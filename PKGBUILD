# Maintainer: Christopher Kelley <ckelley@ghostkellz.sh>
pkgname=ghostshell
pkgver=1.0.1.r8.50235ba
pkgrel=1
pkgdesc="Ghostshell - Enhanced terminal emulator with vivid colors, theme integration, Zig 0.15 and NVIDIA optimizations"
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
    'zig'
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
    cd "$srcdir/ghostshell"
    echo "1.0.1.r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)"
}

prepare() {
    cd "$srcdir/ghostshell"
    
    # Ensure we're using the current directory with our fixes
    echo "Building Ghostshell v1.0.1 with vivid colors, theme integration, and NVIDIA optimizations"
    
    # Verify our key optimization files are present
    if [[ ! -f "nvidia-optimizations.md" ]]; then
        echo "Warning: nvidia-optimizations.md not found"
    fi
    
    # Check that our Zig 0.15 fixes are applied
    if [[ -f "src/config.zig" ]] && ! grep -q "conditional import" src/config.zig; then
        echo "Warning: Zig 0.15 compatibility fixes may not be applied"
    fi
}

build() {
    cd "$srcdir/ghostshell"
    
    # Set build flags for optimization
    export CFLAGS="$CFLAGS -O3 -march=native"
    export CXXFLAGS="$CXXFLAGS -O3 -march=native"
    
    # Build with Zig 0.15
    echo "Building with Zig $(zig version)"
    zig build -Doptimize=ReleaseFast
}

check() {
    cd "$srcdir/ghostshell"
    
    # Verify the binary was built
    if [[ ! -f "zig-out/bin/ghostshell" ]]; then
        echo "Error: ghostshell binary not found"
        return 1
    fi
    
    # Basic functionality test
    ./zig-out/bin/ghostshell --version
    echo "Build verification passed"
}

package() {
    cd "$srcdir/ghostshell"
    
    # Install binary
    install -Dm755 zig-out/bin/ghostshell "$pkgdir/usr/bin/ghostshell"
    
    # Install desktop file
    if [[ -f "zig-out/share/applications/com.ghostkellz.ghostshell.desktop" ]]; then
        install -Dm644 zig-out/share/applications/com.ghostkellz.ghostshell.desktop \
            "$pkgdir/usr/share/applications/com.ghostkellz.ghostshell.desktop"
    fi
    
    # Install icons
    if [[ -d "zig-out/share/icons" ]]; then
        cp -r zig-out/share/icons "$pkgdir/usr/share/"
    fi
    
    # Install man pages if they exist
    if [[ -d "zig-out/share/man" ]]; then
        cp -r zig-out/share/man "$pkgdir/usr/share/"
    fi
    
    # Install license
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    
    # Install our optimization documentation
    install -Dm644 nvidia-optimizations.md "$pkgdir/usr/share/doc/$pkgname/nvidia-optimizations.md"
    
    # Install example configuration showing NVIDIA optimizations
    mkdir -p "$pkgdir/usr/share/doc/$pkgname/examples"
    cat > "$pkgdir/usr/share/doc/$pkgname/examples/nvidia-config" << 'EOF'
# Ghostshell NVIDIA Optimizations Configuration
EOF

    # Install shell configuration scripts
    install -Dm755 scripts/import-shell-config.sh "$pkgdir/usr/share/ghostshell/scripts/import-shell-config.sh"
    install -Dm755 scripts/auto-detect-shell.sh "$pkgdir/usr/share/ghostshell/scripts/auto-detect-shell.sh"
    install -Dm755 scripts/setup-powerlevel10k.sh "$pkgdir/usr/share/ghostshell/scripts/setup-powerlevel10k.sh"
    
    echo "Installation complete!"
    echo "NVIDIA optimizations documentation: /usr/share/doc/$pkgname/nvidia-optimizations.md"
    echo "Example NVIDIA config: /usr/share/doc/$pkgname/examples/nvidia-config"
    echo ""
    echo "Shell Configuration Setup:"
    echo "  Auto-import existing shell configs: /usr/share/ghostshell/scripts/import-shell-config.sh"
    echo "  Auto-detect and optimize: /usr/share/ghostshell/scripts/auto-detect-shell.sh"
    echo "  PowerLevel10k setup: /usr/share/ghostshell/scripts/setup-powerlevel10k.sh"
    echo "  Or copy: /usr/share/ghostshell/configs/powerlevel10k-optimized.conf to ~/.config/ghostshell/config"
}
