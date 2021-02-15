<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler};
use exweb\source\{utils as UT};
/** перенос пользователей от клиента idKlient клиенту DestIdKlient */
class MoveUser extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   6;
        $this->action   =   3; 
    }
    public function run($xml){
        
        $from = (int)$xml->IdKlientFrom;
        $to   = (int)$xml->IdKlientTo;

        $q = 'select * from USER where ID_DEALER='.$from;

        $ds = \base::dsE($q,'deco');
        // получим рабочее место (куда помещаем)
        $fromDEALER = \base::row('select * from DEALER where ID_DEALER = '.$from,'deco');
        $toDEALER = \base::row('select * from DEALER where ID_DEALER = '.$to,'deco');

        while($user = \base::read($ds)){

            if ($user['IS_MAIN']!='1'){
                
                // переносим пользователя в другого клиента
                $q = 'update USER set ID_DEALER='.$to.' where ID_USER='.$user['ID_USER'];
                if (!\base::query($q,'deco'))
                    error_log('k6_13_MoveMouse: error on '.$q);
                
                // изменяем его рабочее место (устаревшее, но без этого не работает)
                $q = 'update USER_RIGHT_PLACE set ID_PLACE='.$toDEALER['ID_PLACE'].' where ID_USER='.$user['ID_USER'];
                if (!\base::query($q,'deco'))
                    error_log('k6_13_MoveMouse: error on '.$q);
                

                // все заказы пользователя переприсваиваем главному пользователю
                $q = 'update ORDERS set ID_USER='.$fromDEALER['ID_USER_MAIN'].' where ID_USER='.$user['ID_USER'];
                if (!\base::query($q,'deco'))
                    error_log('k6_13_MoveMouse: error on '.$q);


            }
        }


    }

};

new MoveUser();

?>