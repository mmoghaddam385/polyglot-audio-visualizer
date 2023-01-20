# Zig

To run this, you'll first have to build dependencies (you might have to edit raylib's build.zig if it complains to you):
```
zig build dependencies
```

^^^ This may or may not work...the gist is to build raylib (`../raylib`) and openal-soft (`../openal-soft`).
If this command doesn't work, try building them yourself.

Then run:
```
zig build run
```
