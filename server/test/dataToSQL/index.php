<?php

if(!isset($Application)){
    require_once '../../../../wsi/ide/ws/utils/application.php';
    
    $Application->LOG_ENABLE        = true;
    $Application->LOG_TO_ERROR_LOG  = false; 
    
    require_once UNIT('ws','ws.php');
    WS_CONF::LOAD(__DIR__,'/../../ws_conf.php');
};

require_once UNIT('plugins','base/base.php');
require_once __DIR__.'/../../source/connect.php';

function aaa(){

    $q = 'select ID_DEALER from DEALER where ID_DEALER = 21039';
    $val = base::rowsE($q,'deco',null,'aaa');
    return $val;

}

function test(){
    
    return aaa();
}

function call(){
    try{
        
        $res = test();
        var_dump($res);

    }catch(Exception $e){

        echo 'exception:'.$e->getMessage();

    }

}
echo 'begin<hr>';
call();
echo '<hr>end';

?>