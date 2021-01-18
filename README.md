# docker
结合 openresty 搭建多级缓存架构
![Image](https://github.com/lijiefeng-lee/docker/blob/master/cache_project/img/%E6%9E%B6%E6%9E%84.png)


lru 缓存和 字典缓存
![Image](https://github.com/lijiefeng-lee/docker/blob/master/cache_project/img/2.jpg)

![Image](https://github.com/lijiefeng-lee/docker/blob/master/cache_project/img/3.jpg)

![Image](https://github.com/lijiefeng-lee/docker/blob/master/cache_project/img/4.jpg)

Redis集群
机器规划
容器名称	容器IP地址	映射端口号	服务运行模式
Redis-master1	172.50.0.2	"6391 -> 6397
16391 -> 16397"	Master
Redis-master2	172.50.0.3	"6392 -> 6397
16392 -> 16397"	Master
Redis-master3	172.50.0.4	"6393 -> 6397
16393 -> 16397"	Master
redis-slave1	172.30.0.2	"6394 -> 6397
16394 -> 16397"	Slave
redis-slave2	172.30.0.3	"6395 -> 6397
16395 -> 16397"	Slave
redis-slave3	172.30.0.4	"6396 -> 6397
16396 -> 16397"	Slave


容器IP地址	映射端口号	服务运行模式
172.50.0.5	8001 -> 80	Nginx分发层
172.50.0.6	8002 -> 80	Nginx应用层
172.30.0.5	8003 -> 80	Nginx应用层


nginx分发层到应用层
加载lua包，使用lua编写的分发策略，让请求转发到应用层

lua定时获取consul当中的redis地址信息
 
curl  -X  PUT  -d  '47.98.147.49:6391'  http://127.0.0.1:8501/v1/kv/redis_cluster/5

Key=》value
redis_cluster/1=>47.98.147.49:6391
