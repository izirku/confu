const std = @import("std");
const Allocator = std.mem.Allocator;

/// Given a build context `b` (used for its allocator), and a slice of slices of `u8`, in a form of
/// `&.{"foo", bar, "baz", ...}`, concatenate all the slices into a single allocation and return
/// a slice of `u8` ("string") containing that allocation.
pub fn concat(allocator: Allocator, slices: []const []const u8) []u8 {
    return std.mem.concat(allocator, u8, slices) catch unreachable;
}
