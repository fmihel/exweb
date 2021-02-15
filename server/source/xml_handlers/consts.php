<?php
namespace exweb\source\xml_handlers;

define('XML_INFO',[
    array('KIND'=>1,'ACTION'=>1,'NOTE'=>'Создание заказа'),
    array('KIND'=>1,'ACTION'=>2,'NOTE'=>'Информация о принятии заказа','REPLYID'=>array('1'=>'Успешно','2'=>'Дублирование','3'=>'Нет товаров','4'=>'Неизвестный отказ')),
    array('KIND'=>1,'ACTION'=>3,'NOTE'=>'Запрос состояния'),
    array('KIND'=>1,'ACTION'=>4,'NOTE'=>'Информация о состоянии',
    'STATE'=>array('Неопределено'
                    ,'Предварительно принят'
                    ,'Подтвержден'
                    ,'Просчитан'
                    ,'Товары заказа списаны'
                    ,'Принято в производство'
                    ,'Отгружен'
                    ,'Завершен'
                    ,'Не принят'
                    ,'пустое'
                    ,'Отменен'
                    ,'Отмена запрещена'
                    ,'Аннулирован')),
    array('KIND'=>1,'ACTION'=>5,'NOTE'=>'Запрос отмены'),
    array('KIND'=>1,'ACTION'=>6,'NOTE'=>'Результат отмены','REPLYID'=>array('-1'=>'Ошибка','1'=>'Отменен','2'=>'Запрет отмены')),
    array('KIND'=>2,'ACTION'=>1,'NOTE'=>'Передача настроек удаленного доступа'),
    array('KIND'=>2,'ACTION'=>2,'NOTE'=>'Запрос адресов доставки'),
    array('KIND'=>2,'ACTION'=>3,'NOTE'=>'Передача адресов доставки'),
    array('KIND'=>2,'ACTION'=>4,'NOTE'=>'Запрос на отправку клиенту данных авторизации в DecoR'),
    array('KIND'=>3,'ACTION'=>1,'NOTE'=>'Загрузка остатков в WEB'),
    array('KIND'=>3,'ACTION'=>2,'NOTE'=>'Запрос остатков'),
    array('KIND'=>3,'ACTION'=>3,'NOTE'=>'Передача остатков'),
    array('KIND'=>3,'ACTION'=>4,'NOTE'=>'Запрос остатков(ткани)'),
    array('KIND'=>3,'ACTION'=>5,'NOTE'=>'Передача остатков(ткани)'),
    array('KIND'=>3,'ACTION'=>6,'NOTE'=>'Запрос на цены'),
    array('KIND'=>3,'ACTION'=>7,'NOTE'=>'Передача цен'),
    array('KIND'=>3,'ACTION'=>8,'NOTE'=>'Запрос на катлоги'),
    array('KIND'=>3,'ACTION'=>9,'NOTE'=>'Передача каталогов'),
    
    array('KIND'=>4,'ACTION'=>0,'NOTE'=>'Сообщение об отказе'),
    array('KIND'=>5,'ACTION'=>1,'NOTE'=>'Запрос данных по дисконтной карте'),
    array('KIND'=>5,'ACTION'=>2,'NOTE'=>'Передача данных по дисконтной карте','REPLYID'=>array('0'=>'Успешно','1'=>'Не зарегистрирована')),
    array('KIND'=>5,'ACTION'=>3,'NOTE'=>'Запрос на регистрацию дисконтной карты','REPLYID'=>array('0'=>'Успешно','1'=>'Не зарегистрирована')),
    array('KIND'=>5,'ACTION'=>4,'NOTE'=>'Результаты регистрации дисконтной карты','REPLYID'=>array('0'=>'Успешно','1'=>'Дублирование')),
    array('KIND'=>5,'ACTION'=>5,'NOTE'=>'Передать изменения по дисконтным картам'),
    array('KIND'=>5,'ACTION'=>6,'NOTE'=>'Заказ в дисконтную карту'),
    array('KIND'=>6,'ACTION'=>1,'NOTE'=>'Запрос данных по клиентам'),
    array('KIND'=>6,'ACTION'=>2,'NOTE'=>'Передача данных по клиентам'),
    array('KIND'=>6,'ACTION'=>3,'NOTE'=>'Перенос пользователей от отдного клиента другому'),
    array('KIND'=>7,'ACTION'=>1,'NOTE'=>'Передача списка пользователей'),
    array('KIND'=>8,'ACTION'=>1,'NOTE'=>'Передача информации по рулонам'),
    array('KIND'=>9,'ACTION'=>1,'NOTE'=>'Модификация таблиц'),

]);

define('KIND_ORDER',1);
define('KIND_CLIENT',2);
define('KIND_OST',3);
define('KIND_DISCONT',5);
define('KIND_OST_TKANI',8);

define('ACT_ORDER_SEND',1);
define('ACT_ORDER_ACCEPT',2);
define('ACT_ORDER_GET_STATE',3);
define('ACT_ORDER_STATE',4);
define('ACT_ORDER_CANCEL',5);
define('ACT_ORDER_CANCEL_RESULT',6);

define('ACT_CLIENT_DATA',1);
define('ACT_CLIENT_GET_ADDR_DOST',2);
define('ACT_CLIENT_ADDR_DOST',3);


define('ACT_OST_SEND_OST',1);
define('ACT_OST_GET_OST',2);
define('ACT_OST_OST',3);

define('ACT_DISCONT_INFO_RECV',1);
define('ACT_DISCONT_INFO_SEND',2);
define('ACT_DISCONT_CHANGE',5);
define('ACT_DISCONT_REGISTERED',3);
define('ACT_DISCONT_ORDER_TO_CARD',6);

define('DELIVERY_NULL_DATE_IN_SELECT','30.12.1990');
define('DELIVERY_NULL_DATE_TO_UPDATE','1990-12-30'); // update FDATA =  DATE_FORMAT('1990-12-30','%Y-%m-%d');

define('ORDER_STATE_STR',[
    'Формируется',              //0
    'Отправлен',                //1
    'Предварительно принят',    //2
    'Подтвержден',              //3
    'Просчитан',                //4
    'Товары заказа списаны',    //5
    'Принято в производство',   //6
    'Отгружен',                 //7
    'Завершен',                 //8
    'Не принят',                //9
    'не используется',          //10
    'Отменен',                  //11
    'Отмена запрещена',         //12
    'Аннулирован'               //13
]);

define('OS_FORMIRUETSY',0);
define('OS_OTPRAVLEN',1);
define('OS_PREDVARITELNO_PRINYT',2);
define('OS_PODTVERJDEN',3);
define('OS_PROSCHITAN',4);
define('OS_TOVARI_SPISANI',5);
define('OS_PRINYTO_V_PROIZVODSTVO',6);
define('OS_OTGRUJEN',7);
define('OS_ZAVERSHEN',8);
define('OS_NE_PRINYT',9);
define('OS_OTMENEN',11);
define('OS_OTMENA_ZAPRESHENA',12);
define('OS_ANNULIROVAN',13);

    

?>