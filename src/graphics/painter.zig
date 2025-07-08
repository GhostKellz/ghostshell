const std = @import("std");
const Canvas = @import("Canvas.zig");
const Surface = @import("Surface.zig");
const Path = @import("Path.zig");

pub const FillError = error{OutOfMemory};
pub const StrokeError = error{OutOfMemory};

pub const FillOpts = struct {
    color: u32 = 0xFFFFFFFF,
};

pub const StrokeOpts = struct {
    color: u32 = 0xFFFFFFFF,
    line_width: f64 = 1.0,
    line_cap_mode: enum { butt, round, square } = .butt,
    
    // Legacy compatibility
    width: f32 = 1.0,
};

pub fn fill(
    allocator: std.mem.Allocator,
    surface: anytype,
    source: anytype,
    nodes: []const Path.Point,
    opts: FillOpts,
) FillError!void {
    _ = allocator;
    _ = source;
    
    // Convert nodes to a simple path
    if (nodes.len >= 3) {
        // Find bounding box
        var min_x: f32 = nodes[0].x;
        var min_y: f32 = nodes[0].y;
        var max_x: f32 = min_x;
        var max_y: f32 = min_y;
        
        for (nodes[1..]) |point| {
            min_x = @min(min_x, point.x);
            min_y = @min(min_y, point.y);
            max_x = @max(max_x, point.x);
            max_y = @max(max_y, point.y);
        }
        
        // Handle both Canvas and Surface types
        if (@TypeOf(surface.*) == Canvas) {
            surface.fillRect(
                @intFromFloat(@max(0, min_x)),
                @intFromFloat(@max(0, min_y)),
                @intFromFloat(@max(1, max_x - min_x)),
                @intFromFloat(@max(1, max_y - min_y)),
                opts.color
            );
        } else {
            surface.canvas.fillRect(
                @intFromFloat(@max(0, min_x)),
                @intFromFloat(@max(0, min_y)),
                @intFromFloat(@max(1, max_x - min_x)),
                @intFromFloat(@max(1, max_y - min_y)),
                opts.color
            );
        }
    }
}

pub fn stroke(
    allocator: std.mem.Allocator,
    surface: anytype,
    source: anytype,
    nodes: []const Path.Point,
    opts: StrokeOpts,
) StrokeError!void {
    _ = allocator;
    _ = source;
    
    // Simple stroke implementation
    if (nodes.len >= 2) {
        for (0..nodes.len - 1) |i| {
            const p1 = nodes[i];
            const p2 = nodes[i + 1];
            
            // Handle both Canvas and Surface types
            if (@TypeOf(surface.*) == Canvas) {
                surface.drawLine(
                    @intFromFloat(p1.x),
                    @intFromFloat(p1.y),
                    @intFromFloat(p2.x),
                    @intFromFloat(p2.y),
                    opts.color
                );
            } else {
                surface.canvas.drawLine(
                    @intFromFloat(p1.x),
                    @intFromFloat(p1.y),
                    @intFromFloat(p2.x),
                    @intFromFloat(p2.y),
                    opts.color
                );
            }
        }
    }
}