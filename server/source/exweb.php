<?php
use PhpOffice\PhpSpreadsheet\Calculation\Exception;

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
            $ds = base::ds($q,'exweb');
            $row =[];
            while(base::by($ds,$row)){
                $q = 'select BLOCK from REST_API_DATA where ID_REST_API_DATA ='.$row['ID_REST_API_DATA'];
                $data = base::val($q,'','exweb');
                if ($block===false)
                    $block=$data;
                else    
                    $block.=$data;
            };

        }catch(Exception $e){
            return '';
        }
        return $block;
    }
    /**
     * получение сообщения
     * при указании $completed = true сообщение, после прочтения будет помечено как 'completed'
     * @return ['id'=>int,'str'=>string,'data'=>stream]
     */
    public static function recv(bool $completed = false){
        $q = "select ID_REST_API,STR,SIZE from REST_API where OWNER='client' and STATE='ready' order by ID_REST_API";
        $row = base::row($q,'exweb');
        if ($row === false)
            throw new Exception(base::error('exweb'));
        
        $result = [
            'id'=>0,
            'str'=>'',
            'data'=>null
        ];

        if ($row!=[]){
            $result['id'] = $row['ID_REST_API'];
            $result['str'] = $row['STR'];
            if($row['SIZE']>0)
                $result['data'] = self::getBlock($row['ID_REST_API']);
            
            if ($completed)
                self::completed($row['ID_REST_API']);
        }


        return $result;
    }
    /**
     * отправка сообщения клиенту
     */
    public static function send(string $str,$data = null){
        
        // создаем строку в таблице REST_API
        $id = base::insert_uuid('REST_API','ID_REST_API','exweb');

        if ($id===false)
            return false;
        
            $q = "update REST_API set OWNER='server', STATE='init', STR = '".$str."', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$id;
        
        if (!base::query($q,'exweb'))
            return false;

        return $id;
        
    }
    public static function completed(int $id_rest_api){
        $q = "update REST_API set STATE='completed' where ID_REST_API=$id_rest_api";
        return base::query($q,'exweb');
    }
}

?>
