const std = @import("std");
const examples = @import("build/add_example.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "confu",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const dep_zig_yaml = b.dependency("zig-yaml", .{}); // here `zig-yaml` refers to a key in `build.zig.zon` file
    exe.root_module.addImport("yaml", dep_zig_yaml.module("yaml")); // first `yaml` is how we refer to the actual `yaml` (second) module inside the package

    const run_cmd = b.addRunArtifact(exe); // run step

    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    examples.init(b, target, optimize);
    examples.add("confu");
}
