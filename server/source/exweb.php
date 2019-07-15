<?php
namespace exweb\source;

//use PhpOffice\PhpSpreadsheet\Calculation\Exception;

class exweb {

    /**
     * получение блока
     * @return block
     */
    public static function getBlock(string $id_rest_api)
    {
        $block = false;
        try{
            $q = 'select ID_REST_API_DATA from REST_API_DATA where ID_REST_API ='.$id_rest_api.' order by ID_REST_API_DATA';                
            $ds = \base::ds($q,'exweb');
            $row =[];
            while(\base::by($ds,$row)){
                $q = 'select BLOCK from REST_API_DATA where ID_REST_API_DATA ='.$row['ID_REST_API_DATA'];
                $data = \base::val($q,'','exweb');
                if ($block===false)
                    $block=$data;
                else    
                    $block.=$data;
            };

        }catch(\Exception $e){
            return '';
        }
        return $block;
    }
    /**
     * получение сообщения (из офиса)
     * при указании $completed = true сообщение, после прочтения будет помечено как 'completed'
     * @return ['id'=>int,'str'=>string,'data'=>stream]
     */
    public static function recv(bool $completed = false){
        $q = "select ID_REST_API,STR,SIZE from REST_API where OWNER='client' and STATE='ready' order by ID_REST_API";
        $row = \base::row($q,'exweb');
        if ($row === false)
            return false;
        
        if ($row!=[]){

            $result = [];
    
            $result['id'] = $row['ID_REST_API'];
            $result['str'] = $row['STR'];
            if($row['SIZE']>0)
                $result['data'] = self::getBlock($row['ID_REST_API']);
            
            if ($completed)
                self::completed($row['ID_REST_API']);

        }else
            $result = false;    

        return $result;
    }
    /**
     * отправка сообщения клиенту(в офис)
     */
    public static function send(string $str,$data = null){
        
        // создаем строку в таблице REST_API
        $id = \base::insert_uuid('REST_API','ID_REST_API','exweb');

        if ($id===false)
            Result::error('Error create row in REST_API');
        
        $q = "update REST_API set OWNER='server', STATE='init', STR = '".$str."', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$id;
        Result::query($q);

        $q = "update REST_API set STATE='ready', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$id;
        Result::query($q);

        return $id;
    }
    
    public static function completed(int $id){
        $q = "update REST_API set STATE='completed' where ID_REST_API=$id";
        return \base::query($q,'exweb');
    }

    public static function setAsError(int $id,$msg=''){
        $msg = str_replace(["'"],['"'],\base::real_escape($msg,'exweb'));
        $q = "update REST_API set STATE='error',ERROR_MSG='$msg' where ID_REST_API=$id";
        if (!\base::query($q,'exweb')) 
            throw new \Exception("error in setAsError($id)");
            
    }
    /** очистка отработанных сообщений
     * Ex: exweb::clear("completed");
     * 
     * Алгоритм запускается в определенный интервал (по уолчанию с 09:00 до 10:00)
     * можно переопределить в ws_confg.php.
     * Очищаются все записи указанного state, на holdDay от сегодня.
     * return: undfined | Exception
     */
    public static function clear($state=false,$o=[]){
        if ($state == false)
            return;

        $a = \ARR::union($o,[
            'holdDay' => \WS_CONF::GET('holdDay',2),  // кол-во дней для которых сохраненяем данные, все что старше удаляем
            'start'=>\WS_CONF::GET('clear_start_time','09:00'),// время наала работы
            'stop'=>\WS_CONF::GET('clear_stop_time','10:00'),// время конца работы работы

        ]);

        // алгоритм запскаем только в определенный интервал
        $start = strtotime($a['start']);
        $stop  = strtotime($a['stop']);
        $current = time();
        
        if (($stop-$current<0) || ($current-$start<0) )
            return;
        
        // ------------------------------------------------

        // поулчаем все записи к удалению
        $q = 'select ID_REST_API from `REST_API` where (`STATE` = "'.$state.'") and ((TO_DAYS(NOW()) - TO_DAYS(`CREATE_DATE`))>'.$a['holdDay'].')';
        $rest_api = \base::dsE($q,'exweb');
        if(\base::isEmpty($rest_api))
            return;

        \base::startTransaction('exweb');
        try{
            $row = [];

            while(\base::by($rest_api,$row)){
                
                $q = 'delete from `REST_API_DATA` where `ID_REST_API` = '.$row['ID_REST_API'];
                \base::queryE($q,'exweb');

            };
            $q = 'delete from `REST_API` where (`STATE` = "'.$state.'") and ((TO_DAYS(NOW()) - TO_DAYS(`CREATE_DATE`))>'.$a['holdDay'].')';
            \base::queryE($q,'exweb');

            \base::commit('exweb');

        }catch(\Exception $e){

            \base::rollback('exweb');
            throw new \Exception($e->getMessage());

        }


    }
}

?>
