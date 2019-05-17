<?php
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
    public static function rusEnCod(string $str) {
        $LMin=1072; // а
        $LMax=1103; // я
        $HMin=1040; // А
        $HMax=1071; // Я
        $A = ord('а')+16;
        $B = ord('А')-16;

        $result = $str;
        
        for($i=$LMin;$i<=$LMax;$i++){
            $code = '#'.$i.';';
            $result =str_replace($code,chr($A+$i-$LMin),$result);
        }

        for($i=$HMin;$i<=$HMax;$i++){
            $code = '#'.$i.';';
            $result =str_replace($code,chr($B+$i-$HMin),$result);
        }

        return $result;
    }
}
?>