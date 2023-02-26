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
    lib.addIncludePath("src");
    var dir = try std.fs.cwd().openIterableDir("src", .{});
    var it = dir.iterate();
    while (try it.next()) |file| {
        const fileName: []const u8 = file.name;
        if (std.mem.endsWith(u8, fileName, ".c")) {
            var filePath = try std.mem.concat(b.allocator, u8, &.{ sdkPath("/src/"), fileName });
            // std.log.info("TD: {s}\n", .{filePath});
            lib.addCSourceFile(filePath, &.{"-D_GLFW_X11"});
        }
    }

    lib.install();
    lib.installHeadersDirectory("include/GLFW", "GLFW");
    lib.addIncludePath("include");
    lib.installHeader("include/GLFW/glfw3.h", "GLFW/glfw3.h");
    // const exe = b.addExecutable(.{
    //     .name = "glfw-test",
    //     .root_source_file = .{ .path = "src/exemple.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // exe.addIncludePath("include");
    // exe.linkSystemLibrary("GL");
    // exe.linkLibrary(lib);
    // exe.linkLibC();
    // exe.install();

    // const run_cmd = exe.run();
    // run_cmd.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }

    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);

    // const main_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const test_step = b.step("test", "Run library tests");
    // test_step.dependOn(&main_tests.step);
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}
