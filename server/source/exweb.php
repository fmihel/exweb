<?php
namespace exweb\source;

use PhpOffice\PhpSpreadsheet\Reader\DefaultReadFilter;

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
     * @return ['id'=>int,'str'=>string,'data'=>stream]
     */
    public static function recv(){

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
        }else
            $result = false;    

        return $result;
    }
    /**
     * отправка сообщения клиенту(в офис)
     * будет сформировано событие
     * onReady
     */
    public static function send(string $str,$data = null){
        $id  = -1;
        
        try{
            
            // создаем строку в таблице REST_API
            $id = \base::insert_uuid('REST_API','ID_REST_API','exweb');
    
            if ($id===false)
                Result::error('Error create row in REST_API');
            
            $q = "update REST_API set OWNER='server', STATE='init', STR = '".$str."', LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=".$id;
            Result::query($q);
    
            exweb::state(['id'=>$id,'state'=>'ready']);

        }catch(\Exception $e){
            Result::error($e->getMessage());
        }
        return $id;
    }
    /**
     * управление состояниями
     * 
     * Получить состояние:
     * exweb:state(['id'=>10]);
     * 
     * Установить состояние:
     * exweb::state(['id'=>10,'state'=>'error']);
     */
    public static function state($o){
        $a = \ARR::union([
            'id'=>-1,
            'state'=>'',
            'msg'=>'',
            'needCallHandler'=>true,
        ],$o);

        if ($a['id']==-1) 
            throw new \Exception("exweb::state need set id");
            
        $id = $a['id'];
        $msg = '';

        if ($a['state']==''){
            return \base::valE("select STATE from REST_API where  ID_REST_API = $id",'exweb');
        }else{

            switch ($a['state']) {
                case 'ready':
                    $q = "update REST_API set STATE='ready',ERROR_MSG = '',LAST_UPDATE=CURRENT_TIMESTAMP where STATE<>'completed' and ID_REST_API=$id";
                    break;
                case 'completed':
                    $q = "update REST_API set STATE='completed',ERROR_MSG = '',LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=$id";
                    break;
                case 'error':
                    $msg = str_replace(["'"],['"'],\base::real_escape($a['msg'],'exweb'));
                    $q = "update REST_API set STATE='error',ERROR_MSG = '$msg',LAST_UPDATE=CURRENT_TIMESTAMP where ID_REST_API=$id";
                    break;
                default:
                    throw new Exception('no defined handler for state ['.$a['state'].'] in exweb::state');
            };

            \base::queryE($q);

            if ($a['needCallHandler']){
                switch ($a['state']) {
                    case 'ready':
                        Events::do('onReady',['id_rest_api'=>$id]);                        
                        break;
                    case 'completed':
                        Events::do('onCompleted',['id_rest_api'=>$id]);                        
                        break;
                    case 'error':
                        Events::do('onError',['id_rest_api'=>$id,'msg'=>$msg]);                        
                        break;
                };
    
            }
        }    

        
    }

    public static function completed(int $id){
        self::state(['id'=>$id,'state'=>'completed']);
        return true;
    }
    
    public static function setAsError(int $id,$msg=''){
        self::state(['id'=>$id,'state'=>'error','msg'=>$msg]);
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
