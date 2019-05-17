<?php

class Stream{
    
    public $read_block_name;   
    public $haveIncomingData;// есть входящие данные
    public $data; // блок данных
    public $md5; // хеш сумма

    public function __construct()
    {
        $this->read_block_name = 'b';
        $this->haveIncomingData = false;
        $this->data = null;
        $this->md5 = '';

        $this->loadIncomingData();
    }

    public function __destruct()
    {
        
    }

    /**
     * загрузка входящих данных, при наличии таковых
     */
    public function loadIncomingData()
    {
        try {
            if (isset($_FILES[$this->read_block_name])){
                
                $file =$_FILES[$this->read_block_name]['tmp_name'];
                $size =$_FILES[$this->read_block_name]['size'];  
                if (file_exists($file))
                { 
                        if ($size>0){
                            $h = fopen($file,"rb"); 
                            $this->data = fread($h,$size);
                            fclose($h); 
                        
                            $this->md5 = md5($this->data);
                            //$this->data =  addslashes($data);
                            //$this->data = mb_convert_encoding($this->data, 'utf-8', 'windows-1251');
                            $this->haveIncomingData = true;
                        }else{
                            $this->data = '';
                            $this->md5 = null;
                            $this->haveIncomingData = false;
                        }    

                }else   
                    throw new Exception("var `$this->read_block_name`  defined but file `$file` not exists");
        
            }    
        }catch (Exception $e){
            $this->data = null;
            $this->md5 = '';
            $this->haveIncomingData = false;
        }
    }
    
    /**
     * получение блока
     * @return block
     */
    public function getBlock($id_rest_api)
    {
        $block = false;
        try{
            $q = 'select ID_REST_API_DATA,SIZE from REST_API_DATA where ID_REST_API ='.$id_rest_api.' order by ID_REST_API_DATA';                
            $ds = base::ds($q,'exweb');
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
}

$stream = new Stream();


?>