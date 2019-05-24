<?php

namespace exweb;
use exweb\source\{Utils,Result,exweb};
//use Complex\Exception;

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



//------------------------------------------------------------------------------------------
// проверка наличия ключа авторизации
// Result::autorize();
//------------------------------------------------------------------------------------------

if (Utils::requestContains('event')){
    switch ($_REQUEST['event']){
        //----------------------------------------------------------------------------------
        // инициализация передачи
        case "init_send":{
            // очистка предыдущих неуспешных передач
            $q = "select * from REST_API where OWNER='client' and STATE NOT IN ('ready','error','completed')";
            $ds = Result::ds($q);

            while(\base::by($ds,$row)){
                $q = "delete from REST_API_DATA where ID_REST_API = ".$row['ID_REST_API'];
                Result::query($q);
            };

            $q = "delete from REST_API where OWNER='client' and  STATE NOT IN ('ready','error','completed')";
            Result::query($q);

            // создаем строку в таблице REST_API
            $id = \base::insert_uuid('REST_API','ID_REST_API','exweb');

            if ($id===false)
                Result::error('error create row in rest_api');

            $q = "update REST_API set OWNER='client', STATE='init_send', STR = '', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$id;
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
        case "string_encode":{
            Result::requestContains('id');

            $q = "select STR from REST_API where ID_REST_API=".$_REQUEST['id'];    
            $str = \base::val($q,'','exweb');
            $str = Utils::rusEnCod($str);

            $q = "update REST_API set STR='".addslashes($str)."', STATE='string_encode', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$_REQUEST['id'];
            Result::query($q);    
            
            Result::ok();
        };break;
        //----------------------------------------------------------------------------------
        // инициализация передачи бинарных данных
        case "init_send_block":{
            Result::requestContains('id','size','md5','count');

            $q = "update REST_API set MD5='".$_REQUEST['md5']."', STATE='init_send_block', SIZE = ".$_REQUEST['size'].',BLOCK_COUNT='.$_REQUEST['count'].',BLOCK_NUM=-1, LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API='.$_REQUEST['id'];
            Result::query($q);    

            Result::ok();
        };break;
        //----------------------------------------------------------------------------------
        // передача бинарного блока данных
        case "send_block":{
            Result::requestContains('id','size');
            
            $id = \base::insert_uuid('REST_API_DATA','ID_REST_API_DATA','exweb');
            $q = "update REST_API_DATA set BLOCK='".addslashes($stream->data)."',SIZE =".$_REQUEST['size']." , ID_REST_API = ".$_REQUEST['id']."  where ID_REST_API_DATA=".$id;            
            Result::query($q);    

            $q = "update REST_API set STATE='send_block', BLOCK_NUM=".$_REQUEST['i'].", LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$_REQUEST['id'];
            Result::query($q);    

            Result::ok();
        };break;
        //----------------------------------------------------------------------------------
        // сравнение исходной и сохраненной контрольной суммы
        case "hash_sum_compare":{
            Result::requestContains('id');
            // последний успешный блок
            $q = "select MD5 from REST_API where ID_REST_API = ".$_REQUEST['id'];
            $clientMD5 = strtoupper(trim(\base::val($q,'','exweb')));
            $serverMD5  = strtoupper(trim(md5(exweb::getBlock($_REQUEST['id']))));
            
            Result::ok([
                'check'=>($clientMD5===$serverMD5?1:0)
            ]);
            
        };break;    
        //----------------------------------------------------------------------------------
        // завершениен передачи и разрешение на чтение данных
        case "ready":{
            Result::requestContains('id');
            //Result::error();    
            $q = "update REST_API set STATE='ready' , LAST_UPDATE=CURRENT_TIMESTAMP where STATE<>'completed' and ID_REST_API=".$_REQUEST['id'];            
            Result::query($q);    

            Result::ok();
        };break;    
        //----------------------------------------------------------------------------------
        // получить id сообщения (если есть)
        // еcли запись есть, то возвращает id и доп информацию
        // если не существует то возвращает  id = -1
        case "recv_get_id":{
            
            $q = "select * from REST_API where STATE='ready' and OWNER='server' order by ID_REST_API";
            $row = Result::row($q);
            
            if ($row===[])
                Result::ok(['id'=>-1]);
            else
                $q = 'select count(*) count from REST_API_DATA where ID_REST_API = '.$row['ID_REST_API']; 
                $count_blocks = Result::val($q,'count');

                Result::ok([
                    'id'=>$row['ID_REST_API'],
                    'str_len'=>mb_strlen($row['STR']),
                    'size'=>$row['SIZE'],
                    'md5'=>$row['MD5'],
                    "count_blocks"=>$count_blocks
                    
                ]);
            
        };break;    
        // чтение строки исходящего сообщения
        case "recv_string":{
            Result::requestContains('id');
            
            $q = "select STR from REST_API where ID_REST_API=".$_REQUEST['id'];
            $row = Result::row($q);
            
            if ($row===[])
                Result::error('can`t read row where ID_REST_API='.$_REQUEST['id']);
            else    
                Result::ok([
                    'id'=>$_REQUEST['id'],
                    'string'=>Utils::rusCod($row['STR']),
                ]);
            
        };break;    
        // получение информации по блоку ( вообще можно и без нее)
        case "recv_block_info":{
            Result::requestContains('id','i');
            // получаем id блока по порялковому номеру 
            $q = "select ID_REST_API_DATA from REST_API_DATA where ID_REST_API=".$_REQUEST['id'].' order by ID_REST_API_DATA';
            $rows = Result::rows($q);
            $id = $rows[intval($_REQUEST['i'])]['ID_REST_API_DATA'];
            

            $q = "select SIZE from REST_API_DATA where ID_REST_API_DATA=".$id;
            $row = Result::row($q);
            
            if ($row===[])
                Result::error('can`t read row where ID_REST_API_DATA='.$id);
            else    
                Result::ok([
                    'size'=>$row['SIZE'],
                    'id'=>$id
                ]);
        };break; 
       
        // считывание i го блока   
        case "recv_block":{
            Result::requestContains('id','i');
            // получаем id блока по порядковому номеру 
            $q = "select ID_REST_API_DATA from REST_API_DATA where ID_REST_API=".$_REQUEST['id'].' order by ID_REST_API_DATA';
            $rows = Result::rows($q);
            try{

                if(!isset($rows[intval($_REQUEST['i'])]))
                    throw new \Exception('offset error');

                $id = $rows[intval($_REQUEST['i'])]['ID_REST_API_DATA'];

                $q = "select BLOCK,SIZE from REST_API_DATA where ID_REST_API_DATA=".$id;
                $row = Result::row($q);
            
                if ($row===[])
                    Result::error('can`t read row where ID_REST_API_DATA='.$id);
                else{
                    echo $row['BLOCK'];
                    exit;    
                };    
            }catch (\Exception $e){
                echo '';
                exit;
            }
            
        };break;    
        
        //----------------------------------------------------------------------------------
        // указывает, что сообщение обработано, и его можно удалить
        case "completed":{
            Result::requestContains('id');
            
            if (!exweb::completed($_REQUEST['id']))
                Result::error('set completed for id='.$_REQUEST['id'] );
            Result::ok();
        };break;    
        //----------------------------------------------------------------------------------
        // работа с таблицами
        case "query":{
                Result::requestContains('sql','return','base');

                $q = $_REQUEST['sql'];
                $base = $_REQUEST['base'];
                $coding = ((!isset($_REQUEST['coding'])||$_REQUEST['coding']==='')?null:$_REQUEST['coding']);
                
                if ($_REQUEST['return'] === 'table'){
                    
                    $ds = \base::ds($q,$base,$coding);
                    if ($ds){
                        $info = \base::fields($ds,false);
                        
                        
                        $fields=[];
                        foreach($info as $v){
                            $fields[] =['name'=>$v->name,'type'=>$v->stype,'length'=>$v->max_length];
                        }
                        $rows = \base::rows($ds);
                        Result::ok(['fields'=>$fields,'rows'=>$rows]);
                    }else
                        Result::error(\base::error($base));
                        
                }else{
                    if (\base::query($q,$base,$coding))
                        Result::ok();
                    else    
                        Result::error(\base::error($base));
                }
                Result::ok();

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
            $row = \base::row($q,'exweb','utf8');

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
            $row = \base::row($q,'exweb');

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
            
            // получаем id блока по порядковому номеру 
            $q = "select ID_REST_API_DATA from REST_API_DATA where ID_REST_API=340 order by ID_REST_API_DATA";
            $rows = Result::rows($q);
            try{

                $id = $rows[0]['ID_REST_API_DATA'];

                $q = "select BLOCK,SIZE from REST_API_DATA where ID_REST_API_DATA=".$id;
                $row = Result::row($q);
            
                //if ($row===[])
                //    Result::error('can`t read row where ID_REST_API_DATA='.$id);
                //else{
                /*
                    $n = 0;
                $block = $row['BLOCK'];
                for($i = 0;$i<10;$i++){    
                    for($j=0;$j<16;$j++){
                        $c =  $block[$n];
                        $code = ord($c);
                        echo ''.$n.':'.$c.'('.$code.') ';
                        $n++;
                    }
                    echo '<br>';
                }
                */    
                $block = $row['BLOCK'];
                for($i=0;$i<strlen($block);$i++){
                    echo ord($block[$i]).'f';
                }
                exit;
            }catch (\Exception $e){
                echo 'ERROR!!!';
                exit;
            }

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
