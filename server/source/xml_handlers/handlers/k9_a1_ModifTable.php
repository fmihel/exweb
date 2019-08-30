<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler,Utils as ut};
use exweb\source\{Utils as Utils}; 

/**
 * модификация таблиц
 */
class ModifTable extends Handler{
    
    // список таблиц с индексами, которые может изменять обработчик
    private $access=[
        'DE_USER'       =>'ID_DE_USER',
        'DE_RIGHT'      =>'ID_DE_RIGHT',
        'DE_ROL'        =>'ID_DE_ROL',
        'DE_ROL_RIGHT'  =>'ID_DE_ROL_RIGHT',
        'DE_USER_RIGHT' =>'ID_DE_USER_RIGHT',
        'DE_USER_ROL'   =>'ID_DE_USER_ROL',
        
        'NEWS'          =>'ID_NEWS', // пока для тестов добавил 
    ];
    private $adminEmail;//['fmihel76@gmail.com','george@windeco.ru'];

    private $ID_DEALER_MENAGER; // дилер для менеджеров
    
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   9;
        $this->action   =   1; 
        $this->adminEmail       = \WS_CONF::GET('emailForKind9Action1',['fmihel76@gmail.com','george@windeco.ru']);
        $this->ID_DEALER_MENAGER = \WS_CONF::GET('ID_DEALER_MANAGER',1);
        
    }
    public function run($xml){
        $coding = 'utf8';
        
        $de_tables=['DE_USER'/*,'DE_RIGHT','DE_ROL','DE_ROL_RIGHT','DE_USER_RIGHT','DE_USER_ROL'*/]; // список таблиц при обновлении,котороых необходимо запустить дополнительный обработчик 

        $run_de_handler = false;

        \base::startTransaction('deco');
        \base::startTransaction('exweb');
        try{
            $Tables = $xml->Tables->children();    
            for($i=0;$i<count($Tables);$i++){
                $Table = $Tables[$i];
                $TableName      = (string)ut::xmlAttr($Table,'Name');

                if (array_key_exists($TableName,$this->access)){
                    $run_de_handler = $run_de_handler || (array_search($TableName,$de_tables)!==false);

                    //$IdFieldName    = (string)ut::xmlAttr($Table,'IdFieldName');
                    $IdFieldName = $this->access[$TableName];

                    $Base           = (string)ut::xmlAttr($Table,'Base','deco');
                    $types = \base::fieldsInfo($TableName,'types',$Base);
                    $fieldsName = \base::fieldsInfo($TableName,'short',$Base);
        
                    $rows = $Table->children();
                    for($j=0;$j<count($rows);$j++){
                        $row = $rows[$j];
                        $id = (int)ut::xmlAttr($row,'Id','');
                        $Action = (string)ut::xmlAttr($row,'Action','update');
                        
                        $query = '';
                        //----------------------------------------------------------------------------------------------------------------
                        if($Action === 'update'){
                            
                            if ($id!=='')    
                                $data = [$IdFieldName=>$id];
    
                            $fields = $row->children();
                            for($k=0;$k<count($fields);$k++){
                                $field = $fields[$k];
                                $name = (string)ut::xmlAttr($field,'Name');
                                $name = $this->toFieldName($name,$fieldsName);
                                if ($name!==false){
                                    $value = (string)$field;
                                    $data[$name] = $value; 
                                };        
                            }        
                            $query = \base::dataToSQL('insertOnDuplicate',$TableName,$data,['refactoring'=>false,'types'=>$types]);
    
                        //----------------------------------------------------------------------------------------------------------------
                        }elseif ($Action === 'delete'){
                            
                            if ($id!==''){

                                $query = "delete from `$TableName` where `$IdFieldName` = $id";
                            }    
                        }
    
                        
                        if ($query!==''){
                            //echo $query."\n-------------------------------\n";
                            if ($Action === 'delete')  // перед удаление необходимо удалить 
                                $this->deleteUSER($id);
                            \base::queryE($query,$Base,$coding);
                        }
                        
                        
                    } // for($j=0;$j<count($rows);$j++)
                }
            } // for($i=0;$i<count($Tables);$i++)  
            \base::commit('exweb');
            \base::commit('deco');

        }catch(\Exception $e){
            \base::rollback('exweb');
            \base::rollback('deco');
            
            throw new \Exception($e->getMessage());
        }

        if ($run_de_handler)
            $this->updateDE_USER();
    }
    /** 
     * преобразование к нужному регистру имени поля переданного в xml атрибуте
     * если имени нет, то возвращает false
    */
    private function toFieldName($xmlName,$fieldsName){
        if (array_search($xmlName,$fieldsName)!==false)
            return $xmlName;

        $upper = strtoupper($xmlName);    
        foreach($fieldsName as $name){
            if (strtoupper($name)===$upper)
                return $name;
        }
        return false;
    }
    
    /**
     * обработчик вызываемый если пришли изменения в таблицах прав декопользователей DE_xxx
     */
    private function updateDE_USER(){
        
        \base::startTransaction('deco');
        try{
            // список всех менеджеров
            $q = "select * from DE_USER ";
            $ds = \base::dsE($q,'deco');
            
            $row = [];
            while(\base::by($ds,$row)){
                if ($row['ID_KLIENT'] != $this->ID_DEALER_MENAGER){ // пользователь не создан
                    $ID_USER = $this->createUSER();
                    $data = [
                        'ID_KLIENT'     =>$this->ID_DEALER_MENAGER,
                        'ID_USER'       =>$ID_USER,
                    ];    
                    $q = \base::dataToSQL('update','DE_USER',$data,['where'=>'ID_DE_USER = '.$row['ID_DE_USER']]);
                    \base::queryE($q,'deco');
    
                }else
                    $ID_USER = $row['ID_USER'];
                
                $autorize = $this->validLoginPass($ID_USER,$row['PWD'],$row['LOGIN']);

                $data = [
                    'NAME'          =>[$row['FIO'],     'string'],
                    'EMAIL_LOGIN'   =>[$autorize['login'],   'string'],
                    'ENABLE'        =>($row['ARCH']==1?0:1),
                    'PASS'          =>[$autorize['pass'],     'string'],
                ];    
                $q = \base::dataToSQL('update','USER',$data,['where'=>'ID_USER = '.$ID_USER]);
                \base::queryE($q,'deco');
            };
          
            
            \base::commit('deco');
        }catch(Exception $e){
            \base::rollback('deco');
            throw new \Exception($e->getMessage());
        }
    }
    /**
     * генерация уникального значения для поля $field (исключая ID_USER)
     * @return string | Exception
     */
    private function generate($field,$ID_USER){
        
        $res = '';
        $loop = 1000;
        while(1>0){
            $loop--;
            if ($loop<=0)
                throw new Exception("generate $field is loop...");
                
            $res = Utils::random_str(5);
            $q = "select count(ID_USER) from USER where ID_USER <> $ID_USER and $field = '$res'";
             if (\base::valE($q,0,'deco')==0) 
                return $res;
        }    
    }
    /**
     * проверка пароля и логина на уникальность
     * если логин или пароль не уникальны, генерируются новые см generate 
     * @return ['login'=>string,'pass'=>string] | Exception
     */
    private function validLoginPass($ID_USER,$pass,$login){

        $countLogin   =  \base::valE("select count(ID_USER) from USER where ID_USER <> $ID_USER and EMAIL_LOGIN = '$login'",0,'deco');
        $countDouble  =  \base::valE("select count(ID_USER) from USER where ID_USER <> $ID_USER and PASS='$pass' and EMAIL_LOGIN='$login' ",0,'deco');

        $msg = '';


        if ($countDouble>0){
            
            $msg.="password `$pass` and login '$login' is duplicated for user ID_USER=$ID_USER is exists\n";
            
            $pass  = $this->generate('PASS',$ID_USER);
            $login = $this->generate('EMAIL_LOGIN',$ID_USER);
            
            $msg.="generate new pass = `$pass`\n";
            
        }elseif ($countLogin>0){
            
            $msg.="login `$login` for user ID_USER=$ID_USER is exists\n";
            $login = $this->generate('EMAIL_LOGIN',$ID_USER);
            $msg.="generate new login = `$login`\n";
            
        };

        
        if ($msg!==''){
            
            // поставил в try т.к. в условиях localhost не работает :( 
            // но как таковым это не является ошибкой    
            foreach($this->adminEmail as $email){
                try{
                    Utils::sendMail($email,'info@windeco.su','Windeco: Not unique login password',$msg);
                }catch(\Exception $e){
                    error_log($e->getMessage());
                }
            }
        }    

        return ['login'=>$login,'pass'=>$pass];

    }
    /**
     * создание пользователя 
     * return ID_USER | Exception
     */
    private function createUSER(){
        // определяем место 
        $ID_PLACE = \base::valE('select ID_PLACE from PLACE where ID_DEALER='.$this->ID_DEALER_MENAGER,-1,'deco');
        if ($ID_PLACE == -1)
            throw new Exception("Can`t find PLACE for ID_DEALER =".$this->ID_DEALER_MENAGER);
        
        // создаем пользователя
        $ID_USER = \base::insert_uuidE('USER','ID_USER','deco');
        
        // связываем пользователя с дилером
        $q = \base::dataToSQL('update','USER', ['ID_DEALER'     =>$this->ID_DEALER_MENAGER],['where'=>'ID_USER = '.$ID_USER]);
        \base::queryE($q,'deco');

        // связываем пользователя с дилером и местом
        $data = [
            'ID_USER'=>$ID_USER,
            'ID_RIGHT'=>1, // пользователь
            'ID_PLACE'=>$ID_PLACE,
        ];    
        $q = \base::dataToSQL('insert','USER_RIGHT_PLACE', $data);
        \base::queryE($q,'deco');

        return $ID_USER;
    }
    /**
     * удаление из структуры личного каталога
     */
    private function deleteUSER($ID_DE_USER){
        $ID_USER = \base::valE('select ID_USER from DE_USER where ID_DE_USER = '.$ID_DE_USER,-1,'deco');
        if ($ID_USER>0){
            $q = 'delete from USER where ID_USER = '.$ID_USER;
            \base::queryE($q,'deco');

            $q = "delete from USER_RIGHT_PLACE where ID_USER = $ID_USER";
            \base::queryE($q,'deco');
        }
    }
    
}

new ModifTable();
?>