const yaml = @import("yaml");

pub const ConfV1 = struct {
    output: []const u8,
    env_prefix: ?[]const u8,
};

pub const ParamV1 = struct {
    param_type: []const u8,
    description: []const u8,
    name: ?[]const u8,
    long: ?[]const u8,
    short: ?[]const u8,
    env: ?[]const u8,
    key_type: ?[]const u8,
    value_type: ?[]const u8,
    default_value: ?yaml.Value,
    limit: ?i64,
    required: ?bool,
    redacted: ?bool,
    hidden: ?bool,
    allow_stdin: ?bool,
    allow_stdout: ?bool,
};

pub const CommandV1 = struct {
    description: []const u8,
    params: []ParamV1,
};

pub const ArgsSpecV1 = struct {
    kind: []const u8,
    version: []const u8,
    config: ConfV1,
    shared_params: ?[]ParamV1,
    params: ?[]ParamV1,
    commands: ?[]CommandV1,
};
