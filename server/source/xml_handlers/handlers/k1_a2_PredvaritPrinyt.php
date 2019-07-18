<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler,Utils as ut};

/**
 * предварительное принятие заказа
 */
class PredvaritPrinyt extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   1;
        $this->action   =   2; 
    }
    public function run($xml){

        $ReplyId = (int)ut::xmlAttr($xml,'ReplyId');
        switch ($ReplyId){
            case 1:{$this->prinyt($xml);break;};
            case 2:{$this->dublir($xml);break;};
            case 3:{$this->noTovars($xml);break;};
            case 4:{$this->error($xml);break;};
            case 5:{$this->chastichno($xml);break;};
        }
    }
    private function prinyt($xml){
        $OrderInfo = ut::xmlVal($xml,'OrderInfo');
        $ID_ORDER  = ut::xmlVal($OrderInfo,'LocalOrderId');
        
        $update = ut::tagToFields('OrderInfo',$OrderInfo);  

        $params = ['types'=>$update['types']];
        $params['exclude']='ID_ORDER';
        
        $update['data']['STATE'] = $update['data']['MAIN_ZAKAZ_STATE']+1;
        $q = \base::dataToSQL('update','ORDERS',$update['data'],$params)." where ID_ORDER= $ID_ORDER";
        \base::queryE($q,'deco');

        //$ID_ORDER_KIND = $base->Value("select ID_ORDER_KIND from ORDERS where ID_ORDER=$ID_ORDER");
        //TKANI order
        //if ($ID_ORDER_KIND == 2)
        //    HANDLER_PROC::_tkani_update($ORDER,$ID_ORDER);
    }
    private function dublir($xml){
        self::error($xml);
    }
    private function noTovars($xml){
        self::error($xml);
    }
    private function error($xml){
        $OrderInfo = ut::xmlVal($xml,'OrderInfo');
        $ID_ORDER  = ut::xmlVal($OrderInfo,'LocalOrderId');
        $q = "update ORDERS set STATE = ".OS_NE_PRINYT." where ID_ORDER = $ID_ORDER";
        \base::queryE($q,'deco');
    }
    private function chastichno($xml){

    }
    
}

new PredvaritPrinyt();
?>