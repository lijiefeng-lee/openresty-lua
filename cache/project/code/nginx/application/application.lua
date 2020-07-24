local config = {
    name = "testCluster",                   --rediscluster name
    serv_list = {                           --redis cluster node list(host and port),
        { ip = "47.105.193.17", port = 6391 },
        { ip = "47.105.193.17", port = 6392 },
        { ip = "47.105.193.17", port = 6393 },
        { ip = "47.105.193.17", port = 6394 },
        { ip = "47.105.193.17", port = 6395 },

    },
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timeout = 1000,              --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection,
    max_connection_attempts = 1,            --maximum retry attempts for connection
    auth = "123456"                         --set password while setting auth
}

local redis_cluster = require "rediscluster"
local red_c = redis_cluster:new(config)

local v, err = red_c:get("name")
if err then
    ngx.log(ngx.ERR, "err: ", err)
else
    ngx.say(v)
end