<?php
/** <?xml version="1.0" encoding="unicode"?> */  

if(!isset($Application)){
    require_once '../../../../wsi/ide/ws/utils/application.php';
    
    $Application->LOG_ENABLE        = true;
    $Application->LOG_TO_ERROR_LOG  = false; 
    
    require_once UNIT('ws','ws.php');
};

function tagToFields($name,$xml){
	$result = [
		'data'=>[],
		'types'=>[],
	];

	// соотвествие tag полям в базе
	$tags = [
		'addr_dost'=>[
			'KlientId'      =>'ID_DEALER',
			'BossPost'      =>['BOSS_POST','string'],
			'BossName'      =>['BOSS_NAME','string'],
			'KindOplata'    =>'KIND_OPLATA',
			'EnableDiscont' =>'ENABLE_DISCONT'
		]
	];

	$tag = $tags[$name];
	foreach($tag as $k=>$v){
		
		if (is_array($v)){
			$name = $v[0];
			$type = $v[1];
		}else{
			$name = $v;
			$type = 'int';
		}

		if (property_exists($xml,$k)){
			$result['data'][]=[$name=>$xml->{$k}->__toString()];
			$result['types'][]=[$name=>$type];
		}
	}
	return $result;
}

$str = '
<Msg Kind="2" Action="3" Ver="1">
	<KlientName>"Планета"</KlientName>
	<BossPost><![CDATA[Генеральный директор]]></BossPost>
	<BossName>Иванов И.И.</BossName>
	<KindOplata>1</KindOplata>
	<DbNum>6</DbNum>
	<List>
		<Addr Id="9834" Txt="г.Тверь, ул. Набережная 25 к 4. тел 123-45-67 Олег"/>
		<Addr Id="9835" Txt="г.Тверь, ул. Набережная 25 к 4. тел 123-45-67 Олег"/>
		<Addr Id="9836" Txt="г.Тверь, ул. Набережная 25 к 4. тел 123-45-67 Олег"/>
	</List>
	<EnableDiscont>1</EnableDiscont>
	<ShowImmediatly>1</ShowImmediatly>
	<UserId>17</UserId>
</Msg>
';
try{
    $xml = @simplexml_load_string($str);
}catch(Exception $e){
    echo 'error';
}
//$res = tagToFields('addr_dost',$xml);
//var_dump($res);

$list = $xml->List->children();
for($i=0;$i<count($list);$i++){
	$item = $list[$i]->attributes();
	
	var_dump($item->Id);
}

/*
$oi = $xml->OrderInfo;
if (property_exists($oi,'MainZakazIda'))
	echo 'true';
else
	echo 'false';
*/

/*
var_dump($xml);

echo 'xml';
echo '<xmp>'.$str.'</xmp>';

echo '<xmp>';
print_r($xml);
echo '</xmp>';


echo 'count:'.$xml->count();
echo '"<xmp>';
if (isset($xml->OrderInfo))
    echo 'ok';
else    
    echo 'error';    
echo '</xmp>"';
*/


?>
