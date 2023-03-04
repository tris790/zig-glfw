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
    lib.addIncludePath(sdkPath("/src/"));
    var dir = try std.fs.cwd().openIterableDir(sdkPath("/src/"), .{});
    var it = dir.iterate();
    while (try it.next()) |file| {
        const fileName: []const u8 = file.name;
        if (std.mem.endsWith(u8, fileName, ".c")) {
            var filePath = try std.mem.concat(b.allocator, u8, &.{ sdkPath("/src/"), fileName });
            lib.addCSourceFile(filePath, &.{"-D_GLFW_X11"});
        }
    }

    lib.install();
    lib.installHeadersDirectory(sdkPath("/include/GLFW"), "GLFW");
    lib.addIncludePath(sdkPath("/include"));
    lib.installHeader(sdkPath("/include/GLFW/glfw3.h"), "GLFW/glfw3.h");

    const exe = b.addExecutable(.{
        .name = "glfw-test",
        .root_source_file = .{ .path = "src/exemple.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(sdkPath("/include"));
    exe.linkSystemLibrary("GL");
    exe.linkLibrary(lib);
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}
