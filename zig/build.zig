const std = @import("std");
const builtin = @import("builtin");

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
    exe.addIncludePath("../openal-soft/include");

    exe.addLibraryPath("../raylib/src/zig-out/lib");
    exe.addLibraryPath("../openal-soft/build/Release");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("raylib");

    exe.linkSystemLibrary("OpenAL32");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const translate_step = b.step("dependencies", "Build local dependencies and translate headers to zig.");
    translate_step.makeFn = buildDependencies;

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);

    
}

fn buildDependencies(_: *std.build.Step) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; // TODO: how do I pass the allocator from the build to the step???
    const allocator = gpa.allocator();

    const alreadyExistsErr = std.os.MakeDirError.PathAlreadyExists;
    std.fs.cwd().makeDir("./src/deps") catch |err| if (err != alreadyExistsErr) { return err; };
    std.fs.cwd().makeDir("./src/deps/AL") catch |err| if (err != alreadyExistsErr) { return err; };

    std.debug.print("building raylib...\n", .{});
    try execCommand(allocator, &[_][]const u8{"zig", "build"}, "../raylib/src");

    var cmake: []const u8 = switch (builtin.os.tag) {
        .windows => "C:\\Program Files\\CMake\\bin\\cmake.exe",
        else => "cmake"
    };

    if (std.process.getEnvVarOwned(allocator, "CMAKE")) |envvar| {
        cmake = envvar;
    } else |_| {}
    
    std.debug.print("using cmake '{s}'\n", .{cmake});
    std.debug.print("generating configs for openal...\n", .{});
    try execCommand(allocator, &[_][]const u8{cmake, "-S", ".", "-B", "./build"}, "../openal-soft");

    std.debug.print("building openal...\n", .{});
    try execCommand(allocator, &[_][]const u8{cmake, "--build", "./build", "--config", "Release"}, "../openal-soft");

    try translateHeader(allocator, "../raylib/src/raylib.h", "./src/deps/raylib.zig");
    try translateHeader(allocator, "../openal-soft/include/AL/al.h", "./src/deps/AL/al.zig");
    try translateHeader(allocator, "../openal-soft/include/AL/alc.h", "./src/deps/AL/alc.zig");
}

fn execCommand(allocator: std.mem.Allocator, command: []const []const u8, cwd: []const u8) !void {
    const result = try std.ChildProcess.exec(.{
        .allocator = allocator,
        .cwd = cwd,
        .argv = command,
        .max_output_bytes = 1000 * 1024,
    });

    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    switch (result.term) {
        .Exited => |code| {
            if (code != 0) {
                std.debug.print("error code {d}:\n{s}", .{code, result.stderr});
                return error.ExecCodeError;
            }
        },
        else => {
            std.debug.print("something weird happened; {s}", .{result.stderr});
            return error.ExecError;
        }
    }
}

fn translateHeader(allocator: std.mem.Allocator, headerFile: []const u8, outputFile: []const u8) !void {
    std.debug.print("translating {s}...\n", .{headerFile});

    const result = try std.ChildProcess.exec(.{
        .allocator = allocator,
        .argv = &[_][]const u8{"zig", "translate-c", headerFile},
        .max_output_bytes = 100 * 1024
    });

    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    switch (result.term) {
        .Exited => |code| {
            if (code == 0) {
                std.debug.print("saving translated file {s}...\n", .{outputFile});
                const file = try std.fs.cwd().createFile(outputFile, std.fs.File.CreateFlags{.truncate = true});
                defer file.close();
                try file.writeAll(result.stdout);
            } else {
                std.debug.print("something went wrong {d}...\n{s}", .{code, result.stderr});
                return error.ExecCodeError;
            }
        },
        else => {
            std.debug.print("wtf happened? {}", .{result.term});
            return error.ExecError;
        }
    }
} 