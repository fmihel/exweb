<?php
namespace exweb\source;
require_once __DIR__.'/handler_utils.php';

define('KIND_ORDER',1);
define('KIND_CLIENT',2);
define('KIND_OST',3);
define('KIND_DISCONT',5);
define('KIND_OST_TKANI',8);

define('ACT_ORDER_SEND',1);
define('ACT_ORDER_ACCEPT',2);
define('ACT_ORDER_GET_STATE',3);
define('ACT_ORDER_STATE',4);
define('ACT_ORDER_CANCEL',5);
define('ACT_ORDER_CANCEL_RESULT',6);

define('ACT_CLIENT_DATA',1);
define('ACT_CLIENT_GET_ADDR_DOST',2);
define('ACT_CLIENT_ADDR_DOST',3);


define('ACT_OST_SEND_OST',1);
define('ACT_OST_GET_OST',2);
define('ACT_OST_OST',3);

define('ACT_DISCONT_INFO_RECV',1);
define('ACT_DISCONT_INFO_SEND',2);
define('ACT_DISCONT_CHANGE',5);
define('ACT_DISCONT_REGISTERED',3);
define('ACT_DISCONT_ORDER_TO_CARD',6);


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
            
            $xml = utils::strToXml($msg['str']);
            if ($xml===false)
                throw new \Exception('xml is not valid , id_rest_api='.$msg['id']);
            
            // передача настроек удаленного доступа
            
            if ($have = self::isAction('changeClientData',$xml))     
                self::changeClientData($xml,$msg);
            else
            // адреса доставки
            if ($have = self::isAction('addrDost',$xml))     
                self::addrDost($xml,$msg);
            else
            // запрос на отправку клиенту данных авторизации в DecoR
            if ($have = self::isAction('requestAutorize',$xml))     
                self::requestAutorize($xml,$msg);
            else
            // пришли остатки по каринизам
            if ($have = self::isAction('ostatkiKarniz',$xml))     
                self::ostatkiKarniz($xml,$msg);
            else
            // пришли остатки по тканям
            if ($have = self::isAction('ostatkiTkan',$xml))     
                self::ostatkiTkan($xml,$msg);

            if (!$have)
                throw new \Exception('no handler for Kind='.$xml->attributes()->Kind.' Action='.$xml->attributes()->Action);
                
    
        }catch(\Exception $e){
            $error_msg = $e->getMessage();
            exweb::setAsError($msg['id'],$error_msg);
            error_log($error_msg);
        }
    }
    /**
     * ф-ция поевряет к какому дейсвтию относится xml запрос
     */
    static private function isAction($name,$xml){
        $types = [
            'changeClientData'=>['KIND'=>KIND_CLIENT,'ACTION'=>ACT_CLIENT_DATA],    // передача настроек удаленного доступа
            'requestAutorize'=>['KIND'=>KIND_CLIENT,'ACTION'=>4],                    // запрос на отправку клиенту данных авторизации в DecoR
            'ostatkiKarniz'=>['KIND'=>KIND_OST,'ACTION'=>ACT_OST_SEND_OST],         // пришли остатки по каринизам 
            'zaprosPoOstatkam'=>['KIND'=>KIND_OST,'ACTION'=>ACT_OST_GET_OST],       // запрос по остаткам
            'ostatkiTkan'=>['KIND'=>KIND_OST_TKANI,'ACTION'=>1],                    // пришли остатки по тканям
            'addrDost'=>['KIND'=>KIND_CLIENT,'ACTION'=>3],                          // адреса доставки

        ];
        $attr = $xml->attributes();
        $type = $types[$name];
        return ($type['KIND'] == $attr['Kind']) && ($type['ACTION'] == $attr['Action']);
    }

    /**
     * передача настроек удаленного доступа
     */
    static private function changeClientData($xml,$msg){

        $ID_DEALER  =   $xml->KlientInfo->KlientId;
        $Email      =   $xml->KlientInfo->DecoRMail;
        $Enable     =   $xml->KlientInfo->RemoteAccess;
        $Arch       =   $xml->KlientInfo->Arch;
        $Name       =   $xml->KlientInfo->KlientName;

        handler_utils::UpdateDealer($ID_DEALER,$Email,$Enable,$Arch,$Name);

    }
    /** изменение/создание адреса доставки (c BOSS_POST) */
    static private function addrDost($xml,$msg){
        handler_utils::addr_dost_update($xml);        
    }
    /**
     * запрос на отправку клиенту данных авторизации в DecoR
     */
    static private function requestAutorize($xml,$msg){

    }

    /**
     * пришли остатки по каринизам 
     */
    static private function ostatkiKarniz($xml,$msg){
        
        $list = $xml->List->children();//tag = LIST  
        
        for($i = 0;$i<count($list);$i++){  
            
            $Rest = $list[$i]->attributes();
            
            $OldRest = -1;
            if (handler_utils::ExistsRest($Rest->Id,$OldRest/*,$DsRest*/))        
            {        
                        
                if ((($Rest->Ost>0) && ($OldRest<=0)) || (($Rest->Ost<=0) && ($OldRest>0))){
                                            
                    if ($Rest->Ost>0){
                        $LAST_FIELD = 'LAST_DELIVERY_DATE';                        
                        $LAST_MEAN = 'CURRENT_DATE';
                    }else{                    
                        $LAST_FIELD = 'LAST_RESET_DATE';                        
                        $LAST_MEAN = 'CURRENT_DATE';
                    };
                    $q = "update QID_REST set REST = $Rest->Ost,LAST_UPDATE=CURRENT_TIMESTAMP,KIND=$Rest->Kind,DELIV='$Rest->Deliv', $LAST_FIELD=$LAST_MEAN,ARCH=0 where TOVAR_ID=$Rest->Id";                                
                }else{
                    $q = "update QID_REST set REST = $Rest->Ost,LAST_UPDATE=CURRENT_TIMESTAMP,KIND=$Rest->Kind,DELIV='$Rest->Deliv', ARCH=0 where TOVAR_ID=$Rest->Id";                                            
                };                                                
            }else{
                
                if ($Rest->Ost<=0){
                    $LAST_RESET = 'CURRENT_DATE';                    
                    $LAST_DELIVERY = "DATE_FORMAT('".DELIVERY_NULL_DATE_TO_UPDATE."','%Y-%m-%d')";
                }else{
                    $LAST_RESET ="DATE_FORMAT('".DELIVERY_NULL_DATE_TO_UPDATE."','%Y-%m-%d')";                    
                    $LAST_DELIVERY = 'CURRENT_DATE';
                };                
                
                $q = "insert into QID_REST (TOVAR_ID,REST,LAST_UPDATE,KIND,DELIV,LAST_RESET_DATE,LAST_DELIVERY_DATE,ARCH) values 
                        ($Rest->Id,$Rest->Ost,CURRENT_TIMESTAMP,$Rest->Kind,'$Rest->Deliv',$LAST_RESET,$LAST_DELIVERY,0)";
            };
        
            if (!\base::query($q,'exweb'))
                throw new \Exception(\base::error('exweb'));
          };
        
    }

    /**
     * пришли остатки по тканям
     */
    static private function ostatkiTkan($xml,$msg){
        $List = $xml->TxProductsList->children();
        
        $cnt = count($List);

        for($i=0;$i<$cnt;$i++){

            $Textile = $List[$i];
            $attr = $Textile->attributes();
            $ID_TEXTILE = $attr->IdTextile;
            $ID_TX_COLOR = $attr->IdTxColor;
            $COLOR_OSTATOK = utils::strToFloat($attr->Ostatok,'asFloat');
            
            
            if (\base::val("select count(ID_TX_COLOR) from TX_COLOR where ID_TX_COLOR = $ID_TX_COLOR and ID_TEXTILE = $ID_TEXTILE",0,'deco')>0){
                
                $q = "update TX_COLOR set OSTATOK = $COLOR_OSTATOK where ID_TX_COLOR = $ID_TX_COLOR and ID_TEXTILE = $ID_TEXTILE";
                if (!\base::query($q,'deco'))
                    throw new \Exception(\base::error('deco'));
                
                $TxPiece =  $Textile->children();   
                for($j=0;$j<count($TxPiece);$j++)
                {
                    $piece          = $TxPiece[$j]->attributes();
                    $ID_TX_PIECE    = $piece->IdTxPiece;
                    $NOM            = $piece->Nom;
                    $OSTATOK        = utils::strToFloat($piece->Ostatok,'asFloat');
                    $BRONIR         = utils::strToFloat($piece->Bronir,'asFloat');
                    
                    if ($OSTATOK !== 0){
                        $q = "insert into TX_PIECE (ID_TX_COLOR,ID_TX_PIECE,NOM,OSTATOK,BRONIR,NOTE,D_LAST_CHANGE) values ($ID_TX_COLOR,$ID_TX_PIECE,$NOM,$OSTATOK,$BRONIR,'',CURRENT_TIMESTAMP) 
                            on duplicate key update ID_TX_COLOR = $ID_TX_COLOR,NOM=$NOM,OSTATOK =$OSTATOK,BRONIR=$BRONIR" ;
                        if (!\base::query($q,'deco'))
                            throw new \Exception(\base::error('deco'));
                    }else{
                        $q = "delete from TX_PIECE where ID_TX_PIECE = $ID_TX_PIECE";
                        if (!\base::query($q,'deco'))
                            throw new \Exception(\base::error('deco'));
                    }    
                }//for($j=0;$j<$Textile->Count();$j++)
            };//Count >0
        }//for($i=0;$i<$List->Count();$i++)

    }

}

?>