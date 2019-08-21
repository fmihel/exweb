<?php

namespace exweb\source;

class Result{
    public static function ok(array $data = [])
    {
        $request = '"res":1';
        if (count($data))
            $request.=',"data":'.\ARR::to_json($data);    
        echo '{'.$request.'}';
        exit;
    }

    public static function error(string $msg='',int $res = 0,array $data = []){
        $request = '"res":'.$res;
        $request.=',"msg":"'.$msg.'"';
        if (count($data))
            $request.=',"data":'.\ARR::to_json($data);    
        echo '{'.$request.'}';
        error_log('{'.$request.'}');        
        exit;    
    }

    public static function query(string $sql,string $msgOnError=''){
        
        if (!\base::query($sql,'exweb'))
            self::error($msgOnError.'query:['.$sql.'] error:['.\base::error('exweb').']');
    }

    public static function ds(string $sql,string $msgOnError=''){
        $ds = \base::ds($sql,'exweb'); 
        if ($ds === false)
            self::error($msgOnError.'query:['.$sql.'] error:['.\base::error('exweb').']');
        return $ds;    
    }
    /**
     * если ошибка завершает скрипт
     * если данных нет то пустой массив
     * если есть данные - хеш
     */
    public static function row(string $sql,string $msgOnError=''){
        $row = \base::row($sql,'exweb');
        if  ($row === false)
            self::error($msgOnError.'query:['.$sql.'] error:['.\base::error('exweb').']');
        if ($row === null)
            return [];    
        return $row;    
    }

    public static function rows(string $sql,string $msgOnError=''){
        $ds = self::ds($sql,$msgOnError);
        return \base::rows($ds);
    }

    public static function val(string $sql,string $fieldName,string $msgOnError=''){
        $row = self::row($sql,$msgOnError);
        if  ($row === [])
            self::error($msgOnError.'query:['.$sql.'] $row = []');
        if (isset($row[$fieldName]))
            return $row[$fieldName];
        else
            self::error($msgOnError.'query:['.$sql.'] '.$fieldName.' not exists');    
    }


    public static function requestContains(/**name1,name2,... */){
        for($i=0;$i<func_num_args();$i++){
            $name = func_get_arg($i);
            if (!isset($_REQUEST[$name]))
                self::error('param "'.$name.'" is not set in url request');
        }
        return true;
        
    }
    public static function autorize(){
        
        self::requestContains('key');
        
        if ($_REQUEST['key'] !== \WS_CONF::GET('key'))
            self::error('access denied');

    }
    
}
?>