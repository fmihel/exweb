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
