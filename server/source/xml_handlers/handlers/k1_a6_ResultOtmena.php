<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler,Utils as ut};

/**
 * результат отмены заказа
 */
class ResultOtmena extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   1;
        $this->action   =   6; 
    }
    public function run($xml){

        $ReplyId =  (int)ut::xmlAttr($xml,'ReplyId');
        $OrderInfo = ut::xmlVal($xml,'OrderInfo');
        //$MainZakazId  = (int)ut::xmlVal($OrderInfo,'MainZakazId');
        $LocalOrderId  = (int)ut::xmlVal($OrderInfo,'LocalOrderId');

        $update = ut::tagToFields('OrderInfo',$OrderInfo);  
        $params = ['types'=>$update['types']];
        $params['exclude']='ID_ORDER';
        

        $STATE = false;
        
        if ($ReplyId == 1)
            $STATE  = OS_OTMENEN;
        elseif ($ReplyId == 2)
            $STATE = OS_OTMENA_ZAPRESHENA;
        elseif ($ReplyId == 3)
            $STATE = OS_FORMIRUETSY;

        if ($STATE!==false){    

            $update['data']['STATE'] = $STATE;

            //$q = \base::dataToSQL('update','ORDERS',$update['data'],$params)." where MAIN_ZAKAZ_ID = $MainZakazId";
            $q = \base::dataToSQL('update','ORDERS',$update['data'],$params)." where ID_ORDER = $LocalOrderId";
            \base::queryE($q,'deco');

        }else{
            $data = str_replace(['</','>'],['[/',']'],$xml->asXML());
            $data = str_replace(['<'],['<br>['],$data);

            ut::sendReportToAdmin([
                'msg'=>'Не удалось обработать ответ на сообщение об отмене.<br>'.__FILE__.':'.__LINE__.'<br>'.$data
            ]);
        }

    }
    
}

new ResultOtmena();
?>