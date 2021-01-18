<?php
/**
 * Created by PhpStorm.
 * User: Sixstar-Peter
 * Date: 2019/11/29
 * Time: 21:41
 */
require  'unique.php';

$redis=new \RedisCluster(
    null,
    ["47.105.193.17:6390","47.105.193.17:6391","47.105.193.17:6392","47.105.193.17:6393"],
    $timeout = null,
    $readTimeout = null, $persistent = false,"123456"
);
$config=[
    '1_20000'=>'{queue_1_20000}',
    '200000_40000'=>'{queue_20000_40000}'
];
//一次性做两个操作,要么都成功,要么都不要成功,用lua脚本 (redis集群环境)
$setName="{queue_1_20000}:update_queue";  //集合key
$queueName="{queue_1_20000}:product_image_1";  //

try{
    //先判断当前的id是否有更新任务，没有再添加，如果有更新任务了，等待获取
    $unique=new Unique($redis);
    $res=$unique->redis->sIsMember($setName,$queueName);
    $retry=3;
    $sleep=1;
    if($res){
        //等待任务完成返回结果，查询是否有数据
        while ( $retry-- ){
            $ok=$unique->redis->get("product_image_1");
            if($ok){
                echo $ok.PHP_EOL;
                break;
            }
            sleep($sleep); //不希望阻塞进程的（协程）
            var_dump("等待获取数据");
        }
    }else{
        $job=json_encode(["method"=>"updateImage","data"=>["id"=>1]]);
        var_dump($unique->push($setName,$queueName,$job));
        //第一次任务放入到队列当中，并没有获取结果
    }

}catch (Exception $e){

}


//弹出任务
//var_dump($unique->pop($setName,$queueName));