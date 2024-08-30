const std = @import("std");
const yaml = @import("yaml");
const spec = @import("spec.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stderr = std.io.getStdErr().writer();

    var arg_iter = try std.process.argsWithAllocator(allocator);
    defer arg_iter.deinit();
    _ = arg_iter.skip();

    const input_file_name = arg_iter.next().?;
    const output_file_name = arg_iter.next().?;

    try stderr.print("input YAML: {s}\n", .{input_file_name});
    try stderr.print("output ZIG: {s}\n", .{output_file_name});

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
