<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler};


class Test extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   -1;
        $this->action   =   -1; 
    }
    public function isThis($xml)
    {
        return true;
    }
    public function run($xml){
        try{    
            //throw new Exception("Error Processing Request", 1);
            echo 'Ok';
        }catch(\Exception $e){

            throw new \Exception($e->getMessage());

        }

    }
}

new Test();
?>