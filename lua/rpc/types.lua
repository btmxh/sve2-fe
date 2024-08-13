local llh = require("llhttp")
local buf = require("string.buffer")

--- @enum HTTPResponseCode
local HTTPResponseCode = {
  OK = { 200, "OK" },
  BAD_REQUEST = { 400, "Bad Request" },
  NOT_FOUND = { 404, "Not Found" },
  INTERNAL_SERVER_ERROR = { 500, "Internal Server Error" },
}

--- @enum HTTPMethod
local HTTPMethod = llh.enum.method

--- @class Request
--- @field method HTTPMethod
--- @field url string
--- @field headers table<string, string>
--- @field body string

--- @class Response
--- @field client unknown
--- @field status_code integer
--- @field headers table<string, string>
--- @field body string.buffer
local Response = {}
Response.__index = Response

--- @param client unknown
--- @return Response
function Response:new(client)
  self.client = client
  self.body = buf.new()
  self.headers = {}
  return setmetatable(self, Response)
end

--- @param key string
--- @param value string
--- @return Response
function Response:addHeader(key, value)
  self.headers[key] = value
  return self
end

--- @param msg string
--- @return Response
function Response:write(msg)
  self.body:put(msg)
  return self
end

--- @param code HTTPResponseCode
function Response:finish(code)
  if self.headers["Content-Length"] == nil then
    self.headers["Content-Length"] = tostring(#self.body)
  end

  self.client:write("HTTP/1.1 " .. code[1] .. " " .. code[2] .. "\r\n")
  for key, value in pairs(self.headers) do
    self.client:write(key .. ": " .. value .. "\r\n")
  end

  self.client:write("\r\n")
  if #self.body > 0 then
    self.client:write(self.body:tostring())
  end

  self.client:close()
  self.client:shutdown()
end

return {
  Response = Response,
  HTTPResponseCode = HTTPResponseCode,
  HTTPMethod = HTTPMethod,
}
