<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler,Utils};


class KarnizOstatki extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   3;
        $this->action   =   1; 
    }
    public function run($xml){
        \base::startTransaction('exweb');
        try{    
            
            $list = $xml->List->children();//tag = LIST  
            
            for($i = 0;$i<count($list);$i++)
            {  
                
                $Rest = $list[$i]->attributes();
                
                $OldRest = -1;
                if (Utils::ExistsRest($Rest->Id,$OldRest/*,$DsRest*/))        
                {        
                            
                    if ((($Rest->Ost>0) && ($OldRest<=0)) || (($Rest->Ost<=0) && ($OldRest>0))){
                                                
                        if ($Rest->Ost>0){
                            $LAST_FIELD = 'LAST_DELIVERY_DATE';                        
                            $LAST_MEAN = 'CURRENT_DATE';
                        }else{                    
                            $LAST_FIELD = 'LAST_RESET_DATE';                        
                            $LAST_MEAN = 'CURRENT_DATE';
                        };
                        $q = "update QID_REST set REST = $Rest->Ost,LAST_UPDATE=CURRENT_TIMESTAMP,KIND=$Rest->Kind,DELIV='$Rest->Deliv', $LAST_FIELD=$LAST_MEAN,ARCH=0 where TOVAR_ID=$Rest->Id";                                
                    }else{
                        $q = "update QID_REST set REST = $Rest->Ost,LAST_UPDATE=CURRENT_TIMESTAMP,KIND=$Rest->Kind,DELIV='$Rest->Deliv', ARCH=0 where TOVAR_ID=$Rest->Id";                                            
                    };                                                
                }else{
                    
                    if ($Rest->Ost<=0){
                        $LAST_RESET = 'CURRENT_DATE';                    
                        $LAST_DELIVERY = "DATE_FORMAT('".DELIVERY_NULL_DATE_TO_UPDATE."','%Y-%m-%d')";
                    }else{
                        $LAST_RESET ="DATE_FORMAT('".DELIVERY_NULL_DATE_TO_UPDATE."','%Y-%m-%d')";                    
                        $LAST_DELIVERY = 'CURRENT_DATE';
                    };                
                    
                    $q = "insert into QID_REST (TOVAR_ID,REST,LAST_UPDATE,KIND,DELIV,LAST_RESET_DATE,LAST_DELIVERY_DATE,ARCH) values 
                            ($Rest->Id,$Rest->Ost,CURRENT_TIMESTAMP,$Rest->Kind,'$Rest->Deliv',$LAST_RESET,$LAST_DELIVERY,0)";
                };
            
                if (!\base::query($q,'exweb'))
                    throw new \Exception(\base::error('exweb'));
                
                // очитка буффера, в котором содержится данный товар
                try{
                    // получим список моделей или разделов в котором содержится товар
                    $modelId = Utils::getModelsIdByID_K_TOVAR_DETAIL($Rest->Id);
                    if ( ( count($modelId['model'])>0 ) || ( count($modelId['chapter'])>0 ) ){
                        // очистим все строки буфера, которые содержат данные модели
                        Utils::clearBufferBy('priceA',array_merge($modelId['model'],$modelId['chapter']));
                        Utils::clearBufferBy('priceB',array_merge($modelId['model'],$modelId['chapter']));
                    }

                }catch(\Exception $e){

                }
            };

            \base::commit('exweb');

        }catch(\Exception $e){

            \base::rollback('exweb');
            throw new \Exception($e->getMessage());

        }

    }
}

new KarnizOstatki();
?>