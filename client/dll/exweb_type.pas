unit exweb_type;

interface
Uses Classes,UExWebType, DB, DBClient;

const
strProcSend       = 'send';
strProcRecv       = 'recv';
strProcQuery       = 'query';
strProcSetParam   = 'setParam';
strProcGetParam   = 'getParam';

type
TProcSend = function (const str:string;data:TStream;prevState:TExWebState):TExWebState;
TProcRecv = function (var str:string;data:TStream;prevState:TExWebState):TExWebState;
TProcQuery = function (const sql, base: string; outDS: TClientDataSet; const coding: string): Boolean;

TProcSetParam = procedure (name:string;value:string);
TProcGetParam = function (name:string):string;

implementation

end.
