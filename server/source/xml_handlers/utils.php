<?php
namespace exweb\source\xml_handlers;
use exweb\source\{Utils as UP};
class Utils{
    /**
     * Проверка сущесвования остака по RetsId
     */
    public static function ExistsRest($RestId,&$OutRest/*,$DsRest*/){
        
        $q = 'select count(*) cnt ,Rest from QID_REST where TOVAR_ID ='.$RestId;  
        $row = \base::row($q,'exweb');
        if (!$row)
            throw new \Exception(\base::error('exweb'));

        if ($row['cnt']>0)  
            $OutRest =$row['Rest'];
        else    
            $OutRest = -1;
          
        return ($row['cnt']>0);
    }
    private static function hpDate($mean){
        $d = explode('.',$mean);
        
        if (count($d)>2)
            return $d[2].'-'.$d[1].'-'.$d[0];
        else
            return '';
    }
    
    /** преобразует теги xml в соотвествующие теги базы
     * @return array('data'=>array(),'types'=>array())
     */
    public static function tagToFields($name,$xml){
        $result = [
            'data'=>[],
            'types'=>[],
        ];

        // соотвествие tag полям в базе
        $tags = [
            'addr_dost'=>[
                'IdKlient'      =>'ID_DEALER',
                'BossPost'      =>['BOSS_POST','string'],
                'BossName'      =>['BOSS_NAME','string'],
                'KindOplata'    =>'KIND_OPLATA',
                'EnableDiscont' =>'ENABLE_DISCONT'
            ],
            'OrderInfo'=>[
                'IdKlient'      =>'ID_DEALER',
                'LocalOrderId'  =>'ID_ORDER',
                'MainZakazId'   =>'MAIN_ZAKAZ_ID',
                'MainZakazNom'   =>'MAIN_ZAKAZ_NOM',
                "MainZakazDate" =>["MAIN_ZAKAZ_DATE",'date'],
                "MainZakazState"=>"MAIN_ZAKAZ_STATE",
                "MainZakazDDostavka"=>["MAIN_ZAKAZ_D_DOSTAVKA",'date'],
                "MainZakazDReady"=>["MAIN_ZAKAZ_D_READY",'date']
            ]
        ];

        $tag = $tags[$name];
        foreach($tag as $k=>$v){
            
            if (is_array($v)){
                $name = $v[0];
                $type = $v[1];
            }else{
                $name = $v;
                $type = 'int';
            }

            if (property_exists($xml,$k)){
                $val = $xml->{$k}->__toString();
                if ($type === 'date')
                    $val=self::hpDate($val);    
                    
                $result['data'][$name]=$val;
                $result['types'][$name]=$type;
            }
        }
        return $result;
    }



    /** 
     * получить список моделей/разделов куда входит товар
     * @return array('model'=>array(int,int,...),'chapter'=>array(int,int,...))
     */
    public static function getModelsIdByID_K_TOVAR_DETAIL($ID_K_TOVAR_DETAIL){
        $res =  array('model'=>array(),'chapter'=>array());
        $q = "  select distinct
                    ID_K_MODEL,
                    ID_K_CHAPTER 
                from
                    ".\WS_CONF::GET('K_MODEL_TOVAR_DETAIL')." mtd
                    join
                    ".\WS_CONF::GET('K_MODEL_TOVAR')." mt
                        on mtd.`ID_K_MODEL_TOVAR` = mt.`ID_K_MODEL_TOVAR`
                where
                    mtd.`ID_K_TOVAR_DETAIL` = $ID_K_TOVAR_DETAIL";

        $ds = \base::dsE($q,'deco');
        $row = array();
        while(\base::by($ds,$row)){
            if ($row['ID_K_CHAPTER']>0)
                $res['chapter'][] = $row['ID_K_CHAPTER'];
            if ($row['ID_K_MODEL']>0)
                $res['model'][] = -$row['ID_K_MODEL']; // если значение part_id>0 то оно соотвествует ID_K_CHAPTER, если part_id<0 то - ID_K_MODEL
        }

        return $res;
    }
    /**
     * очистка буффера исходя из условия
     * @param $bufferTableName 
     */
    public static function clearBufferBy($part,$array_part_id){
        
        $bufferTableName = \WS_CONF::GET('cacheTable');
        $q = "delete from `$bufferTableName` where part = '$part' and part_id in (".implode(',',$array_part_id).")";
        \base::queryE($q,'deco');
        
    }
    
    public static function xmlInfo($kind,$action){
    
        foreach(XML_INFO as $out){
            
            if ( ($out['KIND'] == $kind) && ($out['ACTION'] == $action) )
                return $out;
                
        };
        
        return false;
    }

    /**
     * расшифровка xml и обновление информации в REST_API
     * $xml - undefined | simple_xml | string
    */ 
    static public function decrypt($id_rest_api,$xml=false){

        if ($xml===false)
            $xml  = \base::valE("select STR from REST_API where ID_REST_API=$id_rest_api",'','exweb');

        if (gettype($xml)==='string'){
            $xml = \STR::to_utf($xml);
            $xml = UP::strToXml($xml);
        }    
        if (!$xml)
            throw new \Exception('decrypt: xml is null');

        $attr       = $xml->attributes();
        $action     = $attr['Action'];
        $kind       = $attr['Kind'];
        $info       = self::xmlInfo($kind,$action);
        
        //$replyId        = isset($attr['ReplyId'])?$attr['ReplyId']:false;
        //$replyIdText = ( ($info) && ($replyId) && (isset($info['REPLYID'])) )?$info['REPLYID'][$replyId]:'';

        if ($info !== false){
            
            $q = "update `REST_API` set `DECRYPT` = '".$info['NOTE']."' where `ID_REST_API` = $id_rest_api";
            \base::queryE($q,'exweb','utf8');

        }
    }
    /**
     * возвращает значение тега xml 
     * если default установлен, то при отсутствии элемента вернет default
     * если default неопределен, то сгенерируется исключение
     */
    static public function xmlVal($xml,$tag/*,$default*/){
        if (isset($xml->{$tag}))
            return $xml->{$tag};

        if (func_num_args()>2)
            return func_get_arg(2);
         
        throw new \Exception("tag [$tag] is not exists in xml ");
    }
    /**
     * возвращает значение атрибута xml
     * если default установлен, то при отсутствии элемента вернет default
     * если default неопределен, то сгенерируется исключение
     */
    static public function xmlAttr($xml,$attr){
        $attrs = $xml->attributes();
        
        if ($attrs->{$attr}!==null)
            return $attrs->{$attr};

        if (func_num_args()>2)
            return func_get_arg(2);
         
        throw new \Exception("attr [$attr] is not exists in xml ");
    }

    
    /** отправка сообщения админу*/
    public static function sendReportToAdmin($param=[]){
        try {
            $br="<br>\n";

            $p = array_merge([
                'emails'        =>\WS_CONF::GET('emails-for-system-report',[]),
                'from'          =>'info@windeco.su',
                'header'        =>'системная ошибка (только для администраторов)',
                'msg'           =>'',
                'footer'        =>'',
                'coding'        =>'UTF-8'
            ],$param);

            //---------------------------------------------------------------
            $msg =  mb_convert_encoding($p['msg'], 'UTF-8');// 'windows-1251','utf-8');
            //---------------------------------------------------------------
            if (count($p['emails']) === 0)
                error_log(str_replace(['<br>','&nbsp;'],["\n",' '],$msg));
            else
            foreach($p['emails'] as $email){
                    
                try {
                    UP::sendMail($email,$p['from'],$p['header'],$msg.$br.$p['footer'],$p['coding']);

                } catch (\Exception $e) {
                    error_log('Exception ['.__FILE__.':'.__LINE__.'] '.$e->getMessage());
                };

            };

        } catch (\Exception $e) {
            error_log('Exception ['.__FILE__.':'.__LINE__.'] '.$e->getMessage());
        };
        

    }
}
?>