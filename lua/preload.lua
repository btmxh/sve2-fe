-- add to require path
local path = require("pl.path")
local this_script_dir = path.dirname(debug.getinfo(1).short_src)
package.path = this_script_dir .. "/?.lua;" .. package.path

local sve = require("sve")
local cjson = require("cjson")
local HTTPServer = require("rpc.server")
local HTTPMethod = require("rpc.types").HTTPMethod
local HTTPResponseCode = require("rpc.types").HTTPResponseCode

local server = HTTPServer.new(function(req, res)
  -- needed for cors shit
  res:addHeader("Access-Control-Allow-Origin", "*")

  if req.method == HTTPMethod.POST and req.url == "/eval" then
    local cb, err = loadstring(req.body)
    if cb == nil then
      res:write(err or "no error"):finish(HTTPResponseCode.BAD_REQUEST)
      return
    end

    local ret_value = cb()
    local json = cjson.encode(ret_value)
    res:addHeader("Content-Type", "application/json")
        :write(json)
        :finish(HTTPResponseCode.OK)
    return
  end

  res:write("unsupported route"):finish(HTTPResponseCode.BAD_REQUEST)
end, "127.0.0.1", 1234)

sve.add_render_callback(function()
  server:update()
end)
