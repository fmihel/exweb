<?php
namespace exweb\source;
/**
 * класс коллекция событий и их обработчиков
 */
class Events{
    static private $list=[];
    /**
     * добавление события
     * 
     * Ex: если просто ф-ция
     * function mm(){..}
     * Events::add('onComplete','mm');
     * Events::add('onComplete',mm);
     * 
     * Ex: если метод
     * $t->func();
     * Events::add('onComplete',[$t,'func']);
     *  
     * t::ff();
     * Events::add('onComplete','t::ff');
     */
    public static function add(string $event,$func){
        self::$list[$event][] = $func;
    }
    /**
     * вызов всех ф-ций привязаных к событию
     * Ex:
     * Events::do('doComplete');
     * Events::do('doComplete',['sender'=>$this,'key'=>1]);
     */
    public static function do(string $event,$params=[]){
        if (!isset(self::$list[$event])) 
            return;

        $funcs = self::$list[$event];
        foreach($funcs as $func){
            try{
                $func($params);
            }catch(\Exception $e){
                error_log('error call ['.$func.'] '.$e->getMessage());
            }
        }
    }
}


?>