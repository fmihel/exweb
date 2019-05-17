unit UHash;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  Variants,UlkJSON;

type
    {
        hjprErrorParsing - ошибка парсинга json. json - не валидный
        hjprErrorCreate  - ошибка создания узла при разборе ( возможно проблемы
                           с преобразованием типа
                           cJson:=aChild as TlkJSONobject;)
    }
    THashJsonResult = (hjprOk,hjprErrorParsing,hjprErrorCreate);


    THash  = class;
    THashParam = class(TObject)
    public
        hash: THash;
        name: string;
        value: string;
        constructor Create;
        destructor Destroy; override;
        procedure assign(from: THashParam);
        procedure union(source: THashParam);
    end;

    THash = class(TObject)
    private
        fList: TList;
        function getCount: Integer;
        function getFloat(NameOrIndex:Variant): Double;
        function getHash(name:string): THash;
        function getInt(NameOrIndex:Variant): Integer;
        function getItem(NameOrIndex: Variant): THashParam;
        function getName(Index: Integer): string;
        function getValue(NameOrIndex:Variant): string;
        function getValueVariant(NameOrIndex:Variant): Variant;
        procedure setFloat(NameOrIndex:Variant; const NewValue: Double);
        procedure setInt(NameOrIndex:Variant; const NewValue: Integer);
        procedure setName(Index: Integer; const NewValue: string);
        procedure setValue(NameOrIndex:Variant; const Value: string);
        procedure setValueVariant(NameOrIndex:Variant; const Value: Variant);
        function _toJSON(cr: string = ''): string;
    public
        constructor Create;
        destructor Destroy; override;
        procedure add(NameValue: array of variant); overload;
        function add(aObject: THashParam = nil): THashParam; overload;
        procedure assign(from: THash);
        function asString(cr: string = #13#10; space: string = ' '; level:
            Integer = 0): string;
        procedure clear;
        procedure delete(aIndex: Integer = -1); overload;
        procedure delete(const name: string); overload;
        function exists(const Name: string): Boolean; overload;
        function exists(aObject: THashParam): Boolean; overload;
        function fromJSON(aStr: string; enCodeRus: Boolean = true):
            THashJsonResult;
        function indexOf(aObject: THashParam): Integer;
        function nameToIndex(const name: string): Integer;
        procedure remove(aObject:THashParam);
        function toJSON(const cr: string = ''; codeRus: Boolean = true): string;
        procedure union(source: THash);
        function _fromJSON(aChild: TlkJSONbase; aParent: THash; enCodeRus:
            Boolean = true): THashJsonResult;
        property Count: Integer read getCount;
        property Float[NameOrIndex:Variant]: Double read getFloat write
            setFloat;
        property Hash[name:string]: THash read getHash;
        property Int[NameOrIndex:Variant]: Integer read getInt write setInt;
        property Item[NameOrIndex: Variant]: THashParam read getItem;
        property Name[Index: Integer]: string read getName write setName;
        property Value[NameOrIndex:Variant]: string read getValue write
            setValue; default;
        property ValueVariant[NameOrIndex:Variant]: Variant read
            getValueVariant write setValueVariant;
    end;

function Hash(NameValue: array of variant): THash;overload;
procedure FreeHash(var aHash: THash);

function Hash: THash; overload;

implementation
uses UUtils;

function Hash(NameValue: array of variant): THash;
begin
    result:=THash.create;
    result.add(NameValue);
end;
procedure FreeHash(var aHash: THash);
begin
    if (aHash<>nil) then
        aHash.Free();
    aHash:=nil;
end;

function Hash: THash;
begin
    Result := Hash([]);
end;

{
********************************** THashParam **********************************
}
constructor THashParam.Create;
begin
    inherited Create;
    hash:=THash.Create();
end;

destructor THashParam.Destroy;
begin
    hash.Free();
    inherited Destroy;
end;

procedure THashParam.assign(from: THashParam);
begin
    name    :=from.name;
    value   :=from.value;
    hash.assign(from.hash);
end;

procedure THashParam.union(source: THashParam);
begin
    value   :=source.value;
    if (source.hash.count>0) then
        hash.union(source.hash)
    else
        hash.clear();
end;

{
************************************ THash *************************************
}
constructor THash.Create;
begin
    fList:=TList.Create;
end;

destructor THash.Destroy;
begin
    Clear;
    fList.Free;
    inherited Destroy;
end;

procedure THash.add(NameValue: array of variant);
var
    i: Integer;
begin
    for i:= 0 to (Length(NameValue) div 2-1) do
        Value[NameValue[i*2]]:=NameValue[i*2+1];
end;

function THash.add(aObject: THashParam = nil): THashParam;
begin
    try
        if (aObject = nil) then
            aObject:=THashParam.Create();

        result:=aObject;
        fList .Add(result);
    except
        result:=nil;
    end;
end;

procedure THash.assign(from: THash);
var
    i: Integer;
begin
    clear();
    for i:=0 to from.Count-1 do
        add().assign(from.Item[i]);
end;

function THash.asString(cr: string = #13#10; space: string = ' '; level:
    Integer = 0): string;
var
    item: THashParam;
    i: Integer;
    otstup: string;
begin
    result:='';

    otstup:='';
    for i:=0 to level do
        otstup:=otstup+space;

    for i:=0 to Count-1 do begin
        item:=self.Item[i];
        if (item.hash.count = 0) then
            result:=result + otstup+item.name+' = "'+item.value+'" '+cr
        else begin
            result:= result + otstup+item.name+' = ['+cr+item.hash.asString(cr,space,level+1)+'] '+cr;
        end;
    end;
end;

procedure THash.clear;
begin
    Delete(-1);
end;

procedure THash.delete(aIndex: Integer = -1);
var
    obj: THashParam;
begin
    if aIndex = -1 then
    begin
        while fList.Count>0 do
        begin
            obj:=THashParam(fList.Items[fList.Count-1]);
            obj.Free;
            fList.Delete(fList.Count-1);
        end
    end
    else
    begin
        obj:=THashParam(fList.Items[aIndex]);
        obj.Free;
        fList.Delete(aIndex);
    end;
end;

procedure THash.delete(const name: string);
var
    index: Integer;
begin
    index:=nameToIndex(name);
    if (index<>-1) then
        delete(index);
end;

function THash.exists(const Name: string): Boolean;
begin
    result:=(nameToIndex(Name)<>-1);
end;

function THash.exists(aObject: THashParam): Boolean;
begin
    result:=(IndexOf(aObject)<>-1);
end;

function THash.fromJSON(aStr: string; enCodeRus: Boolean = true):
    THashJsonResult;
var
    cJson: TlkJSONobject;
    cChild: TlkJSONbase;
    cName: string;
    cValue: string;
    i: Integer;
begin
    result:=hjprOk;
    clear();
    if (enCodeRus) then
        aStr:=Utils.rusCod(aStr);

    try
        cJson := TlkJSON.ParseText(aStr) as TlkJSONobject;
        if (cJson=nil) then
            raise Exception.Create('');

        try
        try
            for i:=0 to cJson.Count-1 do begin
                cName:=cJson.NameOf[i];
                cChild:=cJson.FieldByIndex[i];
                if (cChild.Count = 0) then begin
                    cValue:=varToStr(cJson.Field[cName].Value);

                    if (enCodeRus) then
                        cValue:=Utils.rusEnCod(cValue);

                    Value[cName]:=cValue;

                end else begin
                    result:=_fromJSON(cChild,Hash[cName],enCodeRus);
                    if (result<>hjprOk) then
                        raise Exception.Create('');
                end;
            end;
        except
        on e:Exception do begin
            result:=hjprErrorCreate;
        end;
        end;
        finally
            cJson.Free();
        end;
    except on e:Exception do begin
        result:=hjprErrorParsing;
    end;



    end;
end;

function THash.getCount: Integer;
begin
    result:=fList.Count;
end;

function THash.getFloat(NameOrIndex:Variant): Double;
begin
    result:=Utils.StrToFloat(Value[NameOrIndex]);
end;

function THash.getHash(name:string): THash;
var
    index: Integer;
    new: THashParam;
begin
    index := nameToIndex(name);

    if (index<>-1) then begin
        result:= Item[index].hash;
    end else begin
        new := add();
        new.name := name;
        result := new.hash;
    end;
end;

function THash.getInt(NameOrIndex:Variant): Integer;
begin
    result:=StrToInt(Value[NameOrIndex]);
end;

function THash.getItem(NameOrIndex: Variant): THashParam;
var
    vt: TVarType;
    index: Integer;
begin
    vt := VarType(NameOrIndex);
    if ( (vt = varString) or (vt = varUString) ) then
        index := nameToIndex(NameOrIndex)
    else
        index:=NameOrIndex;

    if (index>=0) then
        result:=THashParam(fList.Items[index])
    else
        result:=nil;
end;

function THash.getName(Index: Integer): string;
begin
    result:=Item[Index].name;
end;

function THash.getValue(NameOrIndex:Variant): string;
var
    index: Integer;
    item: THashParam;
    vt: TVarType;
begin
    vt := VarType(NameOrIndex);
    if ( (vt = varString) or (vt = varUString) ) then
        index := nameToIndex(NameOrIndex)
    else
        index:=NameOrIndex;

    if (index<>-1) then begin
        item:= self.Item[index];

        if (item.hash.count>0) then
            raise Exception.Create('["'+NameOrIndex+'"] is hash array, use .Hash["'+NameOrIndex+'"] property for use.')
        else
            result:= item.value;

    end else
        result:= '';
end;

function THash.getValueVariant(NameOrIndex:Variant): Variant;
var
    index: Integer;
    item: THashParam;
    vt: TVarType;
begin
    vt := VarType(NameOrIndex);
    if ( (vt = varString) or (vt = varUString) ) then
        index := nameToIndex(NameOrIndex)
    else
        index:=NameOrIndex;

    if (index<>-1) then begin
        item:= self.Item[index];

        if (item.hash.count>0) then
            raise Exception.Create('["'+NameOrIndex+'"] is hash array, use .Hash["'+NameOrIndex+'"] property for use.')
        else begin
            result:= item.value;
        end;

    end else
        result:= '';
end;

function THash.indexOf(aObject: THashParam): Integer;
begin
    result:=fList.IndexOf(aObject);
end;

function THash.nameToIndex(const name: string): Integer;
var
    i: Integer;
    param: THashParam;
begin
    result:=-1;
    for i:=0 to Count-1 do begin
        param:=Item[i];
        if (param.name = name) then begin
            result:= i;
            break;
        end;
    end;
end;

procedure THash.remove(aObject:THashParam);
begin
    fList.Remove(aObject);
end;

procedure THash.setFloat(NameOrIndex:Variant; const NewValue: Double);
begin
    Value[NameOrIndex]:=Utils.FloatToStr(NewValue);
end;

procedure THash.setInt(NameOrIndex:Variant; const NewValue: Integer);
begin
    Value[NameOrIndex]:=IntToStr(NewValue);
end;

procedure THash.setName(Index: Integer; const NewValue: string);
begin
    Item[Index].name := NewValue;
end;

procedure THash.setValue(NameOrIndex:Variant; const Value: string);
var
    index: Integer;
    new: THashParam;
    item: THashParam;
    vt: TVarType;
begin
    vt := VarType(NameOrIndex);
    if ( (vt = varString) or (vt = varUString) ) then
        index := nameToIndex(NameOrIndex)
    else
        index:=NameOrIndex;

    if (index<>-1) then begin

        item:=self.Item[index];
        item.value := Value;
        item.hash.clear();

    end else begin
        new := add();
        new.value := Value;
        new.name  := NameOrIndex;
    end;
end;

procedure THash.setValueVariant(NameOrIndex:Variant; const Value: Variant);
var
    index: Integer;
    new: THashParam;
    item: THashParam;
    indexType: TVarType;
    valueType: TVarType;
    cValue: string;
begin
    indexType := VarType(NameOrIndex);
    valueType := VarType(Value);
    cValue:='';
    case valueType of
    varString,varUString:
        cValue:=varToStr(Value);
    varSmallint,varInteger,varShortInt,varByte,varInt64,varUInt64:
        cValue:=varToStr(Value);
    varSingle,varDouble,varCurrency:
        cValue:=varToStr(Value);
    end;



    if ( (indexType = varString) or (indexType = varUString) ) then
        index := nameToIndex(NameOrIndex)
    else
        index:=NameOrIndex;


    if (index<>-1) then begin

        item:=self.Item[index];
        item.value := Value;
        item.hash.clear();

    end else begin
        new := add();
        new.value := Value;
        new.name  := NameOrIndex;
    end;
end;

function THash.toJSON(const cr: string = ''; codeRus: Boolean = true): string;
begin
    result:=_toJSON(cr);
    if (codeRus) then
        result:=Utils.rusCod(result);

end;

procedure THash.union(source: THash);
var
    i: Integer;
    name: string;
    param: THashParam;
begin
    for i:=0 to source.Count-1 do begin
        name:=source.Name[i];
        param:=Item[name];

        if (param = nil) then begin
            param      := add();
            param.name := name;
        end;
        param.union(source.Item[i]);
    end;
end;

function THash._fromJSON(aChild: TlkJSONbase; aParent: THash; enCodeRus:
    Boolean = true): THashJsonResult;
var
    i: Integer;
    cChild: TlkJSONbase;
    cJson: TlkJSONobject;
    cList: TlkJSONlist;
    cName: string;
    cValue: string;
begin
    result:=hjprErrorCreate;
    if (aChild.SelfType = jsList) then begin
        cList:=aChild as TlkJSONlist;
        try
            for i:=0 to cList.Count-1 do begin
                cName:=IntToStr(i);
                cChild:=cList.Child[i];
                if (cChild.Count = 0) then begin
                    cValue:=VarToStr(cChild.Value);
                    if (enCodeRus) then
                        cValue:=Utils.rusEnCod(cValue);
                    aParent[cName]:=cValue;

                end else begin
                    result:=_fromJSON(cChild,aParent.Hash[cName],enCodeRus);
                    if (result<>hjprOk) then
                        raise Exception.Create('');
                end;
            end;
            result:=hjprOk;
        except on e:Exception do
        end;
    end else begin
        cJson:=aChild as TlkJSONobject;
        try
            for i:=0 to cJson.Count-1 do begin
                cName:=cJson.NameOf[i];
                cChild:=cJson.FieldByIndex[i];
                if (cChild.Count = 0) then begin

                    cValue:=varToStr(cJson.Field[cName].Value);
                    if (enCodeRus) then
                        cValue:=Utils.rusEnCod(cValue);
                    aParent[cName]:=cValue;

                end else begin
                    result:=_fromJSON(cChild,aParent.Hash[cName],enCodeRus);
                    if (result<>hjprOk) then
                        raise Exception.Create('');
                end;
            end;
            result:=hjprOk;
        except on e:Exception do
        end;
    end;
end;

function THash._toJSON(cr: string = ''): string;
var
    i: Integer;
    isArray: Boolean;
    obj: THashParam;
begin
    isArray:=true;
    result:='';

    for i:=0 to Count-1 do begin
        if (IntToStr(i)<>Name[i]) then begin
            isArray:=false;
            break;
        end;
    end;

    for i:=0 to Count-1 do begin
        obj := Item[i];
        if (i<>0) then
            result:=result+','+cr;
        if (obj.hash.Count = 0) then begin
            if (not isArray) then
                result:=result+'"'+obj.name+'":';
                if ( Utils.isNumeric(obj.Value) ) then
                    result:=result+Value[i]
                else
                    result:=result+'"'+Value[i]+'"';
        end else begin
            result:=result+'"'+obj.name+'":'+cr+obj.hash.toJSON(cr);
        end;
    end;
    if (isArray) then
        result:='['+cr+result+cr+']'+cr
    else
        result:='{'+cr+result+cr+'}'+cr;
end;



end.
