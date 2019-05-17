unit UExWebType;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs;

type
    TExWebResult = (ewrOk,ewrUnknownError,ewrNoResponse,ewrNoValidJSON,ewrErrorCreateHash,ewrRes0,ewrNeedConfirm,ewrHashSumNotCompare);
    TExWebState = record
    public
        //1 идентификатор сообщения
        id: string;
        //1 Результат операции
        webResult: TExWebResult;
        result: Boolean;
    end;

const
    TExWebResultStr:array[0..7] of string = ('ewrOk','ewrUnknownError','ewrNoResponse','ewrNoValidJSON','ewrErrorCreateHash','ewrRes0','ewrNeedConfirm','ewrHashSumNotCompare');
    TExWebResultNotes:array[0..7] of string = (
        'Ok',
        'Неизвестная ошибка',
        'Нет ответа (возможно нет интернета)',
        'Считанный JSON не валидный',
        'Ошибка создания HASH',
        'Сервер обработал запрос с ошибкой',
        'Требуется подтверждение закрытия',
        'Бинарные данные, сохраненные на сервере не совпадают с отправленными'
    );

implementation



end.
