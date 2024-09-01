//! Auto-generated by Confu (not yet, just a mock to flesh out the APIs)
//! Any changes made to this file will be overwritten next time Confu runs
const std = @import("std");

// TODO: define the data structures
pub const ConfuError = error{
    RequestedUsage,
    MissingExecutableName,
    MissingRequiredParameter,
    UnknownParameter,
    InvalidParameterType,
};

pub const Command = enum {
    cmd1,
};

pub const Param = struct {
    name: []const u8,
    required: bool,
    value: Value,
};

pub const Value = union(enum) {
    Int: i64,
    Float: f64,
    String: []const u8,
    Bool: bool,
};

pub const Args = struct {
    const Self = @This();

    executable_name: []const u8 = undefined,
    command: ?Command = null,
    params: ?[]const Param = null,
    @"error": ?ConfuError = null,
    error_message: []const u8 = undefined,

    pub fn printUsage(self: *const Self) !void {
        if (self.@"error") |err| {
            const stderr_file = std.io.getStdErr().writer();
            var bw = std.io.bufferedWriter(stderr_file);
            const stderr = bw.writer();

            if (err == ConfuError.RequestedUsage) {
                // TODO: switch on command to print appropriate usage, else print top level usage
                try stderr.print("Usage: confu [command] [options]\n", .{});
            } else {
                try stderr.print("\nError: {s}\n", .{self.error_message});
            }

            try bw.flush();
        }
    }

    pub fn hasError(self: *const Self) bool {
        return self.@"error" != null;
    }
};

pub fn parse(allocator: std.mem.Allocator) !Args {
    var arg_iter = try std.process.argsWithAllocator(allocator);
    defer arg_iter.deinit();

    var args = Args{};

    // Get executable name
    if (arg_iter.next()) |executable_name| {
        args.executable_name = executable_name;
    } else {
        args.@"error" = ConfuError.MissingExecutableName;
        args.error_message = "missing executable name";
        return args;
    }

    var verbocity: u8 = 0;

    // Parse Commands
    //   Parse Command Params
    //     in order:
    //       directly provided
    //       environment variables
    while (arg_iter.next()) |arg| {

        // TODO: refactor this into appropriate branches below
        if (eq(arg, "help") or eq(arg, "-h")) {
            args.@"error" = ConfuError.RequestedUsage;
            return args;
        }

        //# Parse commands & shared params

        //## Parse shared long opts
        if (sw(arg, "--")) {
            if (eq(arg[2..], "help")) {
                args.@"error" = ConfuError.RequestedUsage;
                return args;
            }
            if (eq(arg[2..], "verbosity")) {
                verbocity += 1;
                continue;
            }

            args.@"error" = ConfuError.UnknownParameter;
            args.error_message = try std.fmt.allocPrint(allocator, "unknown parameter: `{s}`", .{arg});
            return args;
        }

        //## Parse shared short opts
        if (sw(arg, "-")) {
            continue;
        }

        //## Parse commands

        //### Parse command params
    }

    return args;

    // In case of failures, print usage error message / or allow for custom error
    // handling, and let user decide what to do
}

fn eq(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn sw(a: []const u8, b: []const u8) bool {
    return std.mem.startsWith(u8, a, b);
}