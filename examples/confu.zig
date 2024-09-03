const std = @import("std");
const confu = @import("generated.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // const writer = std.io.getStdErr().writer();

    // TODO: think more about ergonomics and error handling
    var args = try confu.parse(allocator);
    // var args = try confu.parse(std.heap.page_allocator);
    defer args.deinit();

    if (args.hasError()) {
        try args.printError();
        std.process.exit(2); // invalid usage
    }

    if (args.helpRequested()) {
        try args.printUsage();
    }

    if (args.command) |cmd| {
        switch (cmd) {
            .cmd1 => {
                std.debug.print("got cmd1\n", .{});
                const cmd_args = try args.getCmd1Args();
                _ = cmd_args;
            },
        }
    }
    // or:
    // this is cleaner, no need to create `.get<Cmd>Args` functions
    if (args.command_opts) |opts| {
        switch (opts) {
            .cmd1 => |cmd_args| {
                _ = cmd_args;
                std.debug.print("got cmd1\n", .{});
            },
        }
    }
}
