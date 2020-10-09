local ngx_re_split=require("ngx.re").split

local ip_addr=ngx.shared.redis_cluster_addr:get('redis-addr')
local ip_addr_table=ngx_re_split(ip_addr,",")

local redis_addr={}
for key, value in ipairs(ip_addr_table) do
    local ip_addr=ngx_re_split(value,":")
    redis_addr[key]={ip=ip_addr[1],port=ip_addr[2]}
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

--redis当中嵌入lua 脚本 交给redis整体来执行

 local ok,err=red_c:eval([[
                local key=KEYS[1]
                local val=ARGV[1]
                -- local res,err=redis.call("bf.add",key,"users")

                local res,err=redis.call("bf.exists",key,"users")

                return  val

  ]],1,'{bf_1}','test')  --{} 集群key是整体存到同一个槽里面  这样保证存储的节相同

 -- 布隆过滤器过滤
  ngx.say(ok)

