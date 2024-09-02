const std = @import("std");
const confu = @import("generated.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const writer = std.io.getStdErr().writer();

    // TODO: think more about ergonomics and error handling
    var args = try confu.parse(allocator);
    defer args.deinit();

    if (args.hasError()) {
        try args.printUsage();
        std.process.exit(2); // invalid usage
    }

    try writer.print("executable name: {s}\n", .{args.executable_name});
}
