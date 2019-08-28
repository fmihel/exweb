<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler,Utils as ut};


/**
 * модификация таблиц
 */
class ModifTable extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   9;
        $this->action   =   1; 
    }
    public function run($xml){
        $coding = 'utf8';

        \base::startTransaction('deco');
        try{
            $Tables = $xml->Tables->children();    
            for($i=0;$i<count($Tables);$i++){
                $Table = $Tables[$i];
                $TableName      = (string)ut::xmlAttr($Table,'Name');
                $IdFieldName    = (string)ut::xmlAttr($Table,'IdFieldName');
                $Base           = (string)ut::xmlAttr($Table,'Base','deco');
                $types = \base::fieldsInfo($TableName,'types',$Base);
                $fieldsName = \base::fieldsInfo($TableName,'short',$Base);
    
                $rows = $Table->children();
                for($j=0;$j<count($rows);$j++){
                    $row = $rows[$j];
                    $id = (int)ut::xmlAttr($row,'Id','');
                    $type = (string)ut::xmlAttr($row,'Type','update');
                    
                    $query = '';
                    //----------------------------------------------------------------------------------------------------------------
                    if($type === 'update'){
                        
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
                    }elseif ($type === 'delete'){
                        
                        if ($id!=='')    
                            $query = "delete from `$TableName` where `$IdFieldName` = $id";

                    }

                    
                    if ($query!==''){
                        //echo $query."\n-------------------------------\n";
                        \base::queryE($query,$Base,$coding);
                    }
                    
                    
                }
            }    
            \base::commit('deco');

        }catch(\Exception $e){
            \base::rollback('deco');
            throw new \Exception($e->getMessage());
        }
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
   
}

new ModifTable();
?>