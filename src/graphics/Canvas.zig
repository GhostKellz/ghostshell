const Canvas = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;

width: u32,
height: u32,
pixels: []u32,
allocator: Allocator,
image_surface_alpha8: struct {
    buf: []u8,
},

pub fn init(allocator: Allocator, width: u32, height: u32) !Canvas {
    const pixels = try allocator.alloc(u32, width * height);
    const alpha_buf = try allocator.alloc(u8, width * height);
    return Canvas{
        .width = width,
        .height = height,
        .pixels = pixels,
        .allocator = allocator,
        .image_surface_alpha8 = .{ .buf = alpha_buf },
    };
}

pub fn deinit(self: *Canvas) void {
    self.allocator.free(self.pixels);
    self.allocator.free(self.image_surface_alpha8.buf);
}

pub fn clear(self: *Canvas, color: u32) void {
    @memset(self.pixels, color);
}

pub fn setPixel(self: *Canvas, x: u32, y: u32, color: u32) void {
    if (x >= self.width or y >= self.height) return;
    self.pixels[y * self.width + x] = color;
}

pub fn getPixel(self: *Canvas, x: u32, y: u32) u32 {
    if (x >= self.width or y >= self.height) return 0;
    return self.pixels[y * self.width + x];
}

pub fn fillRect(self: *Canvas, x: u32, y: u32, w: u32, h: u32, color: u32) void {
    const end_x = @min(x + w, self.width);
    const end_y = @min(y + h, self.height);
    
    var py = y;
    while (py < end_y) : (py += 1) {
        var px = x;
        while (px < end_x) : (px += 1) {
            self.setPixel(px, py, color);
        }
    }
}

pub fn drawLine(self: *Canvas, x0: i32, y0: i32, x1: i32, y1: i32, color: u32) void {
    const dx: i32 = @intCast(@abs(x1 - x0));
    const dy: i32 = @intCast(@abs(y1 - y0));
    const sx: i32 = if (x0 < x1) 1 else -1;
    const sy: i32 = if (y0 < y1) 1 else -1;
    
    var err: i32 = dx - dy;
    var x = x0;
    var y = y0;
    
    while (true) {
        if (x >= 0 and y >= 0) {
            self.setPixel(@intCast(x), @intCast(y), color);
        }
        
        if (x == x1 and y == y1) break;
        
        const e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x += sx;
        }
        if (e2 < dx) {
            err += dx;
            y += sy;
        }
    }
}

pub fn getWidth(self: *Canvas) u32 {
    return self.width;
}

pub fn getHeight(self: *Canvas) u32 {
    return self.height;
}

// Overloaded putPixel for different parameter types
pub fn putPixel(self: *Canvas, x: u32, y: u32, color: u32) void {
    self.setPixel(x, y, color);
}

// Additional putPixel overload for i32 coordinates and different color types
pub fn putPixelCompat(self: *Canvas, x: i32, y: i32, color: anytype) void {
    if (x >= 0 and y >= 0 and x < self.width and y < self.height) {
        const ux: u32 = @intCast(x);
        const uy: u32 = @intCast(y);
        var pixel_color: u8 = 0;
        
        // Handle different color formats
        if (@hasField(@TypeOf(color), "alpha8")) {
            pixel_color = color.alpha8.a;
        } else {
            pixel_color = @intFromEnum(color);
        }
        
        // Set both color and alpha buffers
        self.setPixel(ux, uy, pixel_color);
        self.image_surface_alpha8.buf[uy * self.width + ux] = pixel_color;
    }
}

pub fn drawCircle(self: *Canvas, cx: i32, cy: i32, radius: u32, color: u32) void {
    const r = @as(i32, @intCast(radius));
    var x: i32 = 0;
    var y: i32 = r;
    var d: i32 = 1 - r;
    
    while (x <= y) {
        // Draw 8 symmetric points
        self.plotIfInBounds(cx + x, cy + y, color);
        self.plotIfInBounds(cx - x, cy + y, color);
        self.plotIfInBounds(cx + x, cy - y, color);
        self.plotIfInBounds(cx - x, cy - y, color);
        self.plotIfInBounds(cx + y, cy + x, color);
        self.plotIfInBounds(cx - y, cy + x, color);
        self.plotIfInBounds(cx + y, cy - x, color);
        self.plotIfInBounds(cx - y, cy - x, color);
        
        if (d < 0) {
            d += 2 * x + 3;
        } else {
            d += 2 * (x - y) + 5;
            y -= 1;
        }
        x += 1;
    }
}

fn plotIfInBounds(self: *Canvas, x: i32, y: i32, color: u32) void {
    if (x >= 0 and y >= 0 and x < self.width and y < self.height) {
        self.setPixel(@intCast(x), @intCast(y), color);
    }
}

// z2d compatibility method
pub fn composite(self: *Canvas, other: anytype, mode: anytype, x: i32, y: i32, opts: anytype) void {
    _ = self;
    _ = other;
    _ = mode;
    _ = x;
    _ = y;
    _ = opts;
    // Placeholder implementation for z2d compatibility
}