# exweb
Клиент-серверная библиотека для обмена между Apache и Windows, реализованная на PHP7 и Delphi

## Пример использования exweb.dll
Кроме непосредственно библиотеки `exweb.dll`, для работы необходимы библиотеки работы с ssl - `libey32.dll`, `ssleay32.dll`.
Для использования необходимо подключить к проекту файлы: `UExWebType.pas`, `exweb_import.pas`, `exweb_type.pas`;
```
Uses  UExWebType, exweb_import, exweb_type ;
```

**1. создание и подключение**
```
var exweb:TExweb_import;
....
exweb := TExweb_import.create();
if not exweb.Connect('exweb.dll') then
  ShowMessage('connect error');
```
**2. установка адреса скрипта**
```
exweb.setParam('url','http://site/exweb/');
```
**3. установка ключа авторизации**
```
exweb.setParam('key','xxxxxxxxx');
```
**4. отправка сообщения**
```
var state:TExWebState;
     xml:string;
...

xml:='<?xml version="1.0" encoding="unicode"?><Msg><Name>Mike</Name><Msg>';

state:=exweb.send(xml,nil,state);
if (not state.result) then
  ShowMessage('error send');
```
**5. отправка сообщения и бинарных данных**
```
var state:TExWebState;
     data:TMemoryStream;
     xml:string;
...
data:=TMemoryStream.Create();
data.LoadFromFile('file.jpg');
xml:='<?xml version="1.0" encoding="unicode"?><Msg><Name>Mike</Name><Msg>';

state:=exweb.send(xml,data,state);
if (not state.result) then
  ShowMessage('error send');
  
data.free;  
```
**6. прием сообщения**
```
var state:TExWebState;
     data:TMemoryStream;
     str:string;
...
data:=TMemoryStream.Create();

state:=exweb.recv(str,data,state);
if (not state.result) then
  ShowMessage('error recv');
  
data.free();  
```
**7. выполнение запросов к базе**
```
var cds:TClientDataSet;
...

if ( exweb.query('select * from rest_api','exweb',cds) ) then
    cds.Active:=true;

```
**8. завершение работы**
```
exweb.free();
```
---

## API documentation ***TExWeb_import***
### Functions

|name|notes|
|-----|-----|
|***Create***(aDllFileName:string = '')|Конструктор <br> aDllFileName - путь к библиотеке exweb.dll|
|***Destroy***()|Деструктор|
|***Connect***(const aDllFileName: string): Boolean|Загрузка библиотеки<br> aDllFileName - путь к библиотеке exweb.dll|
|***Disconnect***()|Отключение библиотеки|
|***reConnect***():Boolean|Полное переподключение библиотеки|
|***send***(const str: string; data: TStream; prevState:TExWebState): TExWebState|Отправка данных на сервер<br>str - строка(xml)<br>data - бинарный поток данных<br> prevState - предыдущее состояние|
|***recv***(var str: string; data: TStream; prevState:TExWebState): TExWebState|Прием данных с сервера<br>str - строка(xml)<br>data - бинарный поток данных<br> prevState - предыдущее состояние|
|***getParam***(name:string):string|Получить параметры exweb<br> name - имя параметра|
|***setParam***(name:string;value:string)|установка параметра exweb<br>name - имя параметра<br>value - значение<br><br> ***Доступны следующие параметры***<br> *Script* - адрес скрипта<br>*Key* - ключ авторизации<br>*ProxyPassword* - пароль прокси<br>*ProxyPort* - порт прокси<br>*ProxyServer* - адрес сервера прокси<br>*ProxyUserName* - имя пользователя прокси<br>*MaxDataSetFiedLen* -  Максимальная длина загружаемого поля<br>*EnableLog* - включение вывода  в лог<br>*LogFileName* - путь к log файлу |
|***query***(const sql, base: string; outDS: TClientDataSet; const coding: string = ''): Boolean|выполнение запроса к базе<br>sql - запрос ( не только select )<br>base - алиас базы к которой выполняется запрос<br>outDS - ClientDataSet - с результатом запроса ( или nil)<br>coding - кодировка результат|

### Propertyes

|name|notes|
|-----|-----|
|***Connected***: Boolean|Признак того, что библиотека подключена|
---

## Техническое описание
### Принцип работы протокола
Протокол exweb предназначен для передачи и приема сообщений между клиентом windows и сервером Apache.
Основной здачей протокола является наличие достоверной информации о факте приема противоположной стороной информации.
Передача осуществляется в несколько этапов, важно, что последующий этап не начинается, если не закончен другой, в случае
если этап не завершен передача считается "не пройденной". Однако после успешного этапа send_block, передача принимается,
и если последующий этап (ready) не проходит, то этап ready повотряем на следующей передаче. Для этого клиент должен 
хранить предыдущее состояние send/recv и передавать его на следующую передачу.

# Состояния передачи

|server|client|notes|
|------|------|-----|
|init_send          |init_send          |начало обмена, создание строки в rest_api, возвращает id и block_size, block_len|
|send_string        |send_string        |отправка части строки|
|send_string_encode |send_string_encode |окончание передачи строки и декодрование|
|send_init_block    |send_init_block    |начало передачи бинарных данных|
|send_block         |send_block         |передача блока бинарных данных <=block_size|
|                   |hash_sum_compare   |завершение передачи и проверка целостности данных(сравнение хеш сумм)|
|                   |recv_get_id        |Получить id исходящего с сервера сообщения|
|                   |recv_string        |Запрос исходящей с сервера строки|
|                   |recv_block         |Запрос исходящего с сервера блока|
|ready              |ready              |завершение передачи (после этого, клиент может считывать данные)|
|completed          |completed          |обработка сообщения завершена, сообщение можно удалять|
|error              |                   |выставляется клиентом после ошибочной обработки|



