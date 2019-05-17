{:
UUrl
Модуль cодержить методы для работы со строкой запроса.
}
unit UUrl;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  UHash;

type
    Url = class(TObject)
    public
        class function build(const aURL: string; aNameValueParams: array of
            variant; unionParams: Boolean = false; enc: Boolean = false;
            noCache: boolean = true): string; overload; static;
        //1 Строим строку запроса из входного hash
        class function build(const cHash: THash; enc: Boolean = false; noCache:
            boolean = true): string; overload; static;
        class function build(const cHash: THash; const cNameValueParams: array
            of variant; unionParams: Boolean = false; enc: Boolean = false;
            noCache: boolean = true): string; overload; static;
        class function build(cHash, cParams: THash; unionParams: Boolean =
            false; enc: Boolean = false; noCache: boolean = true): string;
            overload; static;
        //1 Парсинг строки параметров
        class function params(params: string; toHash: THash = nil; dec: Boolean
            = false): THash; static;
        {:
        Парсинг строки url.
        Возвращает hash след струкутуры;
        hash['uri'] - входная строка
        hash['addr'] - строка без параметров
        hash['protocol'] - тип протокола http или https
        hash['path'] - путь
        hash['hpath'] - путь с протоколом и доменом
        hash['document'] - имя конечного файл скрипта
        hash['param'] - строка параметров
        hash.hash['params'] -  hash параметров

        Examples:
        uri = "https://www.windeco.su/dev/test/index.php?h=10&t=89"
        addr = "https://www.windeco.su/dev/test/index.php"
        protocol = "https"
        host = "www.windeco.su"
        path = "/dev/test/"
        hpath = "https://www.windeco.su/dev/test/"
        document = "index.php"
        param = "h=10&t=89"
        params = [
        h = "10"
        t = "89"
        ]
        }
        class function parse(const aURL: string; toHash: THash = nil; dec:
            Boolean = false): THash; static;
    end;


implementation
uses IdURI, UUtils;

{
************************************* Url **************************************
}
class function Url.build(const aURL: string; aNameValueParams: array of variant;
    unionParams: Boolean = false; enc: Boolean = false; noCache: boolean =
    true): string;
var
    cHash: THash;
    cParams: THash;
begin
    cHash:=parse(aUrl);
    cParams:=Hash(aNameValueParams);

    result:=build(cHash,cParams,unionParams,enc,noCache);

    FreeHash(cParams);
    FreeHash(cHash);
end;

class function Url.build(const cHash: THash; enc: Boolean = false; noCache:
    boolean = true): string;
var
    cParam: string;
    cParams: string;
    i: Integer;
begin
    cParams:='';
    for i:=0 to cHash.Hash['params'].Count-1 do begin
        if (i=0) then
            cParams:='?'
        else
            cParams:=cParams+'&';

        cParams:=cParams+cHash.Hash['params'].Name[i];
        if (cHash.Hash['params'][i]<>'') then begin

            cParam:=cHash.Hash['params'][i];
            if (enc) then begin
                cParam:=Utils.rusCod(cParam);
                cParam:=Utils.urlEncode(cParam);
             end;

            cParams:=cParams+'='+cParam;
         end;
    end;
    if (noCache) then begin
        if (cParams='') then
            cParams:=cParams+'?'
        else
            cParams:=cParams+'&';
        cParams:=cParams+'noCache='+Utils.randomStr(5);

    end;
    result:=cHash['addr']+cParams;
end;

class function Url.build(const cHash: THash; const cNameValueParams: array of
    variant; unionParams: Boolean = false; enc: Boolean = false; noCache:
    boolean = true): string;
var
    cParams: THash;
begin
    cParams :=Hash(cNameValueParams);
    result  :=build(cHash,cParams,unionParams,enc,noCache);
    FreeHash(cParams);
end;

class function Url.build(cHash, cParams: THash; unionParams: Boolean = false;
    enc: Boolean = false; noCache: boolean = true): string;
begin
    if (unionParams) then
        cHash.Hash['params'].union(cParams)
    else
        cHash.Hash['params'].assign(cParams);

    result:=build(cHash,enc,noCache);
end;

class function Url.params(params: string; toHash: THash = nil; dec: Boolean =
    false): THash;
var
    cHash: THash;
    cNameValue: THash;
    cParam: string;
    i: Integer;
begin
    if (toHash = nil) then
        result:=Hash()
    else
        result:=toHash;

    params:=trim(params);
    if (pos('?',params) = 1) then
        params:=copy(params,2);

    cHash:=Utils.explode(params,'&');

    for i:=0 to cHash.Count-1 do
    begin
        cNameValue:=Utils.explode(cHash[i],'=');
        if (cNameValue.Count>1) then begin
            cParam:= cNameValue[1];

            if(dec) then begin
                cParam:=Utils.urlDecode(cParam);
                cParam:=Utils.rusEnCod(cParam);
            end;

            result[cNameValue[0]] := cParam;

        end else
            result[cNameValue[0]] := '';
        FreeHash(cNameValue);
    end;
    FreeHash(cHash);
end;

class function Url.parse(const aURL: string; toHash: THash = nil; dec: Boolean
    = false): THash;
var
    cUri: TIdURI;
    cHash: THash;
    cNameValue: THash;
    i: Integer;
begin
    if (toHash = nil) then
        result:=Hash()
    else
        result:=toHash;

    cUri := TIdURI.Create(aUrl);
    try try
        result.clear;

        result['uri']       :=  cUri.URI;
        result['addr']      :=  cUri.Protocol+'://'+cUri.Host+cUri.path+cUri.Document;
        result['protocol']  :=  cUri.Protocol;
        result['host']      :=  cUri.Host;
        result['path']      :=  cUri.path;
        result['hpath']     :=  cUri.Protocol+'://'+cUri.Host+cUri.path;
        result['document']  :=  cUri.Document;
        result['param']     :=  cUri.Params;

        cHash:=params(cUri.Params,nil,dec);
        result.Hash['params'].assign(cHash);
        FreeHash(cHash);
    except on e:Exception do begin

    end;end;
    finally
        if cUri<>nil then
            cUri.Free;
    end;
end;



end.
