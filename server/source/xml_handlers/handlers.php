<?php
namespace exweb\source\xml_handlers;
/**
 * коллекция обработчиков
 * 
 */

class Handlers{
    private static $list  = [];
    public static function add($common){
        self::$list[]=$common;
        
    }
    /**
     * возвращает true если найден обработчик либо false дибо свалится в exception
     */
    public static function run($xml){
        $have = false;
        foreach (self::$list as $common){
            if ($have = $common->runner($xml))
                break;
        };
    
        if (!$have)
            throw new \Exception('no handler for Kind='.$xml->attributes()->Kind.' Action='.$xml->attributes()->Action);
    
    }
};


?>