<?php
/**
 * Created by PhpStorm.
 * User: Sixstar-Peter
 * Date: 2019/10/8
 * Time: 21:47
 */

//$redis=new Redis();
//$redis->connect('47.105.193.17',6390);
//$redis->auth('123456');

//$obj_cluster = new RedisCluster(NULL, Array("47.105.193.17:6390"), 1.5, 1.5, true, "123456");
//
//var_dump($obj_cluster->mget(['name1','name2']));

require  "vendor/autoload.php";

$server=[
     '47.105.193.17:6390',
     '47.105.193.17:6392',
];
$options=[
    'cluster'=>'redis',
    'parameters'=>
    [
        'password'=>'123456'
    ]
];
$client=new Predis\Client($server,$options);
var_dump($client->set('ll','peter'));

//var_dump($client->mget(['name1','name2']));
