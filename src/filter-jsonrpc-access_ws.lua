local cjson = require("cjson")
local set_var = ndk.set_var

local env = require("env")
local domain
local session_enable
local scheme = ngx.var.scheme
if env then
    domain = env.DOMAIN or "massbitroute.com"
    session_enable = env.SESSION_ENABLE
end

-- local domain = env.DOMAIN or "massbitroute.com"

local function empty(s)
    return s == nil or s == ""
end

if session_enable then
    if empty(ngx.var.arg_session) then
        ngx.header.location =
            "http" .. "://session.mbr." .. domain .. "/api/v1?host=" .. ngx.var.host .. "&token=" .. ngx.var.mbr_token

        return ngx.exit(308)
    else
        local _session = ngx.var.arg_session
        ngx.log(ngx.ERR, "session:" .. _session)
        local _token = set_var.set_decode_base32(_session)
        ngx.log(ngx.ERR, "token:" .. _token)
        local token = set_var.set_decrypt_session(_token)
        ngx.log(ngx.ERR, "token real:" .. token)
        ngx.log(ngx.ERR, "token arg:" .. ngx.var.mbr_token)
        if not token or token ~= ngx.var.mbr_token then
            ngx.header.location =
                "http" ..
                "://session.mbr." .. domain .. "/api/v1?host=" .. ngx.var.host .. "&token=" .. ngx.var.mbr_token
            return ngx.exit(308)
        end
    end
end

local function split(s)
    local res = {}
    local i = 1
    for v in string.gmatch(s, "([^,]+)") do
        res[i] = v
        i = i + 1
    end
    return res
end

local function contains(arr, val)
    for i, v in ipairs(arr) do
        if v == val then
            return true
        end
    end
    return false
end

-- parse conf
local blacklist, whitelist = nil
if not empty(ngx.var.jsonrpc_blacklist) then
    blacklist = split(ngx.var.jsonrpc_blacklist)
end
if not empty(ngx.var.jsonrpc_whitelist) then
    whitelist = split(ngx.var.jsonrpc_whitelist)
end

-- check conf
if blacklist ~= nil and whitelist ~= nil then
    ngx.log(ngx.ERR, "invalid conf: jsonrpc_blacklist and jsonrpc_whitelist are both set")
    --    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end

-- get request content
ngx.req.read_body()

if not ngx.var.request_body then
    ngx.log(ngx.ERR, "body empty")
    return
end

-- try to parse the body as JSON
local success, body = pcall(cjson.decode, ngx.var.request_body)
if not success then
    ngx.log(ngx.ERR, "invalid JSON request")
    --    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end

local method = body["method"]
local version = body["jsonrpc"]

-- check we have a method and a version
if empty(method) or empty(version) then
    ngx.log(ngx.ERR, "no method and/or jsonrpc attribute")
    --    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end

-- check the version is supported
if version ~= "2.0" then
    ngx.log(ngx.ERR, "jsonrpc version not supported: " .. version)
    --  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end

ngx.var["api_method"] = method

-- if whitelist is configured, check that the method is whitelisted
if whitelist ~= nil then
    if not contains(whitelist, method) then
        ngx.log(ngx.ERR, "jsonrpc method is not whitelisted: " .. method)
        --        ngx.exit(ngx.HTTP_FORBIDDEN)
        return
    end
end

-- if blacklist is configured, check that the method is not blacklisted
if blacklist ~= nil then
    if contains(blacklist, method) then
        ngx.log(ngx.ERR, "jsonrpc method is blacklisted: " .. method)
        --      ngx.exit(ngx.HTTP_FORBIDDEN)
        return
    end
end

return
