unit exweb_type;

interface
Uses Classes,UExWebType;

const
strProcSend       = 'send';
strProcRecv       = 'recv';
strProcSetParam   = 'setParam';
strProcGetParam   = 'getParam';

type
TProcSend = function (const str:string;data:TStream;prevState:TExWebState):TExWebState;
TProcRecv = function (var str:string;data:TStream;prevState:TExWebState):TExWebState;

TProcSetParam = procedure (name:string;value:string);
TProcGetParam = function (name:string):string;

implementation

end.
