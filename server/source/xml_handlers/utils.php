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
                $result['data'][$name]=$xml->{$k}->__toString();
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

        if (gettype($xml)==='string')
            $xml = UP::strToXml($xml);

        $attr       = $xml->attributes();
        $action     = $attr['Action'];
        $kind       = $attr['Kind'];
        $info       = self::xmlInfo($kind,$action);
        
        //$replyId        = isset($attr['ReplyId'])?$attr['ReplyId']:false;
        //$replyIdText = ( ($info) && ($replyId) && (isset($info['REPLYID'])) )?$info['REPLYID'][$replyId]:'';

        if ($info !== false){
            
            $q = "update `REST_API` set `DECRYPT` = '".$info['NOTE']."' where `ID_REST_API` = $id_rest_api";
            \base::queryE($q,'exweb');

        }
    }

}
?>