# TinyWM (Ruby edition)

This project is an evening experiment to port
Nick Welch's [tinywm](http://incise.org/tinywm.html) from C to Ruby using [FFI](https://github.com/ffi/ffi).

TinyWM uses Xlib as its underlying library.


## Running

It's recommended that you use
[Xephyr](http://www.freedesktop.org/wiki/Software/Xephyr/) to run a nested
X.org server for playing with TinyWM.

1. `bundle install` to get the Ruby dependencies
1. In one terminal run: `Xephyr :1`
1. In another: `DISPLAY=:1.0 ./tinywm` 
1. In another: `DISPLAY=:1.0 xcalc`

### Keybindings

TinyWM only really has a couple key-bindings:

* `Mod4+F1` - Raise the window under the cursor
* `Mod4+LeftMouse` - Move the window
* `Mod4+RightMouse` - Resize the window
