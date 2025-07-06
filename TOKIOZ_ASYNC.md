
# GHOSTSHELL Integration Guide
## Leveraging TokioZ Async Runtime for High-Performance Terminal Applications

![zig-version](https://img.shields.io/badge/zig-v0.15.0-blue?style=flat-square)
![tokioz-integration](https://img.shields.io/badge/TokioZ-async--ready-green?style=flat-square)

**GHOSTSHELL** is a high-performance, pure Zig Linux terminal built on the foundation of Ghostty, enhanced with NVIDIA GPU acceleration, Wayland compatibility, and Arch Linux optimizations. This guide demonstrates how to integrate **TokioZ** async runtime to achieve blazing-fast, non-blocking terminal operations.

---

## 🎯 Integration Overview

TokioZ provides the async foundation that enables GHOSTSHELL to handle:
- **Non-blocking PTY I/O** - Real-time terminal data streams
- **Concurrent GPU Rendering** - Async NVIDIA CUDA operations  
- **Wayland Protocol Handling** - Event-driven compositor communication
- **Process Management** - Async child process spawning and monitoring
- **File System Operations** - Non-blocking file operations and monitoring

---

## 🏗 Architecture Integration

```
GHOSTSHELL + TokioZ Architecture
├── main.zig              # TokioZ runtime bootstrap
├── terminal/
│   ├── pty.zig           # Async PTY handling via TokioZ
│   ├── renderer.zig      # GPU-accelerated async rendering
│   └── input.zig         # Non-blocking input processing
├── wayland/
│   ├── client.zig        # Async Wayland protocol client
│   ├── surface.zig       # Surface management with TokioZ timers
│   └── events.zig        # Event loop integration
├── gpu/
│   ├── nvidia.zig        # Async CUDA compute operations
│   └── vulkan.zig        # Async Vulkan rendering pipeline
└── system/
    ├── process.zig       # Async process spawning
    └── fs.zig            # Async file system operations
```

---

## 🚀 Core Integration Patterns

### 1. Async PTY Management

```zig
const tokioz = @import("TokioZ");
const std = @import("std");

pub const AsyncPty = struct {
    fd: std.posix.fd_t,
    read_buf: [4096]u8,
    
    pub fn init(shell_path: []const u8) !AsyncPty {
        // Fork and setup PTY using TokioZ spawn
        return tokioz.spawn(async {
            const pty_fd = try std.posix.openpty();
            const pid = try std.posix.fork();
            
            if (pid == 0) {
                // Child process - exec shell
                try std.posix.execve(shell_path, &[_][]const u8{shell_path}, std.os.environ);
            }
            
            return AsyncPty{ .fd = pty_fd.master, .read_buf = undefined };
        });
    }
    
    pub fn readAsync(self: *AsyncPty) ![]const u8 {
        return tokioz.io.readAsync(self.fd, &self.read_buf);
    }
    
    pub fn writeAsync(self: *AsyncPty, data: []const u8) !void {
        return tokioz.io.writeAsync(self.fd, data);
    }
};
```

### 2. GPU-Accelerated Async Rendering

```zig
pub const AsyncRenderer = struct {
    cuda_context: CudaContext,
    vulkan_device: VulkanDevice,
    render_queue: tokioz.channel.Channel(RenderCommand),
    
    pub fn init() !AsyncRenderer {
        return tokioz.spawn(async {
            const cuda_ctx = try initCudaContext();
            const vk_device = try initVulkanDevice();
            const queue = try tokioz.channel.channel(RenderCommand, 1024);
            
            return AsyncRenderer{
                .cuda_context = cuda_ctx,
                .vulkan_device = vk_device,
                .render_queue = queue,
            };
        });
    }
    
    pub fn renderFrame(self: *AsyncRenderer, terminal_buffer: []const Cell) !void {
        const render_cmd = RenderCommand{ .frame_data = terminal_buffer };
        try self.render_queue.send(render_cmd);
        
        // Process rendering asynchronously
        return tokioz.spawn(async {
            try self.processRenderCommand(render_cmd);
        });
    }
    
    fn processRenderCommand(self: *AsyncRenderer, cmd: RenderCommand) !void {
        // Async CUDA text rasterization
        const cuda_future = tokioz.spawn(async {
            return self.cuda_context.rasterizeText(cmd.frame_data);
        });
        
        // Async Vulkan presentation
        const vulkan_future = tokioz.spawn(async {
            return self.vulkan_device.presentFrame();
        });
        
        // Wait for both operations
        const raster_result = try cuda_future;
        try vulkan_future;
    }
};
```

### 3. Wayland Async Event Handling

```zig
pub const WaylandClient = struct {
    display: *wl_display,
    event_queue: tokioz.channel.Channel(WaylandEvent),
    surface: ?*wl_surface,
    
    pub fn init() !WaylandClient {
        return tokioz.spawn(async {
            const display = try wl_display_connect(null);
            const queue = try tokioz.channel.channel(WaylandEvent, 512);
            
            // Start async event polling
            try tokioz.spawn(async {
                try pollWaylandEvents(display, queue);
            });
            
            return WaylandClient{
                .display = display,
                .event_queue = queue,
                .surface = null,
            };
        });
    }
    
    pub fn handleEvents(self: *WaylandClient) !void {
        while (true) {
            const event = try self.event_queue.recv();
            
            switch (event) {
                .configure => |cfg| try self.handleConfigure(cfg),
                .close => break,
                .key_input => |key| try self.handleKeyInput(key),
                .pointer_motion => |motion| try self.handlePointerMotion(motion),
            }
        }
    }
    
    fn pollWaylandEvents(display: *wl_display, queue: tokioz.channel.Channel(WaylandEvent)) !void {
        while (true) {
            // Non-blocking event dispatch using TokioZ I/O
            const fd = wl_display_get_fd(display);
            try tokioz.io.pollRead(fd);
            
            if (wl_display_dispatch_pending(display) == -1) {
                try queue.send(WaylandEvent.close);
                break;
            }
            
            // Yield to other tasks
            try tokioz.task.yield();
        }
    }
};
```

---

## ⚡ Performance Optimizations

### Async Task Coordination

```zig
pub fn runGhostShell() !void {
    try tokioz.runtime.run(async {
        // Initialize all subsystems concurrently
        const pty_future = tokioz.spawn(async { return AsyncPty.init("/bin/zsh"); });
        const renderer_future = tokioz.spawn(async { return AsyncRenderer.init(); });
        const wayland_future = tokioz.spawn(async { return WaylandClient.init(); });
        
        // Wait for all initialization
        const pty = try pty_future;
        const renderer = try renderer_future;
        const wayland = try wayland_future;
        
        // Main event loop with async coordination
        const input_task = tokioz.spawn(async { try handleInput(pty, wayland); });
        const output_task = tokioz.spawn(async { try handleOutput(pty, renderer); });
        const render_task = tokioz.spawn(async { try renderLoop(renderer, wayland); });
        
        // Coordinate all tasks
        try tokioz.join!(input_task, output_task, render_task);
    });
}

fn handleInput(pty: AsyncPty, wayland: WaylandClient) !void {
    while (true) {
        const input = try wayland.event_queue.recv();
        
        switch (input) {
            .key_input => |key| {
                const key_data = try processKeyInput(key);
                try pty.writeAsync(key_data);
            },
            else => {},
        }
    }
}

fn handleOutput(pty: AsyncPty, renderer: AsyncRenderer) !void {
    var terminal_state = TerminalState.init();
    
    while (true) {
        const data = try pty.readAsync();
        try terminal_state.processVtSequence(data);
        try renderer.renderFrame(terminal_state.cells);
        
        // Use TokioZ sleep for frame pacing
        try tokioz.time.sleep(tokioz.time.Duration.fromMillis(16)); // ~60 FPS
    }
}
```

### Async File Operations

```zig
pub const AsyncFileMonitor = struct {
    watcher: tokioz.io.FileWatcher,
    
    pub fn watchConfig(config_path: []const u8) !void {
        return tokioz.spawn(async {
            const watcher = try tokioz.io.FileWatcher.init();
            try watcher.watch(config_path);
            
            while (true) {
                const event = try watcher.nextEvent();
                if (event.kind == .modify) {
                    try reloadConfig(config_path);
                }
            }
        });
    }
    
    fn reloadConfig(path: []const u8) !void {
        const config_data = try tokioz.io.readFileAsync(path);
        try applyConfig(config_data);
    }
};
```

---

## 🔧 Build Integration

### build.zig Updates

```zig
// Add TokioZ dependency to GHOSTSHELL build
const tokioz_dep = b.dependency("TokioZ", .{
    .target = target,
    .optimize = optimize,
});

const ghostshell = b.addExecutable(.{
    .name = "ghostshell",
    .root_source_file = b.path("src/main.zig"),
    .target = target,
    .optimize = optimize,
});

// Link TokioZ module
ghostshell.root_module.addImport("TokioZ", tokioz_dep.module("TokioZ"));

// Add system libraries for GPU and Wayland
ghostshell.linkSystemLibrary("wayland-client");
ghostshell.linkSystemLibrary("cuda");
ghostshell.linkSystemLibrary("vulkan");
```

### build.zig.zon Dependencies

```zig
.dependencies = .{
    .TokioZ = .{
        .path = "../tokioZ", // Local development
        // .url = "https://github.com/ghostkellz/tokioZ",
        // .hash = "...",
    },
    .wayland = .{
        .url = "https://github.com/zig-wayland/zig-wayland",
        .hash = "1220a4a8e9745c1b5c8b64b4b6d95fcb25d1f66fd89e01b29e07c77f8b1d0f0f",
    },
    .vulkan = .{
        .url = "https://github.com/Snektron/vulkan-zig",
        .hash = "1220b4a8e9745c1b5c8b64b4b6d95fcb25d1f66fd89e01b29e07c77f8b1d0f0f",
    },
},
```

---

## 🚀 Advanced Use Cases

### Multi-Session Management

```zig
pub const SessionManager = struct {
    sessions: std.HashMap(u32, AsyncPty),
    active_session: u32,
    
    pub fn createSession(self: *SessionManager, shell: []const u8) !u32 {
        const session_id = self.getNextId();
        
        const pty = try tokioz.spawn(async {
            return AsyncPty.init(shell);
        });
        
        try self.sessions.put(session_id, pty);
        return session_id;
    }
    
    pub fn switchSession(self: *SessionManager, session_id: u32) !void {
        if (self.sessions.contains(session_id)) {
            self.active_session = session_id;
            
            // Async session switching with smooth transition
            try tokioz.spawn(async {
                try self.animateSessionSwitch(session_id);
            });
        }
    }
};
```

### Async Plugin System

```zig
pub const PluginManager = struct {
    plugins: std.ArrayList(AsyncPlugin),
    event_bus: tokioz.channel.Channel(PluginEvent),
    
    pub fn loadPlugin(self: *PluginManager, plugin_path: []const u8) !void {
        return tokioz.spawn(async {
            const plugin = try AsyncPlugin.load(plugin_path);
            try self.plugins.append(plugin);
            
            // Start plugin event loop
            try tokioz.spawn(async {
                try plugin.eventLoop(self.event_bus);
            });
        });
    }
};
```

---

## 📊 Performance Benefits

Using TokioZ in GHOSTSHELL provides:

- **Zero-copy I/O**: Direct buffer management without unnecessary allocations
- **Cooperative Multitasking**: Efficient task switching without thread overhead  
- **Event-driven Architecture**: Responsive UI with minimal latency
- **Resource Efficiency**: Low memory footprint with precise control
- **GPU Acceleration**: Async CUDA operations don't block the main thread
- **Wayland Optimization**: Non-blocking compositor communication

---

## 🔍 Next Steps

1. **Implement Core Integration**: Start with AsyncPty and basic I/O
2. **Add GPU Acceleration**: Integrate NVIDIA CUDA async operations
3. **Wayland Client**: Implement async Wayland protocol handling
4. **Performance Tuning**: Profile and optimize using TokioZ introspics
5. **Plugin System**: Build async plugin architecture
6. **Testing**: Create comprehensive async test suite

---

*GHOSTSHELL leverages TokioZ to deliver the fastest, most responsive terminal experience on Linux with full NVIDIA and Wayland integration.*

