# polyglot-audio-visualizer

This repo holds many different audio visualizers written in many different languages.

Why? 

It's a side project idk. 
Audio visualizers can be fun to write.
It combines the need for low-latency processing with artistic expression.
Originally I started writing an audio visualizer with the idea of running it on a raspberry pi and mounting it on a wall,
which adds an extra element of challenge to it (raspberry pi's are weak af when it comes to graphics).
Maybe I'll make my way back to that idea one day who knows.

More recently, my interest in slightly esoteric languages has taken over, 
so I decided to organize myself a bit and put all my attempts into one repo.

This repo serves as a log and archive of my attempts at writing audio visualizers in various different languages. 

## C/C++

Where it all began...

C was an obvious choice back when I wanted to run this on a raspberry pi and didn't know what I was doing.
There are plenty of low-level graphics and audio libraries available. 
I chose ALSA and Raylib...mostly because I found good examples of how to use each.

Raylib turned out to be a great choice, ALSA less so.
ALSA is a fine project don't get me wrong, but being the Advanced _Linux_ Sound Architecture, it isn't exactly portable.
I didn't care at first, since I was building for a raspberry pi,
but as time went on I was annoyed that I couldn't develop on my Windows PC or Macbook.

Eventually I added more functionality and started integrating C++ (more like _C with classes_ in my case).

Currently, this implementation is the most performant and feature rich. 
It easily maintains 45-50 FPS on a raspberry pi 4 and supports 6 different visualizations (some clearly better than others...).

### Secret Python Version

Within the C/C++ repo there lives a [python audio visualizer](c_cpp/raspberry-pi-audio-visualizer/python_version).
Originally intended as a platform to prototype visualization ideas, it was quickly abandoned as being painfully slow.

I'm sure I didn't take full advantage of some python features to speed it up, but I don't care. I didn't like it.

## Rust

Everyone loves rust right? It's supposed to be fast, modern, memory safe, what's not to like?

It's...fine I guess. Personally I don't like the syntax. 
Far too many symbols and special characters for my taste.
I don't fully understand how it gets such high ratings on developer surveys but whatever,
maybe I just need more time to get used to the borrow-checker.
Borrow-checking is definitely an interesting and cool topic.

(this is just my opinion, please don't hate me)

I wasn't able to get it to run on my raspberry pi because the raylib bindings library I chose doesn't support it
(my own fault for just skimming the README...).

I didn't really enjoy the experience of writing this implementation, 
so I didn't bother trying to find another graphics library that would work on raspberry pi.

## nim

My first foray into a slightly esoteric language (hopefully I don't upset anyone by categorizing it like that...).

I learned about nim from a coworker who mentioned it should have good C-interop support,
which makes sense since it can be transpiled to C code.

First impressions are that C interop is definitely good! 
But not as good as I'd hoped...

I was hoping for a stronger set of tooling for generating bindings for C headers. 
`c2nim` gets the job done but still requires a good amount of manual tweaking of the 
input headers + output nim files to really work. Particularly on non-trivial headers like raylib's.

While attempting to make my own bindings for raylib in nim I learned a lot about gcc and the linker,
which will probably come in handy as I continue down this list of languages.

Ultimately though, I ended up using a 3rd party library who did the hard work of dealing with the quirks of `c2nim` and raylib's headers.

This implementation is still a work in progress.

---

Languages to add (in no particular order):
- D
- zig
- odin
- V
- Pony
- OCaml
- Haskell
- Kotlin
