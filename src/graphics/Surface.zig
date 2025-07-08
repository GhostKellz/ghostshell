const Surface = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const Canvas = @import("Canvas.zig");

canvas: Canvas,
// z2d compatibility fields
image_surface_alpha8: struct {
    buf: []u8,
},
image_surface_rgb: struct {
    buf: []RgbPixel,
},

const RgbPixel = struct { r: u8, g: u8, b: u8 };

pub fn init(
    image_format: anytype,
    alloc: Allocator,
    width: u32,
    height: u32,
) !Surface {
    _ = image_format; // ignore format for now
    const canvas = try Canvas.init(alloc, width, height);
    const alpha_buf = try alloc.alloc(u8, width * height);
    const rgb_buf = try alloc.alloc(RgbPixel, width * height);
    return Surface{ 
        .canvas = canvas,
        .image_surface_alpha8 = .{ .buf = alpha_buf },
        .image_surface_rgb = .{ .buf = rgb_buf },
    };
}

// Legacy init
pub fn initLegacy(
    alloc: Allocator,
    width: u32,
    height: u32,
) !Surface {
    const canvas = try Canvas.init(alloc, width, height);
    const alpha_buf = try alloc.alloc(u8, width * height);
    const rgb_buf = try alloc.alloc(RgbPixel, width * height);
    return Surface{ 
        .canvas = canvas,
        .image_surface_alpha8 = .{ .buf = alpha_buf },
        .image_surface_rgb = .{ .buf = rgb_buf },
    };
}

pub fn deinit(self: *Surface, alloc: Allocator) void {
    self.canvas.deinit();
    alloc.free(self.image_surface_alpha8.buf);
    alloc.free(self.image_surface_rgb.buf);
}

// Additional methods for z2d compatibility
pub fn composite(self: *Surface, other: anytype, mode: anytype, x: i32, y: i32, opts: anytype) void {
    _ = self;
    _ = other;
    _ = mode;
    _ = x;
    _ = y;
    _ = opts;
    // Simple placeholder - real compositing would blend surfaces
}

pub fn getPixels(self: *Surface) []u32 {
    return self.canvas.pixels;
}

pub fn getWidth(self: *Surface) u32 {
    return self.canvas.width;
}

pub fn getHeight(self: *Surface) u32 {
    return self.canvas.height;
}