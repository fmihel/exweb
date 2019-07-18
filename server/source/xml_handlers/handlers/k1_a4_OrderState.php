<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler,Utils as ut};

/**
 * изменение состояние заказа
 */
class OrderState extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   1;
        $this->action   =   4; 
    }
    public function run($xml){
        $OrderInfo = ut::xmlVal($xml,'OrderInfo');
        $MainZakazId = ut::xmlVal($OrderInfo,'MainZakazId');

        $update = ut::tagToFields('OrderInfo',$OrderInfo);  
        $params = ['types'=>$update['types']];
        $params['exclude']='MAIN_ZAKAZ_ID';

        $update['data']['STATE'] = $update['data']['MAIN_ZAKAZ_STATE']+1;
        $q = \base::dataToSQL('update','ORDERS',$update['data'],$params)." where MAIN_ZAKAZ_ID= $MainZakazId";
        \base::queryE($q,'deco');
    }
    
}

new OrderState();
?>