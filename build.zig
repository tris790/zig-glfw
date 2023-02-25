const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glfwLib = b.addStaticLibrary(.{
        .name = "glfw",
        .target = target,
        .optimize = optimize,
    });

    glfwLib.linkSystemLibrary("pthread");
    glfwLib.addIncludePath("src");
    var src = try std.fs.cwd().openDir("src", .{});
    var dir = try src.openIterableDir(".", .{});
    var it = dir.iterate();
    while (try it.next()) |file| {
        const f: []const u8 = file.name;
        if (std.mem.endsWith(u8, f, ".c")) {
            glfwLib.addCSourceFile(try std.mem.concat(b.allocator, u8, &[2][]const u8{src/, f}) , &[_][]const u8{"-D_GLFW_X11"});
        }
    }

    glfwLib.install();
    glfwLib.installHeadersDirectory("include", "glfw");
    // const exe = b.addExecutable(.{
    //     .name = "glfw-test",
    //     .root_source_file = .{ .path = "src/exemple.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // exe.addIncludePath("include");
    // exe.linkSystemLibrary("GL");
    // exe.linkLibrary(glfwLib);
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
