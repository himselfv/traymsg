unit InstanceChecker;
{
Based on code taken from:
********************************************
Zarko Gajic
About.com Guide to Delphi Programming
http://delphi.about.com
email: delphi.guide@about.com
free newsletter: http://delphi.about.com/library/blnewsletter.htm
forum: http://forums.about.com/ab-delphi/start/
********************************************

Usage:
1. Include as one of the first units in the application.
2. if InstanceChecker.RestoreIfRunning(Application.Handle) then
     exit;

Notes:
1. A program is considered the same if it has the same full path.
 An option can be added to check for only exe name or signature instead,
 or for a given key (of user's choice).
}

interface
uses Windows, SysUtils;

type
  PNewInstanceInfo = ^TNewInstanceInfo;
  TNewInstanceInfo = record
    CommandLine: array[0..255] of char;
  end;

function RestoreIfRunning(const AppHandle : THandle): boolean;
function TryAcceptNewInstance(out AInfo: TNewInstanceInfo): boolean;

implementation

const
  MAX_NEW_INSTANCES = 5;

type
  PInstanceInfo = ^TInstanceInfo;
  TInstanceInfo = packed record
    PreviousHandle: THandle;
    NewInstanceCount: integer;
    NewInstances: array[0..MAX_NEW_INSTANCES-1] of TNewInstanceInfo;
  end;

var
  MappingName: string;
  MappingHandle: THandle;
  InstanceInfo: PInstanceInfo;
  RemoveMe: boolean = True;
  MappingMutex: THandle;

function RestoreIfRunning(const AppHandle: THandle): boolean;
var ANewInstance: PNewInstanceInfo;
begin
  Result := True;
  MappingName := StringReplace(ParamStr(0), '\', '', [rfReplaceAll, rfIgnoreCase]);
  MappingMutex := CreateMutex(nil, true, PChar(MappingName+'_Mutex')); //create and lock
  if MappingMutex=INVALID_HANDLE_VALUE then
    RaiseLastOsError();

  if GetLastError <> ERROR_ALREADY_EXISTS then try
    MappingHandle := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE,
      0, SizeOf(TInstanceInfo), PChar(MappingName));
    if MappingHandle = 0 then
      RaiseLastOSError;

   //Do not check if the mapping ALREADY_EXISTS because the mutex wasn't.
    InstanceInfo := MapViewOfFile(MappingHandle, FILE_MAP_ALL_ACCESS, 0, 0,
      SizeOf(TInstanceInfo));
    ZeroMemory(InstanceInfo, SizeOf(InstanceInfo));
    InstanceInfo^.PreviousHandle := AppHandle;
    Result := False;
    exit;
  finally
    ReleaseMutex(MappingMutex);
  end;

 //Get the mutex
  if WaitForSingleObject(MappingMutex, INFINITE) <> WAIT_OBJECT_0 then
    RaiseLastOSError;
  try
    MappingHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(MappingName));
    if MappingHandle = 0 then
      RaiseLastOsError;

    InstanceInfo := MapViewOfFile(MappingHandle, FILE_MAP_ALL_ACCESS, 0, 0,
      SizeOf(TInstanceInfo));
    RemoveMe := False;

   //Reserve instance slot
    if InstanceInfo.NewInstanceCount>=MAX_NEW_INSTANCES then
     //Cannot add one more instance data to the queue. Throw the command line out.
      exit;

    ANewInstance := @InstanceInfo.NewInstances[InstanceInfo.NewInstanceCount];
    Inc(InstanceInfo.NewInstanceCount);

    StrPlCopy(
      @ANewInstance^.CommandLine[0],
      GetCommandLine,
      Length(ANewInstance^.CommandLine)-1
    );
    ANewInstance^.CommandLine[
      Length(ANewInstance^.CommandLine)-1
    ] := #00;
  finally
    ReleaseMutex(MappingMutex);
  end;

  if IsIconic(InstanceInfo^.PreviousHandle) then
    ShowWindow(InstanceInfo^.PreviousHandle, SW_RESTORE);
  SetForegroundWindow(InstanceInfo^.PreviousHandle);
end;


//Accepts new instance information, if pending
function TryAcceptNewInstance(out AInfo: TNewInstanceInfo): boolean;
begin
 //Get the mutex
  if WaitForSingleObject(MappingMutex, INFINITE) <> WAIT_OBJECT_0 then
    RaiseLastOSError;
  try
    Result := InstanceInfo^.NewInstanceCount>0;
    if Result then begin
      Dec(InstanceInfo^.NewInstanceCount);
      AInfo := InstanceInfo^.NewInstances[InstanceInfo^.NewInstanceCount];
    end;
  finally
    ReleaseMutex(MappingMutex);
  end;
end;



initialization

finalization

  if Assigned(InstanceInfo) then UnmapViewOfFile(InstanceInfo);
  if MappingHandle <> 0 then CloseHandle(MappingHandle);
  if MappingMutex <> 0 then CloseHandle(MappingMutex);


end.
