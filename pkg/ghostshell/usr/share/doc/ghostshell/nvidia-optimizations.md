# Ghostshell NVIDIA GPU Optimizations for Zig 0.15

## Summary of Changes

This document outlines NVIDIA GPU optimizations for Ghostshell v1.0.0 with Zig 0.15 compatibility, focusing on modern NVIDIA driver optimizations (version 550+ recommended).

### 1. Zig Version Update
- Updated `build.zig` to require Zig v0.15.0 instead of v0.14.0

### 2. OpenGL Rendering Optimizations for NVIDIA GPUs

#### Problem
- Original code always used `glFinish()` which blocks CPU until GPU completes
- This causes significant stalls on NVIDIA GPUs, leading to slow typing
- Fixed 120 FPS target with blocking sync was inefficient

#### Solutions Implemented

1. **Conditional Sync in Frame Completion** (`src/renderer/opengl/Frame.zig`)
   - Changed from always using `glFinish()` to conditional sync
   - Uses `glFlush()` for async operations (better for NVIDIA)
   - Only uses `glFinish()` when sync is explicitly requested

2. **Triple Buffering** (`src/renderer/OpenGL.zig`)
   - Increased `swap_chain_count` from 1 to 3
   - Reduces pipeline stalls by allowing more frames in flight
   - Matches Metal renderer's performance characteristics

3. **VSync Configuration** (`src/config/Config.zig`)
   - Updated `window-vsync` to work on Linux with OpenGL
   - When disabled, uses `glFlush()` for lower latency
   - Helps users experiencing slow typing on NVIDIA GPUs

4. **Frame Sync Logic** (`src/renderer/generic.zig`)
   - Modified to respect vsync config for OpenGL
   - Allows users to control sync behavior via configuration

## Current NVIDIA Driver Optimizations (2024-2025)

### Modern NVIDIA Open Driver Features (575.x+)
- **Open Source Driver**: nvidia-open 575.64.03+ with full Wayland explicit sync support
- **Hardware Acceleration**: Native Wayland hardware acceleration without patching
- **GSP Firmware**: Improved GPU scheduling and power management
- **Vulkan 1.3+ Support**: Enhanced memory management and command buffer optimization
- **DRM Display**: Better multi-monitor and variable refresh rate support

### Ghostshell-Specific NVIDIA Optimizations

#### 1. Wayland + NVIDIA Open 575+ Configuration
```bash
# ~/.config/ghostshell/config

# NVIDIA Open 575.64.03+ optimized settings
window-vsync = false
vsync = false
sync = false

# Take advantage of hardware scheduling
fps-cap = 0

# Enable explicit sync for tear-free experience
wayland-app-id = com.ghostkellz.ghostshell
window-decoration = true

# GSP firmware optimizations
background-blur = true
background-opacity = 0.98
```

#### 2. X11 + NVIDIA Configuration
```bash
# ~/.config/ghostshell/config

# X11 with NVIDIA proprietary drivers
window-vsync = false
vsync = false
sync = true

# Higher performance for gaming/streaming setups
fps-cap = 165
```

#### 3. NVIDIA Optimus/Hybrid Graphics
```bash
# ~/.config/ghostshell/config

# For laptops with NVIDIA Optimus
window-vsync = true
vsync = true
fps-cap = 120
sync = false

# Power management
unfocused-split-opacity = 0.8
```

## Testing Instructions

1. Build Ghostshell with Zig v0.15:
   ```bash
   zig build -Doptimize=ReleaseFast
   ```

2. Check NVIDIA Open driver version:
   ```bash
   nvidia-smi
   # Should show 575.64.03 or newer
   ```

3. For NVIDIA Open 575+, use optimized config:
   ```bash
   cp configs/kde-wayland-optimized.conf ~/.config/ghostshell/config
   ```

4. Verify NVIDIA Open driver is being used:
   ```bash
   cat /proc/driver/nvidia/version
   # Should show "nvidia-open" in output
   ```

4. Test typing performance and verify improvements

## Troubleshooting NVIDIA Issues

### Performance Problems
- **Slow typing**: Disable vsync and set `fps-cap = 0`
- **Frame drops**: Enable triple buffering with `sync = false`
- **High latency**: Use `window-vsync = false` for competitive gaming

### Compatibility Issues
- **Wayland crashes**: Ensure NVIDIA driver 550+ and latest Wayland compositor
- **Screen tearing**: Enable compositor-level vsync (KDE System Settings)
- **Multiple monitors**: Use `window-decoration = true` for better multi-monitor support

## Recommended Environment Variables

```bash
# For NVIDIA Open 575+ drivers
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1
export __VK_LAYER_NV_optimus=NVIDIA_only

# For Wayland with explicit sync support
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland

# NVIDIA Open driver specific
export NVIDIA_DRIVER_CAPABILITIES=all
export __GL_GSYNC_ALLOWED=1
export __GL_VRR_ALLOWED=1

# For variable refresh rate and high refresh displays
export WLR_DRM_NO_ATOMIC=0
export WLR_DRM_NO_MODIFIERS=0
```

## Performance Impact

- Reduced CPU-GPU synchronization overhead
- Lower input latency for typing
- Better frame pacing with triple buffering
- Configurable sync behavior for different GPU vendors

## Compatibility

- Maintains compatibility with all platforms
- OpenGL changes only affect Linux/BSD systems
- No impact on Metal (macOS) or WebGL renderers