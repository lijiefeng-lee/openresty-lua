
--[[
  local template = require "resty.template"
  ngx.say(ngx.var.server_port)
  template.render("view.html", {
      title   = "Testing lua-resty-template",
      message = "Hello, World!",
      names   = { "James", "Jack", "Anne" },
     jquery  = '<script src="js/jquery.min.js"></script>'
   })

]]


--[[
    res = ngx.location.capture(
        '/index.php?'..ngx.var.request_uri,req_data
    )
    ngx.say(res.status)
     -- 判断状态码决定是否打印，如果返回不是200
    if res.status == ngx.HTTP_OK then
        ngx.say(res.body)
        return
    end
--]]




--[[ 测试获取consul当中的集群地址
--测试连接consul
local resty_consul = require('resty.consul')
local consul = resty_consul:new({
        host            = "118.24.109.254",
        port            = 8700,
        connect_timeout = (60*1000), -- 60s
        read_timeout    = (60*1000) -- 60s

})

local res, err = consul:list_keys('redis-cluster') -- Get all keys
if not res then
    ngx.log(ngx.ERR, err)
    return
end
local keys = {}
if res.status == 200 then
    keys = res.body
end

local result=''
for k,v in ipairs(keys) do
    local res, err = consul:get_key(v)
    if not res then
        ngx.log(ngx.ERR, err)
        return
    end
    -- 如果不是最后一个就都拼接一个，号
    if table.getn(keys) == k then
         result=result..res.body[1].Value
    else
         result=result..res.body[1].Value..","
    end
end
local share_data= ngx.shared.redis_cluster_addr --共享内存

share_data:set("redis_addr",result)

--]]
local share_data= ngx.shared.redis_cluster_addr --共享内存

local ngx_re_split = require("ngx.re").split
local addr = ngx_re_split(share_data:get('redis_addr'), ",")                              -- 使用 "," 切分字符串，函数需提前加载
local redis_addr={}
for k,v in pairs(addr) do
    --ngx.say(v)
    ip_addr=ngx_re_split(v,":")
    redis_addr[k]={ ip=ip_addr[1],port=ip_addr[2] }
end

local config = {
    name = "testCluster",                   --rediscluster name
     --[[
     serv_list = {                           --redis cluster node list(host and port),
       { ip = "118.24.109.254", port = 6391 },
        { ip = "118.24.109.254", port = 6392 },
        { ip = "118.24.109.254", port = 6393 },
        { ip = "118.24.109.254", port = 6394 },
        { ip = "118.24.109.254", port = 6395 },
        { ip = "118.24.109.254", port = 6396 }
      },
    ]]
    serv_list=redis_addr,
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timout = 1000,               --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection
    auth = "sixstar"
}
local redis_cluster = require "rediscluster"
local red_c = redis_cluster:new(config)
local function read_redis(key)
      local resp,err = red_c:get(key)
      if err then
          ngx.log(ngx.ERR, "err: ", err)
          return
      end
      if resp == ngx.null then
         resp=nil
      end
      return resp
end

ngx.say(read_redis('peter'))

