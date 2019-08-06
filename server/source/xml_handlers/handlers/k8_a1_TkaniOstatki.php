<?php
namespace exweb\source\xml_handlers\handlers;
use exweb\source\xml_handlers\{Handler};
use exweb\source\{utils as UT};


class TkaniOstatki extends Handler{
    public function __construct()
    {
        parent::__construct();
        $this->kind     =   8;
        $this->action   =   1; 
    }
    public function run($xml){
        \base::startTransaction('deco');
        try{
            
            $List = $xml->TxProductsList->children();
            $cnt = count($List);

            for($i=0;$i<$cnt;$i++){
    
                $Textile = $List[$i];
                $attr = $Textile->attributes();
                $ID_TEXTILE = $attr->IdTextile;
                $ID_TX_COLOR = $attr->IdTxColor;
                $COLOR_OSTATOK = UT::strToFloat($attr->Ostatok,'asFloat');
                
                
                if (\base::val("select count(ID_TX_COLOR) from TX_COLOR where ID_TX_COLOR = $ID_TX_COLOR and ID_TEXTILE = $ID_TEXTILE",0,'deco')>0){
                    
                    $q = "update TX_COLOR set OSTATOK = $COLOR_OSTATOK where ID_TX_COLOR = $ID_TX_COLOR and ID_TEXTILE = $ID_TEXTILE";
                    \base::queryE($q,'deco');
                    
                    $TxPiece =  $Textile->children();   
                    for($j=0;$j<count($TxPiece);$j++)
                    {
                        $piece          = $TxPiece[$j]->attributes();
                        $ID_TX_PIECE    = $piece->IdTxPiece;
                        if ($ID_TX_PIECE != ''){
                            
                            $NOM            = $piece->Nom;
                            $OSTATOK        = UT::strToFloat($piece->Ostatok,'asFloat');
                            $BRONIR         = UT::strToFloat($piece->Bronir,'asFloat');
                        
                            if ($OSTATOK !== 0){
                                $q = "insert into TX_PIECE (ID_TX_COLOR,ID_TX_PIECE,NOM,OSTATOK,BRONIR,NOTE,D_LAST_CHANGE) values ($ID_TX_COLOR,$ID_TX_PIECE,$NOM,$OSTATOK,$BRONIR,'',CURRENT_TIMESTAMP) 
                                    on duplicate key update ID_TX_COLOR = $ID_TX_COLOR,NOM=$NOM,OSTATOK =$OSTATOK,BRONIR=$BRONIR" ;
                                \base::queryE($q,'deco');
                            }else{
                                $q = "delete from TX_PIECE where ID_TX_PIECE = $ID_TX_PIECE";
                                \base::queryE($q,'deco');
                            }    
                        };
                    }//for($j=0;$j<$Textile->Count();$j++)
                };//Count >0
            }//for($i=0;$i<$List->Count();$i++)
            \base::commit('deco');
        }catch(\Exception $e){
            \base::rollback('deco');
            throw new \Exception($e->getMessage());
        }
    }
}

new TkaniOstatki();

?>