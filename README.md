# exweb
Клиент-серверная библиотека для обмена между Apache и Windows, реализованная на PHP7 и Delphi

## Пример использования exweb.dll
Кроме непосредственно библиотеки exweb.dll, для работы необходимы библиотеки работы с ssl - libey32.dll, ssleay32.dll.
Для использования необходимо подключить к проекту файлы: `UExWebType.pas`, `exweb_import.pas`, `exweb_type.pas`;
```
Uses  UExWebType, exweb_import, exweb_type ;

```
----
**1) создание и подключение**
```
var exweb:TExweb_import;
....
exweb := TExweb_import.create();
if not exweb.Connect('exweb.dll') then
  ShowMessage('connect error');
  
```
----
**2) установка адреса скрипта**
```
exweb.setParam('url','http://site/exweb/');
```
----
**3) установка ключа авторизации**
```
exweb.setParam('url','http://site/exweb/');
```
----
**4) отправка сообщения**
```
var state:TExWebState;
     data:TMemoryStream;
...
data:=TMemoryStream.Create();

state:=exweb.send('message',data,state);
if (not state.result) then
  ShowMessage('error send');
  
data.free;  
```
----
**5) прием сообщения**
```
var state:TExWebState;
     data:TMemoryStream;
     str:string;
...
data:=TMemoryStream.Create();

state:=exweb.recv(str,data,state);
if (not state.result) then
  ShowMessage('error send');
  
data.free();  
```
----
**6) завершение работы**
```
exweb.free();
```
---

## Пример использования протокола на Delphi без exweb.dll 
---
### Отправка сообщения
```
Uses UExWebType,UExWeb;

var
    exweb:TExWeb;
    ExWebState:TExWebState;
    cData:TMemoryStream;
begin

    exweb:=TExWeb.Create('https://site/exweb/server/');
    cData:=TMemoryStream.Create;

    try
        cData.LoadFromFile('c://file.jpg');

        ExWebState:=exweb.send('My string for send...',cData,ExWebState);
        if (ExWebState.result) then
            ShowMessage('send: Ok');
        else
            ShowMessage('send: Error');
    finally
        cData.Free;
        exweb.Free;
    end;

end;

```
---
### Прием сообщения
```
Uses UExWebType,UExWeb;

var
    exweb:TExWeb;
    ExWebState:TExWebState;
    cData:TMemoryStream;
    cStr:string;
begin

    exweb:=TExWeb.Create('https://site/exweb/server/');
    cData:=TMemoryStream.Create;

    try

        ExWebState:=exweb.recv(cStr,cData,ExWebState);
        if (ExWebState.result) then begin
            cData.SaveToFile('c://file.jpg');
            ShowMessage(cStr);
        end else
            ShowMessage('recv: Error');
    finally
        cData.Free;
        exweb.Free;
    end;

end;

```
---

# Техническое описание
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



