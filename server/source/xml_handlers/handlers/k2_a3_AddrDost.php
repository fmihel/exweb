<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler,Utils};


class AddrDost extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   2;
        $this->action   =   3; 
    }
    public function run($xml){

        $ID_DEALER = $xml->IdKlient;

        $type = \base::valE("select count(ID_DEALER) from DOST_CLIENTS where ID_DEALER=$ID_DEALER",0,'deco') > 0?'update':'insert';
        $data = Utils::tagToFields('addr_dost',$xml);
        
        $params = ['types'=>$data['types']];
        if ($type==='update')
            $params['exclude']='ID_DEALER';

        $q = \base::dataToSQL($type,'DOST_CLIENTS',$data['data'],$params);
        if ($type==='update')
            $q.=" where ID_DEALER=$ID_DEALER";
            
        \base::queryE($q,'deco');

        $q = 'delete from DOST_CLIENTS_ADDRESS where ID_DEALER='.$ID_DEALER;
        \base::queryE($q,'deco');
        
        $list = $xml->List->children();    
        for($i=0;$i<count($list);$i++){
            $attr = $list[$i]->attributes();
            $ID   = $attr->Id;
            $ADDR = str_replace(array('"'),array("'"),$attr->Txt);
                
            if (\base::valE('select count(ID) from DOST_ADDRESS where ID='.$ID,0,'deco')>0)
                $q = 'update DOST_ADDRESS set ADDR="'.$ADDR.'" where ID='.$ID;
            else
                $q = 'insert into DOST_ADDRESS (ID,ADDR) values ('.$ID.',"'.$ADDR.'")';
                
            \base::queryE($q,'deco');
                            
            $q = 'insert into DOST_CLIENTS_ADDRESS (ID_DEALER,ID) values ('.$ID_DEALER.','.$ID.')';    
            \base::queryE($q,'deco');
                
        }
    }
}

new AddrDost();

?>