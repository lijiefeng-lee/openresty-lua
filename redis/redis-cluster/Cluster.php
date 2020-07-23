<?php
/**
 * Created by PhpStorm.
 * User: Sixstar-Peter
 * Date: 2019/10/8
 * Time: 22:19
 */
require  "vendor/autoload.php";
//1.将数据槽跟节点的关系映射 （为了能够知道某个key，对应的节点）
try{
    $server=[
        '47.105.193.17:6398',
        '47.105.193.17:6392',
        '47.105.193.17:6390',
        '47.105.193.17:6391'
    ];
    $options=[
        'cluster'=>'redis',
        'parameters'=>
            [
                'password'=>'123456'
            ]
    ];

    $client=new Predis\Client($server,$options);
    $connectionId=$server[array_rand($server)];
    //得到槽节点信息,保存在某个缓存文件当中
    $slotInfo=$client->getClientFor($connectionId)->executeRaw(['cluster','slots']);
    /*  槽范围    节点ip
     * [1,1000]=>47.105.193.17:6380
     *
     * */
    $slotNodes=[]; //数据槽跟节点的映射关系
    foreach ($slotInfo as $slots=>$nodes){
        $slotNodes[$nodes[0].','.$nodes[1]]=$nodes[2][0].':'.$nodes[2][1];
    }
     //执行批量删除操作
    $delKeys=['name1','name2','name3','name4','name5','name6'];
    //2.得到key跟节点的对应关系
    $crc=new \Predis\Cluster\Hash\CRC16();
    /*
     * 使用管道发送命令,可以节约一点网络资源
     * ['47.105.193.17:6390']=>'name1,name2'
     * ['47.105.193.17:6391']=>'name4,name5'
     * ['47.105.193.17:6393']=>'name3'
     *
     * */

    //作业封装mget函数,用来批量操作

    $slotKeys=[];
    foreach ($delKeys as $keyName){
        $code=$crc->hash($keyName) % 16384; //计算出某个key对应的槽节点
        //循环匹配,如果key在某个节点的范围之内就拼接数据(有可能多个key在同一节点)
         array_walk($slotNodes,function($node,$slotRange)use($code,&$slotKeys,$keyName){
             $range=explode(",",$slotRange);
            //判断某个key计算出来的槽,是否在这个范围之内,如果是就添加
             if($code>=$range[0] && $code<=$range[1] ){
                 $slotKeys[$node][]=$keyName;
             }
         });
    }
    //执行命令并且返回结果
    foreach ($slotKeys  as $node=>$keys){
            $res=$client->getClientFor($node)->pipeline(function ($pipe)use($keys){
                foreach ($keys as $v) {
                    $pipe->del($v);
                }
            });
            //对应下key跟结果
            var_dump($res);
    }
}catch (\Exception $e){
    var_dump($e->getMessage());
    //更新缓存信息因为槽跟节点的对应关系已经发生改变了,并且发送命令到正确的节点上
    if(strpos($e->getMessage(),"moved") !==false){

    }

}




