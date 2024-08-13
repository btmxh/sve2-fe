local uv = require("luv")
local http = require("llhttp")
local buf = require("string.buffer")
local Response = require("rpc.types").Response

--- @class HTTPServer
--- @field handler fun(req: Request, res: Response): nil
--- @field server unknown
local HTTPServer = {}
HTTPServer.__index = HTTPServer

--- @param handler fun(req: Request, res: Response): nil
--- @param ip string
--- @param port integer
function HTTPServer.new(handler, ip, port)
  local self = {}
  self.handler = handler
  self.server = uv.new_tcp()
  self.server:bind(ip, port)
  self.server:listen(128, function(err)
    if err then
      sve.warn("listen error: " .. err)
      return
    end

    local client = uv.new_tcp()
    self.server:accept(client)

    local parser = http.Parser:new {
      type = http.enum.type.REQUEST
    }

    --- @type HTTPMethod|nil
    local method = nil
    --- @type string|nil
    local url = nil
    --- @type table<string, string>
    local headers = {}
    --- @type string.buffer
    local body = buf.new()

    ---@diagnostic disable-next-line: redefined-local
    client:read_start(function(err, chunk)
      if err then
        sve.warn("read error: " .. err)
        client:shutdown()
        return
      end

      if chunk == nil then
        parser:reset()
        client:close()
        client:shutdown()
        return
      end

      --- @param err string
      --- @diagnostic disable-next-line: redefined-local
      local function malformed_request(err)
        client:write("HTTP/1.1 400 Bad Request\r\n")
        client:write("Content-Length: " .. #err .. "\r\n")
        client:write(err .. "\r\n\r\n")
        client:close()
        client:shutdown()
      end

      local function handle_request()
        if url == nil or method == nil then
          malformed_request("method/url not specified")
          return
        end

        --- @type Request
        local request = {
          method = method,
          url = url,
          headers = headers,
          body = body:tostring()
        }

        local response = Response:new(client)
        self.handler(request, response)
      end

      while #chunk > 0 do
        ---@diagnostic disable-next-line: redefined-local
        local err, consumed, pause_cause = parser:execute(chunk)
        local pc = http.enum.pause_cause
        if err == http.enum.errno.PAUSED then
          if pause_cause == pc.METHOD_COMPLETED then
            method = parser:get_method()
          elseif pause_cause == pc.URL_COMPLETED then
            url = parser:pull_url()
          elseif pause_cause == pc.HEADERS_COMPLETED then
            headers = parser:pull_headers()

            local length = tonumber(headers["Content-Length"])
            if length == nil or length <= 0 then
              handle_request()
              return
            end
          elseif pause_cause == pc.BODY_CHUNK_READY or pause_cause == pc.MESSAGE_COMPLETED_WITH_BODY_CHUNK then
            body:put(parser:pull_body_chunk())
          end

          if pause_cause == pc.MESSAGE_COMPLETED_WITH_BODY_CHUNK or pause_cause == pc.MESSAGE_COMPLETED then
            handle_request()
            return
          end

          parser:resume()
        elseif err ~= http.enum.errno.OK then
          malformed_request("invalid http request")
        end

        chunk = string.sub(chunk, consumed + 1, #chunk)
      end
    end)
  end)

  return setmetatable(self, HTTPServer)
end

function HTTPServer:update()
  uv.run("nowait")
end

return HTTPServer
