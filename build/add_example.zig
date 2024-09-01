const std = @import("std");
const util = @import("util.zig");

const State = struct {
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    examples_step: *std.Build.Step,
    install_examples_step: *std.Build.Step,
    install_opts: std.Build.Step.InstallArtifact.Options,
};

var state: State = undefined;

pub const Dependency = struct {
    import_name: []const u8,
    module: *std.Build.Module,

    pub fn create(import_name: []const u8, module_name: []const u8) Dependency {
        const dep = state.b.dependency(import_name, .{});
        return Dependency{ .import_name = import_name, .module = dep.module(module_name) };
    }

    pub fn createLocal(import_name: []const u8, path: []const u8) Dependency {
        const module = state.b.createModule(.{ .root_source_file = state.b.path(path) });
        // const dep = state.b.dependency(import_name, .{});
        // return Dependency{ .import_name = import_name, .module = dep.module(module_name) };
        return Dependency{ .import_name = import_name, .module = module };
    }
};

/// Initialize an internal state, register the "examples" and "install-examples" steps.
pub fn init(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    // const target_query = std.Target.Query.parse(.{}) catch unreachable;
    // const target = b.resolveTargetQuery(target_query);

    state = State{
        .b = b,
        .target = target,
        .optimize = optimize,
        .examples_step = b.step("examples", "Build examples"),
        .install_examples_step = b.step("install-examples", "Install examples"),
        .install_opts = .{
            .dest_dir = .{ .override = .{ .custom = "./examples" } },
        },
    };

    // we want to build all the examples before installing them
    state.install_examples_step.dependOn(state.examples_step);

    // in case we want to install the examples when running `zig build` (the default `install` step):
    // b.install_step.dependOn(&state.install_examples_step);
}

/// Given a `name` of an example, say `"foo"`, register an example step `run-foo` that expects
/// `./examples/foo.zig` as its entry point. Compiled binary will be installed in the `./zig-out/examples` directory.
pub fn add(name: []const u8) void {
    addWithDependencies(name, &.{});
}

pub fn addWithDependencies(name: []const u8, deps: []const Dependency) void {
    const allocator = state.b.allocator;
    const exe = state.b.addExecutable(.{
        .name = name,
        .root_source_file = state.b.path(util.concat(allocator, &.{ "examples/", name, ".zig" })),
        .target = state.target,
        .optimize = state.optimize,
    });

    for (deps) |d| {
        exe.root_module.addImport(d.import_name, d.module);
    }

    // examples step depends on all examples
    // i.e. builds all the examples
    state.examples_step.dependOn(&exe.step);

    // we want to install the examples in the examples directory
    // so, we create a custom install step, that is not paranted to the top-level install step
    const install_step = state.b.addInstallArtifact(exe, state.install_opts);

    // install examples step depends on the custom install step
    state.install_examples_step.dependOn(&install_step.step);

    // register executable artifact to be run, allowing for passing arguments
    const run_exe_cmd = state.b.addRunArtifact(exe);
    if (state.b.args) |args| {
        run_exe_cmd.addArgs(args);
    }

    // it will depend on our custom install step, so it's ran from the output directory
    // and not the cache directory
    run_exe_cmd.step.dependOn(&install_step.step);

    // here we create a user exposed step that depends on the `run_exe_cmd` step,
    // which will actually run the example and optionally take arguments
    const run_exe_step = state.b.step(
        util.concat(allocator, &.{ "run-", name }),
        util.concat(allocator, &.{ "Run the ", name, " example" }),
    );
    run_exe_step.dependOn(&run_exe_cmd.step);
}
