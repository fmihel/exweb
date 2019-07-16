<?php
namespace exweb\source\xml_handlers;

/**
 * базовый класс для обработчиков входящих пакетов, передаваемых в протоколе обмена
 * Пример создания обработчика
 * 
 * namespace exweb\source\xml_handlers\handlers;
 * 
 * class MyHandler extends Handler{
 *      public function __construct()}{
 *          parent::__construct();
 *          $this->action = 1;
 *          $this->kind   = 2;
 *      }
 *      public function run($xml){
 *          // to do
 
 *      }
 * }
 */

class Handler{
    public $kind;
    public $action;
    /** 
     * конструктор. В нем обработчик добавляется в общий список обработчиков handlers
     * тут же указываем kind и action
    */
    public function __construct(){
        Handlers::add($this);
    }
    /** проверка  на то что xml для данного обработчика*/
    public function isThis($xml){
        $attr = $xml->attributes();
        return ($this->kind == $attr['Kind']) && ($this->action == $attr['Action']);            
    }   
    /** метод для handlers. Запускается только  из handlers*/
    public function runner($xml){
        if ($this->isThis($xml)){
            $this->run($xml);
            return true;
        }else
            return false;
    }
    /** метод обработчика. Определяется в наследуемом классе */
    public function run($xml){
        // virtual
    }
}

?>