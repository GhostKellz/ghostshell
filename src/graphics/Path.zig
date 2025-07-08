const Path = @This();

const std = @import("std");

// Simple path structure for terminal graphics
// Most terminal graphics are simple shapes, so we keep this minimal
points: std.ArrayList(Point),
nodes: std.ArrayList(Point),
transformation: @import("main.zig").Transformation = .{},

pub const Point = struct { x: f32, y: f32 };

pub fn init(allocator: std.mem.Allocator) Path {
    return Path{
        .points = std.ArrayList(Point).init(allocator),
        .nodes = std.ArrayList(Point).init(allocator),
    };
}

pub fn deinit(self: *Path, allocator: std.mem.Allocator) void {
    _ = allocator;
    self.points.deinit();
    self.nodes.deinit();
}

pub fn moveTo(self: *Path, x: f64, y: f64) !void {
    try self.points.append(.{ .x = @floatCast(x), .y = @floatCast(y) });
    try self.nodes.append(.{ .x = @floatCast(x), .y = @floatCast(y) });
}

pub fn lineTo(self: *Path, x: f64, y: f64) !void {
    try self.points.append(.{ .x = @floatCast(x), .y = @floatCast(y) });
    try self.nodes.append(.{ .x = @floatCast(x), .y = @floatCast(y) });
}

pub fn close(self: *Path, allocator: std.mem.Allocator) !void {
    // For terminal graphics, most paths are simple
    _ = self;
    _ = allocator;
}

pub fn StaticPath(comptime len: usize) type {
    return struct {
        points: [len]Point = undefined,
        count: usize = 0,
        wrapped_path: Path,
        
        const Self = @This();
        
        pub fn init(self: *Self) void {
            self.count = 0;
            self.wrapped_path = Path{
                .points = std.ArrayList(Point).init(std.heap.page_allocator),
                .nodes = std.ArrayList(Point).init(std.heap.page_allocator),
                .transformation = .{},
            };
        }
        
        pub fn moveTo(self: *Self, x: f64, y: f64) void {
            if (self.count < len) {
                self.points[self.count] = .{ .x = @floatCast(x), .y = @floatCast(y) };
                self.count += 1;
            }
        }
        
        pub fn lineTo(self: *Self, x: f64, y: f64) void {
            if (self.count < len) {
                self.points[self.count] = .{ .x = @floatCast(x), .y = @floatCast(y) };
                self.count += 1;
            }
        }
        
        pub fn close(self: *Self) void {
            _ = self;
        }
        
        pub fn curveTo(self: *Self, cp1x: f64, cp1y: f64, cp2x: f64, cp2y: f64, x: f64, y: f64) void {
            // For terminal graphics, we can approximate curves with lines
            // Add the control points and end point
            if (self.count + 2 < len) {
                self.points[self.count] = .{ .x = @floatCast(cp1x), .y = @floatCast(cp1y) };
                self.count += 1;
                self.points[self.count] = .{ .x = @floatCast(cp2x), .y = @floatCast(cp2y) };
                self.count += 1;
                self.points[self.count] = .{ .x = @floatCast(x), .y = @floatCast(y) };
                self.count += 1;
            }
        }
        
        pub fn deinit(self: *Self) void {
            self.wrapped_path.deinit();
        }
    };
}