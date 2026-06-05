const std = @import("std");

// Although this function looks imperative, it does not perform the build
// directly and instead it mutates the build graph (`b`) that will be then
// executed by an external runner. The functions in `std.Build` implement a DSL
// for defining build steps and express dependencies between them, allowing the
// build runner to parallelize the build automatically (and the cache system to
// know when a step doesn't need to be re-run).
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    //const mod = b.addModule("structs", .{
    // The root source file is the "entry point" of this module. Users of
    // this module will only be able to access public declarations contained
    // in this file, which means that if you have declarations that you
    // intend to expose to consumers that were defined in other files part
    // of this module, you will have to make sure to re-export them from
    // the root file.
    //.root_source_file = b.path("src/root.zig"),
    // Later on we'll use this module as the root module of a test executable
    // which requires us to specify a target.
    //.target = target,
    //});

    const exe = b.addExecutable(.{
        .name = "inventory",
        .root_module = b.createModule(.{
            // b.createModule defines a new module just like b.addModule but,
            // unlike b.addModule, it does not expose the module to consumers of
            // this package, which is why in this case we don't have to give it a name.
            .root_source_file = b.path("src/main.zig"),
            // Target and optimization levels must be explicitly wired in when
            // defining an executable or library (in the root module), and you
            // can also hardcode a specific target for an executable or library
            // definition if desireable (e.g. firmware for embedded devices).
            .target = target,
            .optimize = optimize,
            // List of modules available for import in source files part of the
            // root module.
            .imports = &.{
                // Here "structs" is the name you will use in your source code to
                // import this module (e.g. `@import("structs")`). The name is
                // repeated because you are allowed to rename your imports, which
                // can be extremely useful in case of collisions (which can happen
                // importing modules from different packages).
                //.{ .name = "structs", .module = mod },
            },
        }),
    });

    exe.root_module.link_libc = true;
    exe.linkSystemLibrary("sqlite3");

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
