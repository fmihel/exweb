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
    static public function onHandler(){
        $msg = exweb::recv(true);

        if ($msg===false)
            return;

        try{
            exweb::clear('completed');

            $xml = utils::strToXml($msg['str']);
            if ($xml===false)
                throw new \Exception('xml is not valid , id_rest_api='.$msg['id']);
            
            Handlers::run($xml);

        }catch(\Exception $e){
            $error_msg = $e->getMessage();
            exweb::setAsError($msg['id'],$error_msg);
            error_log($error_msg);
        }
    }

    static public function onCompleted($a){
            UT::decrypt($a['id_rest_api']);
    }
}

Events::add('onHandler',__NAMESPACE__.'\Handler::onHandler');
Events::add('onCompleted',__NAMESPACE__.'\Handler::onCompleted');


?>