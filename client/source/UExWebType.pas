unit UExWebType;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs;

type
    TExWebResult = (ewrOk,ewrUnknownError,ewrNoResponse,ewrNoValidJSON,ewrErrorCreateHash,ewrRes0,ewrNeedConfirm,ewrHashSumNotCompare,ewrErrorPrepare);
    TExWebState = record
    public
        //1 ������������� ���������
        id: string[16];
        //1 ��������� ��������
        webResult: TExWebResult;
        result: Boolean;
    end;

const
    TExWebResultStr:array[0..8] of string = ('ewrOk','ewrUnknownError','ewrNoResponse','ewrNoValidJSON','ewrErrorCreateHash','ewrRes0','ewrNeedConfirm','ewrHashSumNotCompare','ewrErrorPrepare');
    TExWebResultNotes:array[0..8] of string = (
        'Ok',
        '����������� ������',
        '��� ������ (�������� ��� ���������)',
        '��������� JSON �� ��������',
        '������ �������� HASH',
        '������ ��������� ������ � �������',
        '��������� ������������� ��������',
        '�������� ������, ����������� �� ������� �� ��������� � �������������',
        '������ �������� ������������ �������'
    );

implementation



end.
