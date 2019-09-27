<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler};
use exweb\source\{utils as UT};

class ChangeClientData extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   2;
        $this->action   =   1; 
    }
    public function run($xml){
        
        $id         =   (int)$xml->IdKlient;
        $email      =   (string)$xml->KlientInfo->DecoRMail;
        $enable     =   (int)$xml->KlientInfo->RemoteAccess;
        $arch       =   (int)$xml->KlientInfo->Arch;
        $klientname =   (string)$xml->KlientInfo->KlientName;

        $ID_RIGHT  = 0;
        
        $PASS_DEFAULT = UT::random_str(5);

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

        self::updateCatalogUserInfo($xml);

    }
    /**
     * обновление информации о пользователе КАТАЛОГ - ONLINE
     * @param {xml} - 
     * @return true | Exception
     */
    private function updateCatalogUserInfo($xml){
        $id         =   (int)$xml->IdKlient;
        $email      =   trim((string)$xml->KlientInfo->DecoRMail);
        $enable     =   (int)$xml->KlientInfo->RemoteAccess;
        $arch       =   (int)$xml->KlientInfo->Arch;


        if (\base::val("select count( ID ) from QID_AUTORIZE where ID = $id",0,'exweb') == 0){
            $types =  \base::fieldsInfo('QID_AUTORIZE','types','exweb');
            $pass = UT::random_str(5);
            $q = \base::dataToSQL('insert','QID_AUTORIZE',[
                'KIND'=>3,
                'ID'=>$id,
                'DATE_CREATE'=>['CURRENT_TIMESTAMP','int'],
                'EMAIL'=>$email,
                'ENABLE'=>$enable,
                'ARCH'=>$arch,
                'PASS'=>[$pass,'string'],
            ],['types'=>$types]);
            \base::queryE($q,'exweb');
            
        }else{
            $types =  \base::fieldsInfo('QID_AUTORIZE','types','exweb');
            $q = \base::dataToSQL('update','QID_AUTORIZE',[
                    'ENABLE'=>$enable,
                    'ARCH'=>$arch,
                ],['types'=>$types])." where ID = $id";

            \base::queryE($q,'exweb');
            
            if ($email!==''){
                $q = "select EMAIL from QID_AUTORIZE where ID=$id";
                $emails = \base::val($q,'','exweb');
            
                $emails = UT::replaceAll('  ',' ',trim($emails));
                $emails = UT::replaceAll(' ',',',$emails);
                $emails = UT::replaceAll(';',',',$emails);
                $emails = UT::replaceAll(',,',',',$emails);

                $_emails = explode(',',$emails);
                $emails = [];
                foreach($_emails as $v){ if ($v!=='') $emails[]=$v;}

                if (array_search($email,$emails)===false){
                    $emails[] = $email;
                    $emails = implode(',',$emails);
                    $q = \base::dataToSQL('update','QID_AUTORIZE',['EMAIL'=>[$emails,'string']])." where ID=$id";    
                    
                    \base::queryE($q,'exweb');
                }
            }// if ($email!=='')
        } // else
        return true;
    }// updateCatalogUserInfo
};

new ChangeClientData();

?>