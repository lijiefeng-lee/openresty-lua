local rety_lock = require "resty.lock"
local cache=ngx.shared.my_cache
local key=ngx.re.match(ngx.var.request_uri,"/([0-9]+).html")
if type(key) == "table" then
   --1.先从本地内存获取
   local res,err=cache:get(key[1])
   if  res then
     ngx.say('val',res)
     return
   end
   --2.去后端源服务器获取，只允许一个请求到后端获取，并且更新缓存，加锁 是非阻塞其他key当某个key（请求）
       --获取到该锁后，后续试图对该key再一次获取锁时都会『阻塞』在这里，但不会阻塞其它的key。
       --当第一个获取锁的key将获取到的数据更新到缓存后，后续的key就不会再回源后端应用了，从而可以起到保护后端应用的作用

   --创建锁   exptime 过期时间  timeout 多少时间加好锁
   local lock,err=rety_lock:new("my_locks",{exptime=10,timeout=1})

   if not lock then
         ngx.log(ngx.ERR,"创建锁失败")
         return
   end
   local flag_lock,err =  lock:lock(key[1])--给key加锁
   if err then
        ngx.log(ngx.ERR,"加锁失败:",err)
   end

   if not flag_lock then
      ngx.log(ngx.ERR,"获取锁失败:占用")
      local res=cache:get_stale(key[1])
      return res
   end

   --锁成功获取，可能已经有人将值放入到缓存当中了，再检查下
    local res,err=cache:get(key[1])
      if  res then
        lock:unlock()
        return res
      end
    --再去请求源服务器
    local req_data
    local method = ngx.var.request.method

    if method == "POST" then
        req_data={method = ngx.HTTP_POST, body = ngx.req.read_body() }
    elseif method == "PUT" then
        req_data={method = ngx.HTTP_PUT, body = ngx.req.read_body() }
    else
        req_data={method = ngx.HTTP_GET}
    end
  --[[
    local uri
    if not ngx.var.request.uri then
            uri=''
    end
    ]]
    -- ngx.say(ngx.var.request.uri)
    local res,err=ngx.location.capture(
        '/index.php',
        req_data
    )
    if res.status == 200 then
        ngx.say(res.body)
    end
    lock:unlock()

end





