# sve2-fe

Frontend web editor for [sve2](https://github.com/btmxh/sve2).

## Build instructions

This uses the standard Tauri/pnpm setup, so go there for documentation.

`sve2-fe` ships with its own preload Lua script for sve2, with dependencies:

- [lua-cjson](https://github.com/mpx/lua-cjson)
- [luv](https://github.com/luvit/luv)
- [llhttp.lua](https://github.com/MunifTanjim/llhttp.lua)

Currently, the preload script only starts a HTTP server for RPC, so one should
run it with another preload script that actually renders stuff onto the screen.
