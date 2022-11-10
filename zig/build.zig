const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.linkLibC();

    exe.addIncludePath("../raylib/src");
    exe.addIncludePath("../raylib/src/external");
    exe.addLibraryPath("../raylib/src");
    // exe.addLibraryPath(".");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("raylib");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const translate_step = b.step("translate-raylib-header", "Translate local raylib.h for autocompletions.");
    translate_step.makeFn = translateRaylibHeader;
    exe.step.dependOn(translate_step);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(translate_step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);

    
}

fn translateRaylibHeader(_: *std.build.Step) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // TODO: how do I pass the allocator from the build to the step???
    const allocator = gpa.allocator();

    std.debug.print("translating raylib.h...\n", .{});

    const result = try std.ChildProcess.exec(.{ 
        .allocator = allocator,
        .argv = &[_][]const u8{"zig", "translate-c", "../../raylib/src/raylib.h"},
        .max_output_bytes = 1024 * 100
    });

    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    switch (result.term) {
        .Exited => |code| {
            if (code == 0) {
                std.debug.print("saving ./src/raylib.zig...\n", .{});
                var file = try std.fs.cwd().createFile("src/raylib.zig", std.fs.File.CreateFlags{.truncate = true});
                try file.writeAll(result.stdout);
                file.close();
            } else {
                std.debug.print("something went wrong {d}...\n{s}", .{code, result.stderr});
            }
        },
        else => {
            std.debug.print("wtf happened? {}", .{result.term});
        }
    }
}

