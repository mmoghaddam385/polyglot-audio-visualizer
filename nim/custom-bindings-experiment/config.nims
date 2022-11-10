
# nim c  --passC:-I..\raylib\src --passC:-I..\raylib\src\external --passL:-L..\raylib\src --passC:-Wl,--subsystem,windows --passL:-lraylib --passL:-lopengl32 --passL:-lgdi32 --passL:-lwinmm -r .\main.nim

proc setCompileSwitches() =
  switch("passC", """-I../../raylib\src""")
  switch("passC", """-I../../raylib\src\external""")
  switch("passC", """-Wl,--subsystem,windows""")
  switch("passL", """-L../../raylib\src""")
  switch("passL", """-lraylib""")
  switch("passL", """-lopengl32""")
  switch("passL", """-lgdi32""")
  switch("passL", """-lwinmm""")

task r, "run a basic window":
  exec("make -C ../../raylib/src RAYLIB_RES_FILE=\"\"")

  setCommand("r")
  setCompileSwitches()

task c, "compile the executable":
  setCommand("c")
  setCompileSwitches()

