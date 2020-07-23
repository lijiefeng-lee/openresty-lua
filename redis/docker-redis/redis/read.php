<?php
/**
 * Created by PhpStorm.
 * User: lijiefeng
 * Date: 2020/7/7
 * Time: 1:59 PM
 */
require 'vendor/autoload.php';

$redis=new Predis\Client(['tcp://47.105.193.17:6380?alias=master','tcp://47.105.193.17:6381?alias=slave'],[
    'replication'=>true,
    'parameters' => [
        'password' => '123456',
    ],]);
echo $redis->set('age',100);

/*结合哨兵*/

var_dump($redis->get('name'));