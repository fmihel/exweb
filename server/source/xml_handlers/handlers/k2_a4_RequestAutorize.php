<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler};
use exweb\source\{utils as UT};

class RequestAutorize extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   2;
        $this->action   =   4; 
    }
    public function run($xml){

        $id_client = $xml->IdKlient;
        $send_type = ($xml->DestKind!=2?1:2);

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
                    
            return UT::sendMail(
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
                    UT::sendMail(trim($user['REL_EMAIL']),$admin_email,$appName.': Данные для входа.',
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
}

new RequestAutorize();

?>