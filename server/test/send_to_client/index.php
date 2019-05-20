<?php

use exweb\source\{Utils,Result,exweb};


if(!isset($Application)){
    require_once '../../../../wsi/ide/ws/utils/application.php';
    
    $Application->LOG_ENABLE        = true;
    $Application->LOG_TO_ERROR_LOG  = false;
    
    require_once UNIT('ws','ws.php');
};

require_once UNIT('utils','framet.php');
RESOURCE('plugins','common/framet.js');
RESOURCE('plugins','splitter/splitter.js');

//RESOURCE('plugins','jconsole/jconsole.dcss');
RESOURCE('plugins','jconsole/jconsole.js');

define('SOURCE_ROOT',__DIR__.'/../../source/');
WS_CONF::LOAD(SOURCE_ROOT.'../ws_conf.php');

require SOURCE_ROOT.'utils.php';
require SOURCE_ROOT.'result.php';
require SOURCE_ROOT.'connect.php';
require SOURCE_ROOT.'stream.php';
require SOURCE_ROOT.'exweb.php';


class TWS extends WS{
    
    public function CONTENT(){
        $body = FRAME()->CSS('
            body{
                overflow-x:hidden;
                overflow-y:hidden;
                -webkit-font-smoothing:antialiased;
                -webkit-user-select: none;
                text-overflow: ellipsis;
                margin:0px;
                padding:0px;
                background:#242424;
                color:#849D9D;
                font-family: "Segoe UI", "Roboto", arial, sans-serif;
                font-size:12px;
                
            }
            .frame{
                //border:1px solid silver;
               
            }
            .textarea{
                width:300px;
                height:100px;
                font-size:12px;
            }
            .btn{
                width:120px;
                height:32px;
                font-size:12px;
                
                
            }
            .label{
                width:100px;
                height:32px;
                line-height:32px;
            }
        ');
        FRAMET('
            %size       = 48px;
            %left       = 250px;
            %right      = 250px;
            %splitter   = 10px;
            %css        = frame;
            
            <workplace {margin:0px;padding:0px} ~wp~
                <page {border:0px}              ~vert(stretch:{$bottom})~
                    <top {height:%size;text-indent:5px} "%css" ~lh~
                        |Отправка сообщений с сервера на клиент|
                    >
                    <middle ~horiz(type:left)~ {height:200px;}              
                    
                        <form {width:800px}
                            < |Cтрока| "label"> 
                            <str:textarea "textarea" |Sending string...|>

                            < "label"> 
                            <send:input [type=button] |send| "btn">
                            
                        >
                    
                    middle>
                    <bottom {height:%size} "%css"  ~vert(margin:5)~
                        <log {overflow:auto}> 
                    >
                    
                page>
            workplace>
            <modal {left:0px;top:0px;width:0px;height:0px;z-index:1000}>
        ',$body)
        ->READY('
            
            Qs.log.jconsole("log");
            
            Qs.send.on("click",()=>{
                send();
            })
            
        ')
        ->ALIGN('
            JX.tile(Qs.form.children(),{count:2,gap:5,margin:5});
            
        ')
        ->SCRIPT('
        
    function send(){


        Ws.ajax({
            id:"send",
            value:{str:Qs.str.val()},
            error(){console.error("system",arguments);},
            done(data){
                if (data.res==1){
                    Qs.log.jconsole(data,"send");
                }else
                    console.error(arguments);
            }
        });
    }
        ');
        
        
        
    }
    


    // in TWS->AJAX handler use next code:
    // if ($this->AJAX_send($response)) return true;
    public function AJAX_send(&$response){
        global $REQUEST;
        if ($REQUEST->ID=='send'){
            $str = $REQUEST->VALUE['str'];
            
            $id = exweb::send($str);
            $response = array("res"=>1,'id'=>$id);
            return true;
        }
        return false;
    }
        


    public function AJAX(&$response){
        global $REQUEST;
        
        if ($this->AJAX_send($response)) return true;
        return false;
    }




    
  
}      

if($Application->is_main(__FILE__)){
  
    $app = new TWS();
    // ----------------------------------------------------------
    //  $app->version = ''; - custom clear cache 
    //  $app->version = 'nocache'; no caching data always
    //  $app->verison = 'XXXXX'; caching data (version control)
    $app->version = ''; 
    
    // ----------------------------------------------------------
    //  $app->title - browser tab name
    $app->title = 'App';

    // ----------------------------------------------------------
    //  $app->tabColor - in mobile Chrome tab color
    $app->tabColor = '#DCDCDC';
    
    $app->RUN();

}
?>
    