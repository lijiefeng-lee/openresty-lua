<?php
/**
 * Created by PhpStorm.
 * User: 123456-Peter
 * Date: 2019/9/10
 * Time: 22:25
 */

//定时任务,监控无法容忍大量延迟场景，可以编写外部监控程序监听主从节点的复制偏移量，
//当延迟较大时触发报警或者通知客户端避免读取延迟过高的从节点(修改配置文件)

//supvisor

$redis=new Redis();
$redis->connect('47.105.193.17',6380);
$redis->auth('123456');

//安装swoole扩展
swoole_timer_tick(100,function ()use($redis){
    $serverInfo=$redis->info('replication');
    $masterOffset=$serverInfo['master_repl_offset'];
    $slaveCount=$serverInfo['connected_slaves'];
    //$slave=explode(); 数据拼接好了
    /*
     * 判断主节点的offset-从节点的offset是否大于>10
     if(){
     }
     //重新生成配置文件
     file_put_contents();
   */


});
