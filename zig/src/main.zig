const std = @import("std");


// This works just as well, but I can't seem to get zls to find raylib.h, so it's unable to provide code completions
// const ray = @cImport({
//     @cInclude("raylib.h");
// });

// raylib.zig auto-generated via zig translate-c. See build-raylib-header task in build.zig
const ray = @import("raylib.zig");

pub fn main() !void {

    std.debug.print("what this? {}", .{ray});
    ray.InitWindow(800, 600, "hello world");
    ray.SetTargetFPS(60);

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawFPS(12, 12);
        ray.EndDrawing();
    }
}
