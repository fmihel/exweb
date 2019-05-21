<?php

namespace exweb\source;

$utf8_cyr_l = ['а','б','в','г','д','е','ж','з','и','й','к','л','м','н','о','п','р','с','т','у','ф','х','ц','ч','ш','щ','ъ','ы','ь','э','ю','я','ё'];
$utf8_cyr_h = ['А','Б','В','Г','Д','Е','Ж','З','И','Й','К','Л','М','Н','О','П','Р','С','Т','У','Ф','Х','Ц','Ч','Ш','Щ','Ъ','Ы','Ь','Э','Ю','Я','Ё'];
$utf8_cyr_l_code = [];//1072;
$utf8_cyr_h_code = [];//1040;
for($i=0;$i<32;$i++){
    $utf8_cyr_l_code[]='#'.(224+$i).';';
    $utf8_cyr_h_code[]='#'.(192+$i).';';
}
$utf8_cyr_l_code[]='#1027;';
$utf8_cyr_h_code[]='#1028;';

define('UNI_D',json_decode('"\u000d"'));
define('UNI_A',json_decode('"\u000a"'));

class Utils{
    /**
     * проверка налиичия входящей переменной $_REQUEST
     * Ex: Utils::requestContains($name1,$name2,$...);
     */
    public static function requestContains(){
        for($i=0;$i<func_num_args();$i++){
            if (!isset($_REQUEST[func_get_arg($i)]))
                return false;
        }
        return true;
    }
    static public function mb_str_replace($needle, $replace_text, $haystack) {
        return implode($replace_text, mb_split($needle, $haystack));
    }
    /**
     *  раскодирование, закодированной в delphi кириллицы 
     */    
    public static function rusEnCod(string $str) {
        global $utf8_cyr_l;
        global $utf8_cyr_h;
        global $utf8_cyr_l_code;
        global $utf8_cyr_h_code;

        $str = str_replace($utf8_cyr_l_code,$utf8_cyr_l,$str);
        $str = str_replace($utf8_cyr_h_code,$utf8_cyr_h,$str);
        return $str;
    }
    /**
     *  кодирование кириллицы в код понятный и интерпретаторам json и delphi
     */    
    public static function rusCod(string $str) {
        global $utf8_cyr_l;
        global $utf8_cyr_h;
        global $utf8_cyr_l_code;
        global $utf8_cyr_h_code;

        $str = str_replace($utf8_cyr_l,$utf8_cyr_l_code,$str);
        $str = str_replace($utf8_cyr_h,$utf8_cyr_h_code,$str);
        
        // при передачи строки из веб страницы, в частности с компонента textarea переносы строки помечаются только
        // \u000a, для  delphi нужно, чтобы было \u000d\u000a , 
        // поэтому везде где \u000a стоит не вместе с \u000d заменяю  \u000a на \u000d\u000a
        $str = str_replace(UNI_D.UNI_A,'{_ENT839ER_ALL_}',$str);
        $str = str_replace(UNI_A,UNI_D.UNI_A,$str);
        $str = str_replace('{_ENT839ER_ALL_}',UNI_D.UNI_A,$str);

        return $str;

    }    
}
?>