<?php
    require_once UNIT('plugins','base/base.php');
    
    define ('SERVER_NAME1', WS_CONF::GET('exweb_server'));
    define ('SERVER_USER1', WS_CONF::GET('exweb_user')); 
    define ('SERVER_PASS1', WS_CONF::GET('exweb_pass')); 
    define ('BASE_NAME1',   WS_CONF::GET('exweb_base'));    

    base::connect(SERVER_NAME1,SERVER_USER1,SERVER_PASS1,BASE_NAME1,'exweb');
    //base::charSet('cp1251','exweb');
    base::charSet('utf8','exweb');

    define ('SERVER_NAME2', WS_CONF::GET('deco_server'));
    define ('SERVER_USER2', WS_CONF::GET('deco_user')); 
    define ('SERVER_PASS2', WS_CONF::GET('deco_pass')); 
    define ('BASE_NAME2',   WS_CONF::GET('deco_base'));    

    base::connect(SERVER_NAME2,SERVER_USER2,SERVER_PASS2,BASE_NAME2,'deco');
    base::charSet('utf8','deco');


    
?>