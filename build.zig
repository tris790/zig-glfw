const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "glfw",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibC();
    lib.linkSystemLibrary("pthread");
    lib.addIncludePath(b.path("src/"));
    var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });

    var it = dir.iterate();
    while (try it.next()) |file| {
        const fileName: []const u8 = file.name;
        if (std.mem.endsWith(u8, fileName, ".c")) {
            const filePath = try std.mem.concat(b.allocator, u8, &.{ "src/", fileName });
            lib.addCSourceFile(.{ .file = b.path(filePath), .flags = &.{"-D_GLFW_X11"} });
        }
    }

    lib.installHeadersDirectory(b.path("include/GLFW"), "GLFW", .{});
    lib.addIncludePath(b.path("include"));
    lib.installHeader(b.path("include/GLFW/glfw3.h"), "GLFW/glfw3.h");
    b.installArtifact(lib);

    // const exe = b.addExecutable(.{
    //     .name = "glfw-test",
    //     .root_source_file = b.path("src/example.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    // exe.addIncludePath(b.path("include"));
    // exe.linkSystemLibrary("GL");
    // exe.linkLibrary(lib);
    // exe.linkLibC();
    // b.installArtifact(exe);

    // const run_cmd = b.addRunArtifact(exe);

    // run_cmd.step.dependOn(b.getInstallStep());

    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);
}
