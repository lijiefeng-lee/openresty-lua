<?php
/**
 * Created by PhpStorm.
 * User: 123456-Peter
 * Date: 2019/9/21
 * Time: 22:05
 */

$sentinelConf = [
    ['ip' => '192.168.1.14 ', 'port' => '26386'],
    ['ip' => '192.168.1.15', 'port' => '26387'],
    ['ip' => '192.168.1.16', 'port' => '26387'],
];
$key='test';
$index=hash($key)%count($sentinelConf);

var_dump($index);

return;

$index = array_rand($sentinelConf);
$info = $sentinelConf[$index];

try {
    //随机取一个
    $redis = new Redis();
    $redis->connect($info['ip'], $info['port']);
    //模拟客户端发起请求
    while (true) {
        //定期的去更新配置,当程序出现连接异常,触发事件,去重新获取最新的主从节点的信息
        $slaveInfo = $redis->rawCommand("redis-sentinel", "slaves", "mymaster");
        //$masterInfo=$redis->rawCommand("redis-sentinel","get-master-addr-by-name");
        foreach ($slaveInfo as $v) {
            $slaves[] = ['ip' => $v[3], 'port' => $v[5]];
            //生成到配置文件当中
        }

        var_dump($slaves);
//        $retry = 3; //尝试三次
//        Retry:
//        try {
//            $redis = new Redis();
//            $redis->connect($slaves['ip'], $slaves['port']);
//        } catch (\Exception $e) {
//            $message = $e->getMessage();
//            var_dump($message);
//            #php_network_getaddresses: getaddrinfo failed: Name or service not known
//            while ($message == "Redis server went away"  && $retry--) {
//                echo "连接失败重试";
//                sleep(1);
//                //触发更新事件
//                goto  Retry;
//            }
//            echo "超过重试次数";
//        }
        sleep(1);
    }

} catch (\Exception $e) {
    //连接失败,重新选择一个哨兵
    //var_dump($e->getMessage());
}
