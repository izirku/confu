const std = @import("std");
const yaml = @import("yaml");
const spec = @import("spec.zig");

const log = std.log.scoped(.confu);

pub const std_options = std.Options{
    .log_scope_levels = &[_]std.log.ScopeLevel{
        .{ .scope = .parse, .level = .info },
        .{ .scope = .tokenizer, .level = .info },
    },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var arg_iter = try std.process.argsWithAllocator(allocator);
    defer arg_iter.deinit();
    _ = arg_iter.skip();

    const input_file_name = arg_iter.next().?;
    const output_file_name = arg_iter.next().?;

    log.debug("input YAML: {s}", .{input_file_name});
    log.debug("output ZIG: {s}", .{output_file_name});

    const input_file = try std.fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();

    const input_file_contents = try input_file.readToEndAlloc(allocator, std.math.maxInt(u32));
    defer allocator.free(input_file_contents);

    var untyped_yaml = try yaml.Yaml.load(allocator, input_file_contents);
    defer untyped_yaml.deinit();

    const parsed_yaml = try untyped_yaml.parse(spec.ArgsSpecV1);

    // TODO: write the domain logic
    _ = parsed_yaml;
}
