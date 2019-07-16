<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler};


class PredvaritPrinyt extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   1;
        $this->action   =   2; 
    }
    public function run($xml){
        $ReplyId = $xml->attributes();
        
    }
}

new PredvaritPrinyt();
?>