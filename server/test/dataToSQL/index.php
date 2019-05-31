<?php
/** <?xml version="1.0" encoding="unicode"?> */  

if(!isset($Application)){
    require_once '../../../../wsi/ide/ws/utils/application.php';
    
    $Application->LOG_ENABLE        = true;
    $Application->LOG_TO_ERROR_LOG  = false; 
    
    require_once UNIT('ws','ws.php');
};
require_once UNIT('plugins','base/base.php');

$data = ['ID_ORDER'=>10,'NAME'=>'Mike'];
$res = base::dataToSQL('update','ORDER',$data,['types'=>['NAME'=>'string']]);
echo '<xmp>';
echo $res;
echo '</xmp>';
?>