unit UUtils;

interface

uses
  UHash, SysUtils,Classes;
{$define _log_}
type
    Utils = class(TObject)
    private
        class function isNum(c: char): Boolean; static;
    public
        class procedure concat(A: string; B, Target: TStream); overload; static;
        class procedure concat(A, B, Target: TStream); overload; static;
        //1 Преобразует строку с разделителями glue в hash
        class function explode(str, glue: string; toHash: THash = nil): THash;
            static;
        //1 Пребразует число в строку валидную к json
        class function FloatToStr(f: Double): string; static;
        //1 преобразует значения hash (value) в строку с разделителями
        class function implode(fromHash: THash; glue: string = ';'): string;
            static;
        class function isFloat(const aStr: string): Boolean; static;
        class function isInt(const aStr:string): Boolean; static;
        class function isNumeric(const aStr: string): Boolean; static;
        class function randomStr(aLen: integer=10): string; static;
        class function readFromStream(Stream: TStream): string; static;
        //1 Кодирует все кириличиские символы
        class function rusCod(s: string): string; static;
        //1 Декодирует все коды в их кириличиское представление
        class function rusEnCod(s: string): string; static;
        //1 Преобразует вещественное из строки ( с учетом что разделитель и точка и запятая)
        class function StrToFloat(str: string): Double; static;
        class function UrlDecode(Str: AnsiString): AnsiString; static;
        class function UrlEncode(Str: AnsiString): AnsiString; static;
        class function writeToStream(str: string; Stream: TStream): Integer;
            static;
    end;

implementation
uses {$ifdef _log_}ULog,{$endif} IdURI;
{
************************************ Utils *************************************
}
class procedure Utils.concat(A: string; B, Target: TStream);
begin
    Utils.writeToStream(A,Target);
    Target.CopyFrom(B,B.Size-B.Position);
end;

class procedure Utils.concat(A, B, Target: TStream);
begin
    Target.CopyFrom(A,A.Size-B.Position);
    Target.CopyFrom(B,B.Size-B.Position);
end;

class function Utils.explode(str, glue: string; toHash: THash = nil): THash;
var
    cPos: Integer;
    cStr: string;
    cStep: Integer;
begin
    if (toHash = nil) then
        toHash:=Hash();
    result:=toHash;

    cPos:=pos(glue,str);
    cStep:=0;

    while cPos>0 do begin
        cStr:=copy(str,1,cPos-1);
        str:=copy(str,cPos+1,length(str));
        result[IntToStr(cStep)]:=cStr;
        cPos:=pos(glue,str);
        inc(cStep);
    end;

    if (length(str)>0) then
        result[IntToStr(cStep)]:=str;
end;

class function Utils.FloatToStr(f: Double): string;
begin
    result:=SysUtils.FloatToStr(f);
    result:=StringReplace(result,',','.',[rfReplaceAll]);
end;

class function Utils.implode(fromHash: THash; glue: string = ';'): string;
var
    i: Integer;
begin
    result:='';
    for i:=0 to fromHash.count-1 do begin

        if (fromHash.Item[i].Hash.Count=0) then begin
            if (result<>'') then
                result:=result+glue;
            result:=result+fromHash.value[i];
        end;

    end;
end;

class function Utils.isFloat(const aStr: string): Boolean;
var
    i: Integer;
    cChar: Char;
    cStr: string;
    cSep: Boolean;
begin
    cStr:=aStr;
    cStr:=trim(cStr);
    if length(cStr)=0 then
    begin
           result:=false;
           exit;
    end;
    result:=true;
    cSep:=false;
    if (cStr[1] = '-') or (cStr[1] = '+') then
           cStr:=copy(cStr,2,length(cStr));
    for i:=1 to Length(cStr) do
    begin
           cChar:=cStr[i];
           if not isNum(cChar) then
           begin
                   if (not cSep) and ((cChar = '.') or (cChar = ',')) then
                           cSep:=true
                   else
                   begin
                           result:=false;
                           exit;
                   end;
           end;
    end;//for
end;

class function Utils.isInt(const aStr:string): Boolean;
var
    i: Integer;
    cChar: Char;
    cStr: string;
begin
    cStr:=aStr;
    cStr:=Trim(cStr);
    if Length(cStr)=0 then
    begin
           result:=false;
           exit;
    end;

    result:=true;

    if (cStr[1] = '-') or (cStr[1] = '+') then
       cStr:=copy(cStr,2,length(cStr));

    for i:=1 to Length(cStr) do
    begin
           cChar:=cStr[i];
           if not isNum(cChar) then
           begin
                   result:=false;
                   exit;
           end;
    end;//for
end;

class function Utils.isNum(c: char): Boolean;
begin
    result:=(ord(c)>=48) and (ord(c)<=57);
end;

class function Utils.isNumeric(const aStr: string): Boolean;
begin
    result:= ( isInt(aStr) or isFloat(aStr) );
end;

class function Utils.randomStr(aLen: integer=10): string;
var
    i: Integer;
begin
    randomize;
    result:='';
    if aLen>0 then
    for i:=0 to aLen-1 do
        result:=result+chr(65+random(25));
end;

class function Utils.readFromStream(Stream: TStream): string;
var
    cLen: Integer;
begin
    Stream.ReadBuffer(cLen,SizeOf(cLen));
    SetLength(result, cLen div 2);
    Stream.ReadBuffer(result[1], cLen);
end;

class function Utils.rusCod(s: string): string;
var
    c: AnsiChar;
    code: Integer;
    i: Integer;
    LMax, LMin, HMax, HMin: Integer;
    ansi: AnsiString;
begin

    LMin:=Ord(AnsiChar('а'));
    LMax:=Ord(AnsiChar('я'));
    HMin:=Ord(AnsiChar('А'));
    HMax:=Ord(AnsiChar('Я')) ;
    ansi:=AnsiString(s);

    result:='';
    for i:=1 to length(ansi) do begin
        c:=ansi[i];
        code:=ord(c);
        if ((code>=HMin) and (code<=HMax)) or
           ((code>=LMin) and (code<=LMax)) then
                result:=result+'#'+IntToStr(code)+';'
        else if (code = Ord(AnsiChar('ё'))) then
            result:=result+'#1027;'
        else if (code = Ord(AnsiChar('Ё'))) then
            result:=result+'#1028;'
        else
            result:=result+c;

    end;
end;

class function Utils.rusEnCod(s: string): string;
var
    code: AnsiString;
    cStr: AnsiString;
    i: Integer;
    LMax, LMin, HMax, HMin: Integer;
begin

    LMin:=Ord(AnsiChar('а'));
    LMax:=Ord(AnsiChar('я'));
    HMin:=Ord(AnsiChar('А'));
    HMax:=Ord(AnsiChar('Я'));

    cStr:=AnsiString(s);


    for i:=LMin to LMax do begin
        code:='#'+IntToStr(i)+';';
        cStr:=StringReplace(cStr,code,AnsiChar(chr(i)),[rfReplaceAll]);
    end;

    for i:=HMin to HMax do begin
        code:='#'+IntToStr(i)+';';
        cStr:=StringReplace(cStr,code,AnsiChar(chr(i)),[rfReplaceAll]);
    end;

    cStr:=StringReplace(cStr,'#1027;',AnsiChar('ё'),[rfReplaceAll]);
    cStr:=StringReplace(cStr,'#1028;',AnsiChar('Ё'),[rfReplaceAll]);

    result:=cStr;
end;

class function Utils.StrToFloat(str: string): Double;
begin
    str:=StringReplace(str,'.',',',[rfReplaceAll]);
    result:=SysUtils.StrToFloat(str);
end;

class function Utils.UrlDecode(Str: AnsiString): AnsiString;

            function HexToChar(W: word): AnsiChar;
            asm
                    cmp ah, 030h
                    jl @@error
                       cmp ah, 039h
                       jg @@10
                       sub ah, 30h
                       jmp @@30
                    @@10:
                       cmp ah, 041h
                       jl @@error
                       cmp ah, 046h
                       jg @@20
                       sub ah, 041h
                       add ah, 00Ah
                       jmp @@30
                    @@20:
                       cmp ah, 061h
                       jl @@error
                       cmp al, 066h
                       jg @@error
                       sub ah, 061h
                       add ah, 00Ah
                    @@30:
                       cmp al, 030h
                       jl @@error
                       cmp al, 039h
                       jg @@40
                       sub al, 030h
                       jmp @@60
                    @@40:
                       cmp al, 041h
                       jl @@error
                       cmp al, 046h
                       jg @@50
                       sub al, 041h
                       add al, 00Ah
                       jmp @@60
                    @@50:
                       cmp al, 061h
                       jl @@error
                       cmp al, 066h
                       jg @@error
                       sub al, 061h
                       add al, 00Ah
                    @@60:
                       shl al, 4
                       or al, ah
                       ret
                    @@error:
                       xor al, al
            end;//asm func

            function GetCh(P: PAnsiChar; var Ch: AnsiChar): AnsiChar;
            begin
                    Ch := P^;
                    Result := Ch;
            end;

    var
            P: PAnsiChar;
            Ch: AnsiChar;

begin
    Result := '';
    if Str = '' then
          exit;

    P := @Str[1];
    while GetCh(P, Ch) <> #0 do
    begin
          case Ch of
            '+': Result := Result + ' ';
            '%':begin
                  Inc(P);
                  Result := Result + HexToChar(PWord(P)^);
                  Inc(P);
                end;
            else
                  Result := Result + Ch;
          end;//case

          Inc(P);
    end;
end;

class function Utils.UrlEncode(Str: AnsiString): AnsiString;

            function CharToHex(Ch: AnsiChar): Integer;
            asm
                    and eax, 0FFh
                    mov ah, al
                    shr al, 4
                    and ah, 00fh
                    cmp al, 00ah
                    jl @@10
                    sub al, 00ah
                    add al, 041h
                    jmp @@20
                @@10:
                    add al, 030h
                @@20:
                    cmp ah, 00ah
                    jl @@30
                    sub ah, 00ah
                    add ah, 041h
                    jmp @@40
                @@30:
                    add ah, 030h
                @@40:
                    shl eax, 8
                    mov al, '%'
            end;
    var
            i, Len: Integer;
            Ch: AnsiChar;
            N: Integer;
            P: PAnsiChar;

begin

    Result        := '';
    Len           := Length(Str);
    P             := PAnsiChar(@N);

    for i := 1 to Len do
    begin
          Ch := Str[i];
          if Ch in ['0'..'9', 'A'..'Z', 'a'..'z', '_'] then
                  Result := Result + Ch
          else
          begin
                  if Ch = ' ' then
                          Result := Result + '+'
                  else
                  begin
                          N := CharToHex(Ch);
                          Result := Result + P;
                  end;
          end;
    end;

end;

class function Utils.writeToStream(str: string; Stream: TStream): Integer;

    const
        cFuncName = 'writeToStream';
    var
        cLen: Integer;
        cStr:ShortString;

begin
    cStr:=ShortString(str);
    //cLen := Length(str)*2;
    cLen:=Length(cStr);
    Stream.WriteBuffer(cLen,sizeof(Integer));
    {$ifdef _log_} ULog.Log('LEN = %d',[sizeof(Integer)],ClassName,cFuncName);{$endif}
    Stream.WriteBuffer(cStr[1],cLen);
end;


end.
