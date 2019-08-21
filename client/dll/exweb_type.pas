unit exweb_type;

interface
Uses Classes,UExWebType;

const
strProcSend       = 'send';
strProcRecv       = 'recv';
strProcQuery       = 'query';
strProcSetParam   = 'setParam';
strProcGetParam   = 'getParam';
strProcPrepare   = 'prepare';

type
TProcSend = function (const str:string;data:TStream;prevState:TExWebState):TExWebState;
TProcRecv = function (var str:string;data:TStream;prevState:TExWebState):TExWebState;
TProcQuery = function (const sql, base: string; outDS: TStrings; const coding: string): Boolean;

TProcSetParam = procedure (name:string;value:string);
TProcGetParam = function (name:string):string;
TProcPrepare = function (str:string):integer;

implementation

end.
