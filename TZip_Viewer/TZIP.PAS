unit TZip;

{Questo componente è stato realizzato da:                }
{                                                        }
{                    Pier Carlo Chiodi                   }
{           E-Mail: pc.chiodi@mbox.thunder.it            }
{WEB: http://www.geocities.com/SiliconValley/Park/6159/  }
{                                                        }


interface

uses
  Windows, SysUtils, Classes;

type ZipFile = Record
  Version                      : WORD;
  Flag                         : WORD;
  CompressionMethod            : WORD;
  Time                         : WORD;
  Date                         : WORD;
  CRC32                        : Longint;
  CompressedSize               : Longint;
  UncompressedSize             : Longint;
  FileNameLength               : WORD;
  ExtraFieldLength             : WORD;
  FileName                     : String;
end;

type PZipFile = ^ZipFile;

const
  LocalFileHeaderSig = $04034b50;
  CentralFileHeaderSig = $02014b50;
  EndCentralDirSig = $06054b50;

type TReadFile = procedure (ZipFile : ZipFile) of object;

type
  TZipFile = class(TComponent)
  private
    vFiles : TList;
    vFileName : String;
    FOnReadFile : TReadFile;
    procedure SetFileName(Value:String);
    procedure Aggiungi(F:ZipFile);

    function GetFiles(I:Integer):ZipFile;
    function GetFileCount:Longint;
  public

    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;

    function GetDate(Date:Word):TDateTime;
    function GetTime(Time:Word):TDateTime;

    procedure Read(Value:String);
    property Files[I:Integer]:ZipFile read GetFiles;

  published
    property FileName : String read vFileName write SetFileName;
    property OnReadFile : TReadFile read FOnReadFile write FOnReadFile;
    property FileCount : Longint read GetFileCount;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TZipFile]);
end;

constructor TZipFile.Create(AOWner:TComponent);
begin
inherited Create(AOwner);
vFiles:=TList.Create;
end;

Destructor TZipFile.Destroy;
begin
  vFiles.Free;
  inherited Destroy;
end;

function TZipFile.GetDate(Date:Word):TDateTime;
var FileTime:TFileTime;
    SysTime:TSystemTime;
    D,M,Y:Word;
    Time:Word;
begin
  DosDateTimeToFileTime(Date,Time,FILETIME);
  FileTimeToSystemTime(FileTime,SysTime);
  Y:=SysTime.wYear;
  M:=SysTime.wMonth;
  D:=SysTime.wDay;
  Result:=EncodeDate(Y,M,D);
end;

function TZipFile.GetTime(Time:Word):TDateTime;
var FileTime:TFileTime;
    SysTime:TSystemTime;
    H,M,S,Ms:Word;
    D:Word;
begin
  DosDateTimeToFileTime(D,Time,FILETIME);
  FileTimeToSystemTime(FileTime,SysTime);
  H:=SysTime.wHour;
  M:=SysTime.wMinute;
  S:=SysTime.wSecond;
  Ms:=SysTime.wMilliseconds;
  Result:=EncodeTime(H,M,S,Ms);
end;

procedure TZipFile.Aggiungi(F:ZipFile);
var ZF:PZipFile;
begin
  New(ZF);
  ZF^.Version:=F.Version;
  ZF^.Flag:=F.Flag;
  ZF^.CompressionMethod:=F.CompressionMethod;
  ZF^.Time:=F.Time;
  ZF^.Date:=F.Date;
  ZF^.CRC32:=F.CRC32;
  ZF^.CompressedSize:=F.CompressedSize;
  ZF^.UncompressedSize:=F.UncompressedSize;
  ZF^.FileNameLength:=F.FileNameLength;
  ZF^.ExtraFieldLength:=F.ExtraFieldLength;
  ZF^.FileName:=F.FileName;

  vFiles.Add(ZF);
end;

function TZipFile.GetFiles(I:Integer):ZipFile;
begin
  Result:=ZipFile(vFiles[I]^);
end;

function TZipFile.GetFileCount:Longint;
begin
  Result:=vFiles.Count;
end;

procedure TZipFile.Read(Value:String);
var Sig                            : Longint;
    ZipStream                      : TFileStream;
    Res                            : Longint;
    ZFile                          : ZipFile;
    Name                           : array [0..255] of char;
begin
vFiles.Clear;
ZipStream:=TFileStream.Create(Value,fmOpenRead);
while TRUE do
begin
  Res:=ZipStream.Read(Sig,SizeOf(Sig));
  if (Res = HFILE_ERROR) or (Res <> SizeOf(Sig)) then
    Break
  else

  if Sig = LocalFileHeaderSig then
  begin
    Res:=ZipStream.Read(ZFile.Version,SizeOf(WORD));
    Res:=ZipStream.Read(ZFile.Flag,SizeOf(WORD));
    Res:=ZipStream.Read(ZFile.CompressionMethod,SizeOf(WORD));
    Res:=ZipStream.Read(ZFile.Time,SizeOf(WORD));
    Res:=ZipStream.Read(ZFile.Date,SizeOf(WORD));
    Res:=ZipStream.Read(ZFile.CRC32,SizeOf(Longint));
    Res:=ZipStream.Read(ZFile.CompressedSize,SizeOf(Longint));
    Res:=ZipStream.Read(ZFile.UncompressedSize,SizeOf(Longint));
    Res:=ZipStream.Read(ZFile.FileNameLength,SizeOf(WORD));
    Res:=ZipStream.Read(ZFile.ExtraFieldLength,SizeOf(WORD));
    Res:=ZipStream.Read(Name,ZFile.FileNameLength);
    ZFile.FileName:=Copy(Name,0,ZFile.FileNameLength);
    Res:=ZipStream.Seek(ZFile.ExtraFieldLength,soFromCurrent);
    Res:=ZipStream.Seek(ZFile.CompressedSize,soFromCurrent);
    Aggiungi(ZFile);
    if Assigned (FOnReadFile) then
      FOnReadFile(ZFile);
  end
  else
  if Sig = CentralFileHeaderSig then
  begin
    ZipStream.Seek(42,soFromCurrent)
  end
  else
  if Sig = EndCentralDirSig then
    Break;
end;
ZipStream.Free;
end;

procedure TZipFile.SetFileName(Value:String);
begin
  if FileExists(Value) then
    vFileName:=VALUE;
  Read(Value);
end;

end.
