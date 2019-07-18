<?php
namespace exweb\source;
use exweb\source\xml_handlers\{Handlers,Utils as UT};
require_once __DIR__.'/xml_handlers/load.php';


/**
 * Обработчик для переданных по каналу exweb сообщений, 
 * запускается по событию ready (см. index.php)
 */
class Handler{

    static public function onReady($a){
        // расшифруем название xml
        UT::decrypt($a['id_rest_api']);
    }

    /** 
     * запуск цикла обработки
     */
    static public function onHandler(){
        $msg = exweb::recv();

        if ($msg===false)
            return;

        try{

            // выставим состояние в error 
            exweb::state(['id'=>$msg['id'],'state'=>'error','msg'=>'ошибка в обработчике xml','needCallHandler'=>false]);

            $xml = utils::strToXml($msg['str']);

            if ($xml===false)
                throw new \Exception('xml is not valid , id_rest_api='.$msg['id']);
            
            Handlers::run($xml);

            exweb::state(['id'=>$msg['id'],'state'=>'completed','needCallHandler'=>false]);
        }catch(\Exception $e){
            $error_msg = $e->getMessage();
            exweb::setAsError($msg['id'],$error_msg);
            error_log($error_msg);
        }finally{

            // очистка предыдущих отработанных сообщений
            exweb::clear('completed');

        }
    }

}
Events::add('onReady',__NAMESPACE__.'\Handler::onReady');
Events::add('onHandler',__NAMESPACE__.'\Handler::onHandler');
//Events::add('onCompleted',__NAMESPACE__.'\Handler::onCompleted');


?>