<?php
namespace exweb\source\xml_handlers;
use exweb\source\{Utils as UT};
require_once __DIR__.'/../../../../wsi/ide/ws/plugins/base/base.php';
require_once __DIR__.'/load.php';
require_once __DIR__.'/handlers.php';
require_once __DIR__.'../../Utils.php';

\base::connect('localhost','root','','_wd_test','deco');
\base::charSet('cp1251','deco');

/*
$xmlString = '
<?xml version=”1.0” encoding =”unicode”?>
<Msg Kind="2" Action="1">
    <IdKlient>999999</IdKlient>
    <KlientInfo>
        <AdresatKind>3</AdresatKind>
        <KlientName><![CDATA[Menegers]]></KlientName>
        <EMail>fmihel76@gmail.com</EMail>
        <RemoteAccess>1</RemoteAccess>
        <DecoRMail>fmihel76@gmail.com</DecoRMail>
        <Arch>0</Arch>
    </KlientInfo>
</Msg>';
*/

$xmlString = '
<?xml version=”1.0” encoding =”unicode”?>
<Msg Kind="9" Action="1">
<Tables>
    <Table Name="DE_RIGHT">
        <Row Id="1">
            <Field Name="CAPTION"><![CDATA[Описание]]></Field>
        </Row>
        <Row Id="2">
            <Field Name="CAPTION"><![CDATA[Изображение]]></Field>
        </Row>
        <Row Id="3">
            <Field Name="CAPTION"><![CDATA[Прайс]]></Field>
        </Row>
        <Row Id="4">
            <Field Name="CAPTION"><![CDATA[Заказ]]></Field>
        </Row>
        <Row Id="5">
            <Field Name="CAPTION"><![CDATA[Цены]]></Field>
        </Row>
    </Table>
    <Table Name="DE_USER">
        <Row Id="4">
            <Field Name="FIO">Morra</Field>
            <Field Name="LOGIN">Morra</Field>
            <Field Name="PWD">Morra1</Field>
        </Row>

    </Table>

</Tables>
</Msg>';
echo '<xmp>';


echo $xmlString;
$xml = UT::strToXml($xmlString);
echo "\n";
echo '</xmp>';

Handlers::run($xml);



?>