<?php
/**
 * Created by PhpStorm.
 * User: Sixstar-Peter
 * Date: 2019/11/29
 * Time: 21:32
 */

class  Unique{
    const  PUSH='
          local setName=KEYS[1]
          local jobName=ARGV[1]
          local res=redis.call("SADD",setName,jobName)
          if res == 1 then 
             return redis.call("LPUSH",jobName,ARGV[2])
          end
          return 0
    ';
    const  POP='
          local setName=KEYS[1]
          local jobName=ARGV[1]
          local res=redis.call("RPOP",jobName)
          if type(res) == "boolean" then 
             return 0
          end
          redis.call("SREM",setName,jobName)
          return res
    ';
    public  function  __construct($redis)
    {
        $this->redis=$redis;
    }


    public  function  push($setName,$queueName,$jobData){

        return $this->redis->eval(self::PUSH,[$setName,$queueName,$jobData],1);
//        if($this->redis->sAdd($setName,$queueName)){
//            return $this->redis->lpush($queueName,$job);
//        }
//        return false;
    }
    public  function  pop($setName,$jobName){
        return $this->redis->eval(self::POP,[$setName,$jobName],1);
    }


}