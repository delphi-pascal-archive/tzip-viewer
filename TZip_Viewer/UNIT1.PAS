unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, ComCtrls, StdCtrls, TZip;

type
  TForm1 = class(TForm)
    List: TListView;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Zip: TZipFile;
    OD: TOpenDialog;
    Refresh1: TMenuItem;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Properties1: TMenuItem;
    procedure Open1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure ZipReadFile(ZipFile: ZipFile);
    procedure ListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Open1Click(Sender: TObject);
begin
List.items.Clear;
if Od.Execute then
  Zip.Filename:=Od.Filename;
end;

procedure TForm1.Refresh1Click(Sender: TObject);
begin
List.Items.Clear;
Zip.Read(Zip.Filename);
end;

Function Subs(S:String;Sub,Sost:Char):String;
var i:Longint;
begin
For i:= 0 to Length(S) do
  If s[i] = Sub then
    s[i]:= Sost;
Result:= s;
end;

procedure TForm1.ZipReadFile(ZipFile: ZipFile);
var It:TListItem;
begin
It:=List.Items.Add;
It.Caption:=ExtractFileName(Subs(ZipFile.Filename,'/','\'));
It.SubItems.Add(DateToStr(Zip.GetDate(ZipFile.Date)));
It.SubItems.Add(TimeToStr(Zip.GetTime(ZipFile.Time)));
It.SubItems.Add(FloatToStrF(ZipFile.CompressedSize /1, ffNumber,10,0));
It.SubItems.Add(FloatToStrF(ZipFile.UncompressedSize /1, ffNumber,10,0));
It.SubItems.Add(ExtractFilePath(Subs(ZipFile.Filename,'/','\')));
end;

procedure TForm1.ListDblClick(Sender: TObject);
var I:Longint;
begin
if List.Selected <> nil then
begin
  I:=List.Selected.Index;
  MessageBox(Form1.Handle,pChar(Zip.Files[i].FileName + #13 + #13 + 'Date: ' + DateToStr(Zip.GetDate(Zip.Files[i].Date)) + #13 + 'Time: ' + TimeToStr(Zip.GetTime(Zip.Files[i].Time)) + #13 + 'Compressed size: ' + FloatToStrF(Zip.Files[i].CompressedSize / 1, ffNumber,15,0) + #13 + 'Uncompressed size: ' + FloatToStrF(Zip.Files[i].UncompressedSize / 1, ffNumber,15,0)),'ZipFiles',MB_ICONINFORMATION + MB_APPLMODAL);
end;
end;

end.
