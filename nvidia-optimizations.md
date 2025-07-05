# Ghostty NVIDIA GPU Optimizations for Zig 0.15

## Summary of Changes

This patch updates Ghostty for Zig v0.15 compatibility and optimizes OpenGL rendering for NVIDIA GPUs to fix slow typing issues.

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

## Testing Instructions

1. Build with Zig v0.15:
   ```bash
   zig build -Doptimize=ReleaseFast
   ```

2. For NVIDIA GPU users experiencing slow typing, add to config:
   ```
   window-vsync = false
   ```

3. Test typing performance and verify improvements

## Performance Impact

- Reduced CPU-GPU synchronization overhead
- Lower input latency for typing
- Better frame pacing with triple buffering
- Configurable sync behavior for different GPU vendors

## Compatibility

- Maintains compatibility with all platforms
- OpenGL changes only affect Linux/BSD systems
- No impact on Metal (macOS) or WebGL renderers