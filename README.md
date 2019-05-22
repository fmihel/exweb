# exweb
Набор клиент-серверных библиотек для обмена между Apache(PHP) и Win (Delphi).


### Пример использования на Delphi
#### upload
```
Uses UExWebType,UExWeb;
...

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

#### upload
```
Uses UExWebType,UExWeb;
...

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

#Принцип работы протокола
Протокол exweb предназначен для передачи и приема сообщений между клиентом windows и сервером Apache.
Основной здачей протокола является наличие достоверной информации о факте приема противоположной стороной информации.

# Описание состояний

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



