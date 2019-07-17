<?php
namespace exweb\source\xml_handlers;

require_once __DIR__.'/consts.php';
require_once __DIR__.'/utils.php';
require_once __DIR__.'/handler.php';
require_once __DIR__.'/handlers.php';

$dir_handlers = __DIR__.'/handlers';
//require_once $dir_handlers.'/test.php';

require_once $dir_handlers.'/k8_a1_TkaniOstatki.php';
require_once $dir_handlers.'/k3_a1_KarnizOstatki.php';
require_once $dir_handlers.'/k2_a4_RequestAutorize.php';
require_once $dir_handlers.'/k2_a3_AddrDost.php';
require_once $dir_handlers.'/k2_a1_ChangeClientData.php';
//require_once $dir_handlers.'/k1_a2_PredvaritPrinyt.php';

?>