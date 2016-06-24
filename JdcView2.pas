unit JdcView2;

interface

uses
  JdcView2.ObserverListEx, ValueList, Classes, SysUtils;

type
  TView = class(TObserverListEx)
  protected
    constructor Create(AOwner: TComponent); reintroduce;
  public
    class function Obj: TView;

    procedure sp_SyncPacket(const APacket: String);
    procedure sp_ASyncPacket(const APacket: String);

    procedure sp_SyncMessage(const ACode: String; AMsg: String = '');
    procedure sp_AsyncMessage(const ACode: String; AMsg: String = '');
    destructor Destroy; override;

    procedure sp_ErrorMessage(const ErrorName: string;
      const ErrorMsg: String = '');
    procedure sp_DebugMessage(const Msg: String); overload;
    procedure sp_DebugMessage(const Format: string;
      const Args: array of const); overload;
    procedure sp_LogMessage(const LogName: String; const LogMsg: string = '');
    procedure sp_ShowMessage(const Msg: String);
    procedure sp_Terminate(const Msg: string);
  end;

implementation

uses JdcGlobal;

var
  MyObj: TView = nil;

  { TView }

constructor TView.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TView.Destroy;
begin
  inherited;
end;

procedure TView.sp_AsyncMessage(const ACode: String; AMsg: String = '');
var
  ValueList: TValueList;
begin
  ValueList := TValueList.Create;
  try
    ValueList.Values['Code'] := ACode;
    ValueList.Values['Msg'] := AMsg;
    AsyncBroadcast(ValueList);
  finally
    ValueList.Free;
  end;
end;

procedure TView.sp_ASyncPacket(const APacket: String);
var
  ValueList: TValueList;
begin
  ValueList := TValueList.Create;
  try
    ValueList.Text := APacket;
    AsyncBroadcast(ValueList);
  finally
    ValueList.Free;
  end;
end;

procedure TView.sp_DebugMessage(const Format: string;
  const Args: array of const);
var
  str: string;
begin
  FmtStr(str, Format, Args);
  sp_DebugMessage(str);
end;

procedure TView.sp_DebugMessage(const Msg: String);
begin
  PrintDebug(Msg);
  sp_SyncMessage('DebugMessage', Msg);
end;

procedure TView.sp_ErrorMessage(const ErrorName: string;
  const ErrorMsg: String = '');
var
  ValueList: TValueList;
begin
  ValueList := TValueList.Create;
  try
    ValueList.Values['Code'] := 'ErrorMessage';
    ValueList.Values['Msg'] := ErrorName; // old version.
    ValueList.Values['ErrorName'] := ErrorName;
    ValueList.Values['ErrorMsg'] := ErrorMsg;
    Broadcast(ValueList);
  finally
    ValueList.Free;
  end;
end;

procedure TView.sp_LogMessage(const LogName: String; const LogMsg: string = '');
var
  ValueList: TValueList;
begin
  ValueList := TValueList.Create;
  try
    ValueList.Values['Code'] := 'LogMessage';
    ValueList.Values['Msg'] := LogName + ', ' + LogMsg; // old version.
    ValueList.Values['LogName'] := LogName;
    ValueList.Values['LogMsg'] := LogMsg;
    Broadcast(ValueList);
  finally
    ValueList.Free;
  end;
end;

procedure TView.sp_ShowMessage(const Msg: String);
begin
  sp_SyncMessage('ShowMessage', Msg);
end;

procedure TView.sp_SyncPacket(const APacket: String);
var
  ValueList: TValueList;
begin
  ValueList := TValueList.Create;
  try
    ValueList.Text := APacket;
    Broadcast(ValueList);
  finally
    ValueList.Free;
  end;
end;

procedure TView.sp_SyncMessage(const ACode: String; AMsg: String = '');
var
  ValueList: TValueList;
begin
  ValueList := TValueList.Create;
  try
    ValueList.Values['Code'] := ACode;
    ValueList.Values['Msg'] := AMsg;

    Broadcast(ValueList);
  finally
    ValueList.Free;
  end;
end;

procedure TView.sp_Terminate(const Msg: string);
begin
  sp_SyncMessage('Terminate', Msg);
end;

{ TView }

class function TView.Obj: TView;
begin
  if MyObj = nil then
    MyObj := TView.Create(nil);
  Result := MyObj;
end;

end.
