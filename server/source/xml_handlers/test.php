<?php
namespace exweb\source\xml_handlers;
use exweb\source\{Utils as UT};
require_once __DIR__.'/../../../../wsi/ide/ws/plugins/base/base.php';
require_once __DIR__.'/load.php';
require_once __DIR__.'/handlers.php';
require_once __DIR__.'../../Utils.php';

\base::connect('localhost','root','','_wd_test','deco');
\base::charSet('cp1251','deco');


$xmlString = '
<?xml version=”1.0” encoding =”unicode”?>
<Msg Kind="9" Action="1">
<Tables>
    <Table Name="NEWS" IdFieldName="ID_NEWS" Base="deco">git 
        <Row Id="15">
            <Field Name="msG"><![CDATA[Русские]]></Field>
        </Row>
        <Row Id="17">
            <Field Name="Msg"><![CDATA[qhwjejhqwjhwgjhwdjhwg ]]></Field>
        </Row>
    </Table>
    <Table Name="NEWS" IdFieldName="ID_NEWS" Base="deco">
        <Row Id="16">
            <Field Name="msG"><![CDATA[2l3k4oi3i23j4oij]]></Field>
            <Field Name="permissioN"><![CDATA[ [2,3,4] ]]></Field>
        </Row>
        <Row Id="18">
            <Field Name="Msg"><![CDATA[2i34i 2j34oijoi23j i 23oioi j34]]></Field>
        </Row>
    </Table>
    <Table Name="NEWS" IdFieldName="ID_NEWS">
        <Row Id="18" Type="delete"/>
    </Table>
</Tables>
</Msg>';

var_dump(\base::fieldsInfo('NEWS','types','deco'));
echo '<xmp>';



echo $xmlString;
$xml = UT::strToXml($xmlString);
echo "\n";
Handlers::run($xml);
echo '</xmp>';



?>