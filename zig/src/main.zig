const std = @import("std");
const thread = std.Thread;


// This works just as well, but I can't seem to get zls to find raylib.h, so it's unable to provide code completions
// const ray = @cImport({
//     @cInclude("raylib.h");
// });

// raylib.zig auto-generated via zig translate-c. See build-raylib-header task in build.zig
const ray = @import("deps/raylib.zig");
const audio = @import("sound.zig");

const window_width = 1440;
const window_height = 900;

const audio_buffer_len = 4096;
var audio_buffer = std.mem.zeroes([audio_buffer_len]i16);

pub fn main() !void {
    ray.InitWindow(800, 600, "hello world");
    ray.SetTargetFPS(60);

    const audio_device = try audio.initOpenAL(audio_buffer_len);
    // var runtime_0: usize = 0;

    while (!ray.WindowShouldClose()) {
        //try audio.captureAudio(audio_device, &audio_buffer);

        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawFPS(12, 12);
        ray.EndDrawing();
    }

    std.debug.print("what in tarnation\n", .{});

    try audio.shutdownOpenAL(audio_device);
}
