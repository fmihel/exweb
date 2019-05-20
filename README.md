# exweb
Набор клиент-серверных библиотек для обмена между Apache(PHP) и Win (Delphi).

### Пример использования на Delphi

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
            ShowMessage('send: Ok');
    finally
        cData.Free;
        exweb.Free;
    end;

end;

```

## Алгоритм передачи
### Список состояний

|server|client|notes|
|------|------|-----|
|init               |send_init          |начало обмена, создание строки в rest_api, возвращает id и block_size, block_len|
|send_string        |send_string        |отправка части строки|
|encode             |send_encode        |окончание передачи строки и декодрование|
|block_init         |send_block_init    |начало передачи бинарных данных|
|                   |send_block         |передача блока бинарных данных <=block_size|
|                   |hash_sum_compare   |завершение передачи и проверка целостности данных(сравнение хеш сумм)|
|ready              |send_ready         |завершение передачи (после этого, клиент может считывать данные)|
|completed          |                   |выставляется клиентом после успешной обработки|
|error              |                   |выставляется клиентом после ошибочной обработки|



