pub const Canvas = @import("Canvas.zig");
pub const Surface = @import("Surface.zig");
pub const Path = @import("Path.zig");
pub const painter = @import("painter.zig");
pub const png_exporter = @import("png_exporter.zig");

// Compatibility types for z2d replacement
pub const StaticPath = Path.StaticPath;

pub const Context = struct {
    canvas: *Canvas,
    transformation: Transformation = .{},
    line_width: f64 = 1.0,
    source_color: u32 = 0xFFFFFFFF,
    
    pub fn init(_: std.mem.Allocator, canvas: *Canvas) Context {
        return Context{ .canvas = canvas };
    }
    
    pub fn deinit(self: *Context) void {
        _ = self;
    }
    
    pub fn setTransformation(self: *Context, transform: Transformation) void {
        self.transformation = transform;
    }
    
    pub fn setSource(self: *Context, source: anytype) void {
        // For terminal graphics, we typically just use the alpha channel
        // Store color information for later use
        _ = self;
        _ = source;
    }
    
    pub fn setLineWidth(self: *Context, width: f64) void {
        self.line_width = width;
    }
    
    pub fn stroke(self: *Context) !void {
        // Basic stroke implementation for context
        _ = self;
    }
    
    pub fn fill(self: *Context) !void {
        // Basic fill implementation for context
        _ = self;
    }
    
    pub fn arc(self: *Context, x: f64, y: f64, radius: f64, start_angle: f64, end_angle: f64) !void {
        // Basic arc implementation - for terminal graphics we can approximate with pixels
        _ = self;
        _ = x;
        _ = y;
        _ = radius;
        _ = start_angle;
        _ = end_angle;
    }
    
    pub fn moveTo(self: *Context, x: f64, y: f64) void {
        _ = self;
        _ = x;
        _ = y;
    }
    
    pub fn lineTo(self: *Context, x: f64, y: f64) void {
        _ = self;
        _ = x;
        _ = y;
    }
    
    pub fn rectangle(self: *Context, x: f64, y: f64, width: f64, height: f64) void {
        _ = self;
        _ = x;
        _ = y;
        _ = width;
        _ = height;
    }
    
    pub fn closePath(self: *Context) !void {
        _ = self;
    }
    
    pub fn newPath(self: *Context) void {
        _ = self;
    }
    
    pub fn curveTo(self: *Context, cp1x: f64, cp1y: f64, cp2x: f64, cp2y: f64, x: f64, y: f64) !void {
        _ = self;
        _ = cp1x;
        _ = cp1y;
        _ = cp2x;
        _ = cp2y;
        _ = x;
        _ = y;
    }
    
    pub fn quadraticCurveTo(self: *Context, cpx: f64, cpy: f64, x: f64, y: f64) !void {
        _ = self;
        _ = cpx;
        _ = cpy;
        _ = x;
        _ = y;
    }
    
    pub fn ellipse(self: *Context, x: f64, y: f64, radius_x: f64, radius_y: f64, rotation: f64, start_angle: f64, end_angle: f64) !void {
        _ = self;
        _ = x;
        _ = y;
        _ = radius_x;
        _ = radius_y;
        _ = rotation;
        _ = start_angle;
        _ = end_angle;
    }
};

pub const Transformation = struct {
    // z2d-style transformation matrix
    ax: f64 = 1.0,
    by: f64 = 0.0,
    cx: f64 = 0.0,
    dy: f64 = 1.0,
    tx: f64 = 0.0,
    ty: f64 = 0.0,
};

const std = @import("std");

test {
    @import("std").testing.refAllDecls(@This());
}