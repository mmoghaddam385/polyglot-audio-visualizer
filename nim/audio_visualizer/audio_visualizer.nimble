# Package

version       = "0.1.0"
author        = "Michael Moghaddam"
description   = "An audio visualizer in Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["audio_visualizer"]


# Dependencies

requires "nim >= 1.6.8"
requires "nimraylib_now == 0.15.0"
requires "openal == 0.1.1"
