unit UHref;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs;

type
    THrefParam = class(TObject)
    public
        name: string;
        value: string;
    end;

    THref = class(TObject)
    private
        fList: TList;
        function getCount: Integer;
        function getGet(name:string): THrefParam;
        function getItem(Index: Integer): THrefParam;
        procedure setGet(name:string; Value: THrefParam);
    public
        constructor Create;
        destructor Destroy; override;
        function Add(const name, value: string): THrefParam; overload;
        function Add(param: THrefParam): THrefParam; overload;
        procedure Clear;
        procedure Delete(aIndex: Integer = -1);
        function Exists(param: THrefParam): Boolean;
        function IndexOf(aObject: THrefParam): Integer;
        procedure Remove(aObject:THrefParam);
        property Count: Integer read getCount;
        property Get[name:string]: THrefParam read getGet write setGet; default;
        property Item[Index: Integer]: THrefParam read getItem;
    end;


implementation

{
************************************ THref *************************************
}
constructor THref.Create;
begin
    fList :=TList.Create;
end;

destructor THref.Destroy;
begin
    Clear();
    fList.Free();
end;

function THref.Add(const name, value: string): THrefParam;
begin
    result:= THrefParam.create();
    try try
        result.name := name;
        result.value := value;
        result := self.Add(result);
    except on e:Exception do
    begin
        result
    end;
    end;
    finally

    end;
end;

function THref.Add(param: THrefParam): THrefParam;
begin
    try
            result:=param;
            fList.Add(result);
    except
            result:=nil;
    end;
end;

procedure THref.Clear;
begin
    Delete(-1);
end;

procedure THref.Delete(aIndex: Integer = -1);
var
    obj: THrefParam;
begin
    if aIndex = -1 then
    begin
        while fList .Count>0 do
        begin
            obj:=THrefParam(fList.Items[fList.Count-1]);
            obj.Free;
            fList.Delete(fList.Count -1);
        end
    end
    else begin
        obj:=THrefParam(fList.Items[aIndex]);
        obj.Free;
        fList.Delete(aIndex);
    end;
end;

function THref.Exists(param: THrefParam): Boolean;
begin
    result:=(IndexOf(param)<>-1);
end;

function THref.getCount: Integer;
begin
    result:=fList .Count;
end;

function THref.getGet(name:string): THrefParam;
begin
end;

function THref.getItem(Index: Integer): THrefParam;
begin
    result:=THrefParam(fList.Items[Index]);
end;

function THref.IndexOf(aObject: THrefParam): Integer;
begin
    result:=fList.IndexOf(aObject);
end;

procedure THref.Remove(aObject:THrefParam);
begin
    fList .Remove(aObject);
end;

procedure THref.setGet(name:string; Value: THrefParam);
begin
end;



end.
