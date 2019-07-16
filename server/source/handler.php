<?php
namespace exweb\source;
use exweb\source\xml_handlers\{Handlers,Utils as UT};
require_once __DIR__.'/xml_handlers/load.php';


/**
 * Обработчик для переданных по каналу exweb сообщений, 
 * запускается по событию ready (см. index.php)
 */
class Handler{
    
    /** 
     * запуск цикла обработки
     */
    static public function run(){
        $msg = exweb::recv(true);

        if ($msg===false)
            return;

        try{
            exweb::clear('completed');

            $xml = utils::strToXml($msg['str']);
            if ($xml===false)
                throw new \Exception('xml is not valid , id_rest_api='.$msg['id']);
            
            self::decrypt($xml,$msg['id']);
            
            Handlers::run($xml);

    
        }catch(\Exception $e){
            $error_msg = $e->getMessage();
            exweb::setAsError($msg['id'],$error_msg);
            error_log($error_msg);
        }
    }

    /**
     * расшифровка xml и обновление информации в REST_API
    */ 
    static private function decrypt($xml,$id_rest_api){
        $attr = $xml->attributes();
        $action  = $attr['Action'];
        $kind  = $attr['Kind'];
        $info = UT::xmlInfo($kind,$action);
        
        $replyId        = isset($attr['ReplyId'])?$attr['ReplyId']:false;
        $replyIdText = ( ($info) && ($replyId) && (isset($info['REPLYID'])) )?$info['REPLYID'][$replyId]:'';
        
        

        if ($info !== false){
            
            $q = "update `REST_API` set `DECRYPT` = '".$info['NOTE']."' where `ID_REST_API` = $id_rest_api";
            \base::queryE($q,'exweb');
        }
    }

}

?>