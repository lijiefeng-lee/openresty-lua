--分隔函数

local ngx_re_split=require("ngx.re").split
--存放redis集群地址的
local ip_addr=ngx.shared.redis_cluster_addr:get('redis_addr')
--ngx.say(ip_addr)

local ip_addr_table=ngx_re_split(ip_addr,",")

local resty_consul = require('resty.consul')
local consul = resty_consul:new({
            host            = "47.105.193.17",
            port            = 8700,
            connect_timeout = (60*1000), -- 60s
            read_timeout    = (60*1000), -- 60s
        })
local res, err = consul:list_keys("redis-cluster") -- Get all keys


if not res then
    ngx.log(ngx.ERR, err)
    return
end

local keys = {}
if res.status == 200 then
     keys = res.body
end


local redis_addr={}

for key, value in ipairs(ip_addr_table) do
    local ip_addr=ngx_re_split(value,":")
    redis_addr[key]={ip=ip_addr[1],port=ip_addr[2]}
    --ngx.print(value) -- Key value after base64 decoding
end

local config = {
    name = "testCluster",                   --rediscluster name
    --[[serv_list = {                           --redis cluster node list(host and port),
        { ip = "47.105.193.17", port = 6391 },
        { ip = "47.105.193.17", port = 6392},
        { ip = "47.105.193.17", port = 6393 },
        { ip = "47.105.193.17", port = 6394 },
        { ip = "47.105.193.17", port = 6395 },
        { ip = "47.105.193.17", port = 6396 }
    },
    ]]
    serv_list=redis_addr,
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timout = 1000,               --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection
    auth="123456"
    }

local redis_cluster = require "rediscluster"
local red_c = redis_cluster:new(config)

local v, err = red_c:get("peter")
if err then
    ngx.log(ngx.ERR, "err: ", err)
else
    ngx.say(v)
end




