<?php

if(!isset($Application)){
    require_once '../../wsi/ide/ws/utils/application.php';
    
    $Application->LOG_ENABLE        = true;
    $Application->LOG_TO_ERROR_LOG  = false; 
    
    require_once UNIT('ws','ws.php');
};

define('SOURCE_ROOT',dirname(__FILE__).'/source/');
require SOURCE_ROOT.'utils.php';
require SOURCE_ROOT.'result.php';
require SOURCE_ROOT.'connect.php';
require SOURCE_ROOT.'stream.php';
require SOURCE_ROOT.'exweb.php';

/**
 * список состояний STATE
 * 
 * init         (event = init)
 * send_string  (event = send_string)
 * encode_string (event = encode_string)
 * open         (event = open_string)
 * ready        (event = close_string)
 * completed    (!!not from client!!)
 * error        (!!not from client!!)
 */

if (Utils::requestContains('event')){
    switch ($_REQUEST['event']){
        //----------------------------------------------------------------------------------
        // инициализация передачи
        case "init":{
            // очистка предыдущих неуспешных передач
            $q = "select * from REST_API where OWNER='client' and STATE NOT IN ('ready','error','completed')";
            $ds = Result::ds($q);

            while(base::by($ds,$row)){
                $q = "delete from REST_API_DATA where ID_REST_API = ".$row['ID_REST_API'];
                Result::query($q);
            };

            $q = "delete from REST_API where OWNER='client' and  STATE NOT IN ('ready','error','completed')";
            Result::query($q);

            // создаем строку в таблице REST_API
            $id = base::insert_uuid('REST_API','ID_REST_API','exweb');

            if ($id===false)
                Result::error('error create row in rest_api');

            $q = "update REST_API set OWNER='client', STATE='init', STR = '', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$id;
            Result::query($q);    

            Result::ok([

                'id'=>$id,
                'upload_max_filesize'=>(int)(ini_get('upload_max_filesize'))*1024*1024,
                'post_max_size'=>(int)(ini_get('post_max_size'))*1024*1024,
                'block_size'=>100*1024, // размер блоков, на которые будет разбит отправляемый клиентом бинарный пакет
                'block_len'=>1024, // размер блоков, на которые будет разбита строка, отправляемая клиентом

            ]);


            
        };break;
        //----------------------------------------------------------------------------------
        // отправка части строки
        case "send_string":{
            Result::requestContains('id','string');

            $q = "update REST_API set STR=CONCAT(STR,'".addslashes($_REQUEST['string'])."'), STATE='send_string', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$_REQUEST['id'];
            Result::query($q);

            Result::ok(); 
        };break;
        //----------------------------------------------------------------------------------
        // декодировка получеенной строки, по завершению передачи строки
        case "encode_string":{
            Result::requestContains('id');

            $q = "select STR from REST_API where ID_REST_API=".$_REQUEST['id'];    
            $str = base::val($q,'','exweb');    
            $str = Utils::rusEnCod($str);

            $q = "update REST_API set STR='".addslashes($str)."', STATE='encode_string', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$_REQUEST['id'];
            Result::query($q);    
            
            Result::ok();
        };break;
        //----------------------------------------------------------------------------------
        // инициализация передачи бинарных данных
        case "open":{
            Result::requestContains('id','size','md5');

            $q = "update REST_API set MD5='".$_REQUEST['md5']."', STATE='open', SIZE = ".$_REQUEST['size'].', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API='.$_REQUEST['id'];
            Result::query($q);    

            Result::ok();
        };break;
        //----------------------------------------------------------------------------------
        // завершениен передачи и разрешение на чтение данных
        case "close":{
            Result::requestContains('id');
            //Result::error();    
            $q = "update REST_API set STATE='ready' , LAST_UPDATE=CURRENT_TIMESTAMP where STATE<>'completed' and ID_REST_API=".$_REQUEST['id'];            
            Result::query($q);    

            Result::ok();
        };break;    
        //----------------------------------------------------------------------------------
        // передача бинарного блока данных
        case "block":{
            Result::requestContains('id','size');
            
            $id = base::insert_uuid('REST_API_DATA','ID_REST_API_DATA','exweb');
            $q = "update REST_API_DATA set BLOCK='".addslashes($stream->data)."',SIZE =".$_REQUEST['size']." , ID_REST_API = ".$_REQUEST['id']."  where ID_REST_API_DATA=".$id;            
            Result::query($q);    

            Result::ok();
        };break;
        //----------------------------------------------------------------------------------
        // сравнение исходной и сохраненной контрольной суммы
        case "hash_sum_compare":{
            Result::requestContains('id');
            // последний успешный блок
            $q = "select MD5 from REST_API where ID_REST_API = ".$_REQUEST['id'];
            $clientMD5 = strtoupper(trim(base::val($q,'','exweb')));
            $serverMD5  = strtoupper(trim(md5(exweb::getBlock($_REQUEST['id']))));
            
            Result::ok([
                'check'=>($clientMD5===$serverMD5?1:0)
            ]);
            
        };break;    
        
        //----------------------------------------------------------------------------------
        // отображение последнего пакета для отладки
        case "view_last_ready":{
            $max_upload = (int)(ini_get('upload_max_filesize'));
            $max_post = (int)(ini_get('post_max_size'));
            $memory_limit = (int)(ini_get('memory_limit'));
            
            echo 'max_upload = '.$max_upload.' Mb <br>';            
            echo 'max_post = '.$max_post.' Mb <br>';            
            echo 'memory_limit = '.$memory_limit.' Gb <br>';            
            echo '<hr>';            
            // ------------------------------------------------
            // последний успешный блок
            $q = "select * from REST_API where STATE = 'ready' and OWNER='client' order by ID_REST_API desc";
            $row = base::row($q,'exweb','utf8');

            if ($row!=[]){
                $block  = exweb::getBlock($row['ID_REST_API']);
                
                echo 'id = '.$row['ID_REST_API'].'<br>';
                echo 'orig = '.strtoupper($row['MD5']).'<br>';
                echo 'save = '.strtoupper(md5($block)).'<br>';
                echo '<xmp style="border:1px solid gray;width:99%;overflow:auto">'.$row['STR'].'</xmp>';
                echo '<xmp style="border:1px solid gray;width:99%;overflow:auto">'.$block.'</xmp>';
                
            }else{
                echo 'not ready api data';    
            }

            // ------------------------------------------------

            
        };break;    
        //----------------------------------------------------------------------------------
        case "view_as_image":{
            // последний успешный блок
            $q = "select ID_REST_API,MD5 from REST_API where STATE = 'ready' and OWNER='client' order by ID_REST_API desc";
            $row = base::row($q,'exweb');

            if ($row!=[]){
                $block  = exweb::getBlock($row['ID_REST_API']);

                $img    = imagecreatefromstring($block);

                imagepng($img);
                
            }else{
                echo 'not ready api data';    
            }

        };break;    
        //----------------------------------------------------------------------------------
        case "test":{
            $msg = exweb::recv(true);
            var_dump($msg);
        };break;
        //----------------------------------------------------------------------------------
        
        default:
            Result::error('no data');

    }

}else{

}


//if ($stream->haveIncomingData){
//    result_ok();
//}else{
//    result_error('русский');
//}



?>
