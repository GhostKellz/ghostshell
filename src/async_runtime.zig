//! Async runtime integration for ghostshell using TokioZ
//! This module provides async functionality for terminal operations

const std = @import("std");
// TokioZ async runtime for ghostshell
const tokioZ = @import("tokioZ");

/// Async runtime instance for ghostshell
pub const Runtime = struct {
    allocator: std.mem.Allocator,
    rt: *tokioZ.Runtime,
    
    pub fn init(allocator: std.mem.Allocator) !Runtime {
        const rt = try tokioZ.Runtime.init(allocator, .{});
        return Runtime{
            .allocator = allocator,
            .rt = rt,
        };
    }
    
    pub fn deinit(self: *Runtime) void {
        self.rt.deinit();
    }
    
    /// Start the async runtime with a task
    pub fn block_on(self: *Runtime, comptime func: anytype, args: anytype) !@TypeOf(@call(.auto, func, args)) {
        return self.rt.blockOn(func, args);
    }
    
    /// Spawn an async task
    pub fn spawn(self: *Runtime, comptime func: anytype, args: anytype) !u32 {
        return self.rt.spawnTask(func, args);
    }
};

/// Initialize the global async runtime for ghostshell
pub fn initGlobalRuntime(allocator: std.mem.Allocator) !Runtime {
    return Runtime.init(allocator);
}

/// Async PTY operations using tokioZ
pub const AsyncPty = struct {
    runtime: *Runtime,
    pty_fd: ?std.posix.fd_t,
    read_buffer: []u8,
    
    pub fn init(runtime: *Runtime, pty_fd: std.posix.fd_t, allocator: std.mem.Allocator) !AsyncPty {
        const buffer = try allocator.alloc(u8, 4096); // Default PTY buffer size
        return AsyncPty{
            .runtime = runtime,
            .pty_fd = pty_fd,
            .read_buffer = buffer,
        };
    }
    
    pub fn deinit(self: *AsyncPty, allocator: std.mem.Allocator) void {
        allocator.free(self.read_buffer);
        if (self.pty_fd) |fd| {
            std.posix.close(fd);
        }
    }
    
    /// Async read from PTY using tokioZ
    pub fn read(self: *AsyncPty, buffer: []u8) !usize {
        if (self.pty_fd == null) return error.InvalidFd;
        
        // Spawn async read task using tokioZ
        const ReadTask = struct {
            fd: std.posix.fd_t,
            buf: []u8,
            result: usize = 0,
            
            fn readTask(task: *@This()) !void {
                // Non-blocking read from PTY
                const bytes_read = std.posix.read(task.fd, task.buf) catch |err| switch (err) {
                    error.WouldBlock => 0,
                    else => return err,
                };
                task.result = bytes_read;
            }
        };
        
        var read_task = ReadTask{
            .fd = self.pty_fd.?,
            .buf = buffer,
        };
        
        // Execute async read through tokioZ
        _ = try self.runtime.spawn(ReadTask.readTask, .{&read_task});
        return read_task.result;
    }
    
    /// Async write to PTY using tokioZ
    pub fn write(self: *AsyncPty, data: []const u8) !usize {
        if (self.pty_fd == null) return error.InvalidFd;
        
        // Spawn async write task using tokioZ
        const WriteTask = struct {
            fd: std.posix.fd_t,
            data: []const u8,
            result: usize = 0,
            
            fn writeTask(task: *@This()) !void {
                // Non-blocking write to PTY
                const bytes_written = std.posix.write(task.fd, task.data) catch |err| switch (err) {
                    error.WouldBlock => 0,
                    else => return err,
                };
                task.result = bytes_written;
            }
        };
        
        var write_task = WriteTask{
            .fd = self.pty_fd.?,
            .data = data,
        };
        
        // Execute async write through tokioZ
        _ = try self.runtime.spawn(WriteTask.writeTask, .{&write_task});
        return write_task.result;
    }
    
    /// Async PTY resize operation
    pub fn setSize(self: *AsyncPty, rows: u16, cols: u16) !void {
        if (self.pty_fd == null) return error.InvalidFd;
        
        const ResizeTask = struct {
            fd: std.posix.fd_t,
            rows: u16,
            cols: u16,
            
            fn resizeTask(task: *@This()) !void {
                const winsize = std.posix.system.winsize{
                    .ws_row = task.rows,
                    .ws_col = task.cols,
                    .ws_xpixel = 0,
                    .ws_ypixel = 0,
                };
                
                // Set PTY window size
                const rc = std.c.ioctl(task.fd, std.posix.system.T.IOCSWINSZ, &winsize);
                if (rc != 0) return error.IoctlFailed;
            }
        };
        
        var resize_task = ResizeTask{
            .fd = self.pty_fd.?,
            .rows = rows,
            .cols = cols,
        };
        
        _ = try self.runtime.spawn(ResizeTask.resizeTask, .{&resize_task});
    }
    
    /// Start continuous async reading from PTY
    pub fn startAsyncReading(self: *AsyncPty, callback: *const fn([]const u8) void) !void {
        const ReadLoopTask = struct {
            pty: *AsyncPty,
            cb: *const fn([]const u8) void,
            
            fn readLoop(task: *@This()) !void {
                while (task.pty.pty_fd != null) {
                    const bytes_read = task.pty.read(task.pty.read_buffer) catch |err| switch (err) {
                        error.WouldBlock => {
                            // Sleep briefly before retrying
                            std.time.sleep(1_000_000); // 1ms
                            continue;
                        },
                        else => return err,
                    };
                    
                    if (bytes_read > 0) {
                        task.cb(task.pty.read_buffer[0..bytes_read]);
                    }
                }
            }
        };
        
        var read_loop = ReadLoopTask{
            .pty = self,
            .cb = callback,
        };
        
        _ = try self.runtime.spawn(ReadLoopTask.readLoop, .{&read_loop});
    }
};

/// Async terminal event handling using tokioZ
pub const AsyncTerminal = struct {
    runtime: *Runtime,
    event_queue: std.ArrayList(TerminalEvent),
    allocator: std.mem.Allocator,
    
    const TerminalEvent = union(enum) {
        input: []const u8,
        resize: struct { rows: u16, cols: u16 },
        focus: bool,
        paste: []const u8,
    };
    
    pub fn init(runtime: *Runtime, allocator: std.mem.Allocator) !AsyncTerminal {
        return AsyncTerminal{
            .runtime = runtime,
            .event_queue = std.ArrayList(TerminalEvent).init(allocator),
            .allocator = allocator,
        };
    }
    
    pub fn deinit(self: *AsyncTerminal) void {
        self.event_queue.deinit();
    }
    
    /// Queue a terminal event for async processing
    pub fn queueEvent(self: *AsyncTerminal, event: TerminalEvent) !void {
        try self.event_queue.append(event);
    }
    
    /// Process terminal events asynchronously using tokioZ
    pub fn processEvents(self: *AsyncTerminal) !void {
        const EventProcessorTask = struct {
            terminal: *AsyncTerminal,
            
            fn processTask(task: *@This()) !void {
                // Process all queued events
                while (task.terminal.event_queue.items.len > 0) {
                    const event = task.terminal.event_queue.orderedRemove(0);
                    
                    switch (event) {
                        .input => |data| {
                            // Process keyboard input asynchronously
                            std.log.debug("Async processing input: {s}", .{data});
                        },
                        .resize => |size| {
                            // Process terminal resize asynchronously
                            std.log.debug("Async processing resize: {}x{}", .{ size.cols, size.rows });
                        },
                        .focus => |focused| {
                            // Process focus events asynchronously
                            std.log.debug("Async processing focus: {}", .{focused});
                        },
                        .paste => |data| {
                            // Process paste events asynchronously
                            std.log.debug("Async processing paste: {s}", .{data});
                        },
                    }
                }
            }
        };
        
        var processor = EventProcessorTask{ .terminal = self };
        _ = try self.runtime.spawn(EventProcessorTask.processTask, .{&processor});
    }
    
    /// Handle input events asynchronously
    pub fn handleInput(self: *AsyncTerminal, input: []const u8) !void {
        // Clone input data for async processing
        const input_copy = try self.allocator.dupe(u8, input);
        try self.queueEvent(.{ .input = input_copy });
        try self.processEvents();
    }
    
    /// Handle resize events asynchronously
    pub fn handleResize(self: *AsyncTerminal, rows: u16, cols: u16) !void {
        try self.queueEvent(.{ .resize = .{ .rows = rows, .cols = cols } });
        try self.processEvents();
    }
    
    /// Handle focus events asynchronously
    pub fn handleFocus(self: *AsyncTerminal, focused: bool) !void {
        try self.queueEvent(.{ .focus = focused });
        try self.processEvents();
    }
    
    /// Handle paste events asynchronously
    pub fn handlePaste(self: *AsyncTerminal, data: []const u8) !void {
        const paste_copy = try self.allocator.dupe(u8, data);
        try self.queueEvent(.{ .paste = paste_copy });
        try self.processEvents();
    }
    
    /// Start async event processing loop
    pub fn startEventLoop(self: *AsyncTerminal) !void {
        const EventLoopTask = struct {
            terminal: *AsyncTerminal,
            
            fn eventLoop(task: *@This()) !void {
                while (true) {
                    // Process events every 10ms
                    try task.terminal.processEvents();
                    
                    // Use tokioZ sleep for non-blocking delay
                    try task.terminal.runtime.rt.asyncSleep(10);
                }
            }
        };
        
        var event_loop = EventLoopTask{ .terminal = self };
        _ = try self.runtime.spawn(EventLoopTask.eventLoop, .{&event_loop});
    }
};

test "async runtime initialization" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var runtime = try initGlobalRuntime(allocator);
    defer runtime.deinit();
    
    // Test that we can create async components
    const async_pty = AsyncPty.init(&runtime);
    _ = async_pty;
    
    const async_terminal = AsyncTerminal.init(&runtime);
    _ = async_terminal;
}