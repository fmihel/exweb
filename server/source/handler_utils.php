<?php
namespace exweb\source;
/**
 * вспомогательные ф-ции для handler
 */
class handler_utils{


    public static function UpdateDealer($id,$email,$enable,$arch,$klientname){

        $ID_RIGHT  = 0;
        $PASS_DEFAULT = Utils::random_str(5);

        if ($enable ==='') 
            $enable = 0;
        
        $count = \base::valE('select count(ID_DEALER) from DEALER where ID_DEALER='.$id,0,'deco');

        if ($count == 0){ // дилер отсутствует

            // создание дилера    
            $q = "insert into DEALER (ID_DEALER,NAME,DATE_CREATE,ENABLE,LAST_MODIFY,ARCH,EMAIL,ID_USER_MAIN) value ($id,'$klientname',CURRENT_TIMESTAMP,$enable,CURRENT_TIMESTAMP,$arch,'$email',0)";
            \base::queryE($q,'deco');

            // создание торговой точки    
            $id_place = \base::insert_uuidE('PLACE','ID_PLACE','deco');
            $q = "update PLACE set CAPTION='no name', ID_DEALER=$id where ID_PLACE=$id_place";
            //$q = 'insert into PLACE (ID_DEALER,UUID,CAPTION,DATE_CREATE,LAST_MODIFY) value (:ID_DEALER,:UUID,:CAPTION,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)';
            \base::queryE($q,'deco');

            // установка торговой точки поумолчанию
            $q = "update DEALER set ID_PLACE=$id_place where ID_DEALER=$id";
            \base::queryE($q,'deco');

            // создаем пользователя
            $id_user = \base::insert_uuidE('USER','ID_USER','deco');
            $q = "update USER set ID_DEALER=$id, NAME='$email',PASS='$PASS_DEFAULT',ENABLE=1,REL_EMAIL='$email',IS_MAIN=1 where ID_USER=$id_user";
            //$q = 'insert into USER (ID_DEALER,UUID,NAME,DATE_CREATE,LAST_MODIFY,PASS,ENABLE,REL_EMAIL,IS_MAIN) value 
            //                      (:ID_DEALER,:UUID,:NAME,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,:PASS,:ENABLE,:REL_EMAIL,1)';
            \base::queryE($q,'deco');

            // устанавливаем права пользователя      
            $q = "insert into USER_RIGHT_PLACE (ID_USER,ID_RIGHT,ID_PLACE) value ($id_user,$ID_RIGHT,$id_place)";
            \base::queryE($q,'deco');
                

            // указываем созданного пользователя как главного
            $q = 'update DEALER set ID_USER_MAIN ='.$id_user.' where ID_DEALER='.$id;
            \base::queryE($q,'deco');

            
        };//count = 0;

        $q = "update DEALER set NAME='$klientname',EMAIL='$email',ENABLE=$enable,ARCH=$arch where ID_DEALER = $id";
        \base::queryE($q,'deco');

        // изменяем главного клиента если он есть
        $id_user = \base::val('select ID_USER_MAIN from DEALER where ID_DEALER = '.$id,0,'deco');
        if ($id_user!=0){
            if(\base::val('select BY_USER_MODIFY from USER where ID_USER = '.$id_user,0,'deco') != 1){
                $q = "update USER set REL_EMAIL = '$email' where ID_USER=$id_user";
                \base::queryE($q,'deco');
                    
            };

            if (\base::val('select EMAIL_LOGIN from USER where ID_USER = '.$id_user,0,'deco') == ''){
                    // проверка на существование такого login
                    $email_login = $email;
                    if (\base::val("select count(ID_USER) from USER where EMAIL_LOGIN='$email'",0,'deco')>0)
                        $email_login = $email.''.$id;

                    $q = "update USER set EMAIL_LOGIN='$email_login' where ID_USER=$id_user";
                    \base::queryE($q,'deco');
            };
        };
    }
    
    public static function addr_dost_update($xml){
        

        $ID_DEALER = $xml->IdKlient;

        $type = \base::valE('select count(ID_DEALER) from DOST_CLIENTS where ID_DEALER='.$ID_DEALER,0,'deco') > 0?'update':'insert';
        $data = self::tagToFields('addr_dost',$xml);
        
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
    /** отправка клиенту информации по его авторизации (напиминалка) */
    public static function RequestAutorizeInfo($id_client,$send_type){
        
        $q = "select * from DEALER where ID_DEALER=$id_client";
        $dealer = \base::rowE($q,'deco',null);

        $s='Клиент: "'.\base::valE('select NAME from DEALER where ID_DEALER = '.$id_client.' order by NAME','','deco').'"<br><br>';
            
        $userDS =  \base::dsE("select * from USER where ID_DEALER = $id_client",'deco');
        $user = [];
        
        $admin_email    = \WS_CONF::GET('admin_email');
        $appName        = \WS_CONF::GET('appName');
        $appUrl         = \WS_CONF::GET('APPLICATION_URL');

        if ($send_type==1)
        {
            while(\base::by($userDS,$user))
                $s.='Сотрудник: "'.$user['NAME'].'"    логин: "'.$user['EMAIL_LOGIN'].'" пароль: "'.$user['PASS'].'"<br>';
                    
            return utils::sendMail(
                $dealer['EMAIL'],
                $admin_email,
                $appName.': Данные для входа.',
                'Данное письмо сгенерировано автоматически, отвечать на него не надо.<br>'.
                'Данные для входа в программу '.$appName.' ('.$appUrl.')<br><br>'.
                $s.
                '<br>С уважением<br>'.
                'Cлужба поддержки компании '.$appName.'!'
            );

        }else{
                    
            while(\base::by($userDS,$user))
            {
                $s.='Сотрудник: "'.$user['NAME'].'"   логин: "'.$user['EMAIL_LOGIN'].'" пароль: "'.$user['PASS'].'"<br>';
                if(trim($user['REL_EMAIL'])!=='')
                    utils::sendMail(trim($user['REL_EMAIL']),$admin_email,$appName.': Данные для входа.',
                        'Данное письмо сгенерировано автоматически, отвечать на него не надо.<br>'.
                        "Данные для входа в программу $appName ($appUrl)<br><br>".
                        $s.
                        '<br>Вы можете самостоятельно изменить свой логин и пароль, - кнопка "Настройки" раздел "Личные данные"'.
                        '<br>С уважением<br>'.
                        "Cлужба поддержки компании $appName!"
                    );                        
            }
                    
        }
        return true;
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
}
?>