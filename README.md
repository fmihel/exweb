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
|init|init| начало обмена, создание строки в rest_api, возвращает id и block_size, block_len|
|send_string|send_string|отправка части строки|
|encode_string|encode_string| окончание передачи строки и декодрование|
|open|open|начало передачи бинарных данных|
||block|передача блока бинарных данных <=block_size|
||hash_sum_compare|завершение передачи и проверка целостности данных(сравнение хеш сумм)|
|ready|close| завершение передачи (после этого, клиент может считывать данные)|
|completed||выставляется клиентом после успешной обработки|
|error||выставляется клиентом после ошибочной обработки|



