type
  Color* {.importc: "Color", header: "raylib.h", bycopy.} = object
    r* {.importc: "r".}: uint8
    g* {.importc: "g".}: uint8
    b* {.importc: "b".}: uint8
    a* {.importc: "a".}: uint8

proc init_window(width: cint, height: cint, name: cstring) {.header: "raylib.h", importc: "InitWindow"}
proc set_target_fps(fps: cint) {.header: "raylib.h", importc:"SetTargetFPS"}
proc window_should_close(): bool {.header: "raylib.h", importc:"WindowShouldClose"}
proc begin_drawing() {.header: "raylib.h", importc: "BeginDrawing"}
proc end_drawing() {.header: "raylib.h", importc: "EndDrawing"}
proc draw_text(text: cstring; posX: cint; posY: cint; fontSize: cint; color: Color) {.header: "raylib.h", importc: "DrawText"}


echo "Hello World"

init_window(800, 400, "hello from nim")
set_target_fps(60)

while not window_should_close():
  begin_drawing()

  draw_text("hello from nim", 200, 200, 24, Color(r: 200, g: 200, b: 200, a: 255))

  end_drawing()
