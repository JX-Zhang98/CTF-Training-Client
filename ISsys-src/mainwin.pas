unit mainwin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AdvPageControl, ComCtrls, jpeg, Buttons, pngimage, StdCtrls,
  Grids, DBGrids, DB, ADODB, IdHashMessageDigest;

type
  Tmainwnd = class(TForm)
    content: TPageControl;
    News: TTabSheet;
    Challenge: TTabSheet;
    board: TTabSheet;
    subflag: TTabSheet;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Image1: TImage;
    Splitter2: TSplitter;
    Image2: TImage;
    Splitter3: TSplitter;
    LSolves: TLabel;
    LallScore: TLabel;
    Lrank: TLabel;
    solves: TLabel;
    allScore: TLabel;
    rank: TLabel;
    challenges: TPageControl;
    misc: TTabSheet;
    reverse: TTabSheet;
    crypto: TTabSheet;
    pwn: TTabSheet;
    web: TTabSheet;
    rankGrid: TDBGrid;
    DataSource: TDataSource;
    query: TADOQuery;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    DBGrid5: TDBGrid;
    DBGrid6: TDBGrid;
    setting: TTabSheet;
    Label1: TLabel;
    flag: TEdit;
    submit: TButton;
    proc: TADOStoredProc;
    solven: TLabel;
    score: TLabel;
    rankk: TLabel;
    Image3: TImage;
    label9: TLabel;
    newpsd: TEdit;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    infochange: TButton;
    newsquery: TADOQuery;
    newsDS: TDataSource;
    rankquery: TADOQuery;
    rankDS: TDataSource;
    reDS: TDataSource;
    requery: TADOQuery;
    miscDS: TDataSource;
    miscquery: TADOQuery;
    cryDS: TDataSource;
    cryquery: TADOQuery;
    pwnDS: TDataSource;
    pwnquery: TADOQuery;
    webDS: TDataSource;
    webquery: TADOQuery;
    Image4: TImage;
    procedure contentDrawTab(Control: TCustomTabControl;
TabIndex: Integer; const Rect: TRect; Active: Boolean);
    
    procedure submitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure infochangeClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  mainwnd: Tmainwnd;

implementation
uses log, common;
{$R *.dfm}
function MD5(const str:string):String;
var
    AMD5:TIdHashMessageDigest5;
begin
    AMD5:=TIdHashMessageDigest5.Create;
    Result:=AMD5.HashStringAsHex(str,TEncoding.UTF8);
    AMD5.Free;
end;



procedure Tmainwnd.contentDrawTab(Control: TCustomTabControl;
TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
s:string;
i:integer;
begin
  for i:=0 to 4 do
    begin
      s:= copy(content.Pages[TabIndex].Caption,i*6+1,6);//每一行最多显示3字
      content.Canvas.TextOut(Rect.Left+5,Rect.Top +5 + i*12,s);
    end;
end;









procedure Tmainwnd.FormCreate(Sender: TObject);
var
so:integer;
sc:integer;
ra:integer;
begin
//显示顶端信息
   query.Close;
   query.SQL.Clear;
   query.SQL.Text := 'select pm, solveNum, score from (select rank() over(order by score desc) as pm, * from student) allrank where id = :id' ;
   query.Parameters[0].Value := logedid;
   query.Prepared := true;
   query.Open;
   rankk.Caption :=  query.Fields[0].AsString;
   solven.Caption := query.Fields[1].AsString;
   score.Caption := query.Fields[2].AsString;
   //题目信息
   cryquery.Close;
  cryquery.SQL.Clear;
  cryquery.SQL.Add('select nam, val, addr from challenge where clas = 4');
  cryquery.Prepared := True;
  cryquery.Open;

  miscquery.Close;
  miscquery.SQL.Clear;
  miscquery.SQL.Add('select nam, val, addr from challenge where clas = 5');
  miscquery.Prepared := True;
  miscquery.Open;

  pwnquery.Close;
  pwnquery.SQL.Clear;
  pwnquery.SQL.Add('select nam, val, addr from challenge where clas = 1');
  pwnquery.Prepared := True;
  pwnquery.Open;

     requery.Close;
  requery.SQL.Clear;
  requery.SQL.Add('select nam, val, addr from challenge where clas = 2');
  requery.Prepared := True;
  requery.Open;

  webquery.Close;
  webquery.SQL.Clear;
  webquery.SQL.Add('select nam, val, addr from challenge where clas = 3');
  webquery.Prepared := True;
  webquery.Open;

  //显示新闻
   newsquery.Close;
    newsquery.SQL.Clear;
    newsquery.SQL.Add('select title, content, puber, pubtime from news order by id');
    newsquery.Prepared := true;
    newsquery.open;

    //排名
   rankquery.SQL.Clear;
   rankquery.SQL.Add('select rank() over (order by score desc)as 排名 ,username, score, solveNum, title from student');
   rankquery.Prepared := True;
   rankquery.Open;

end;

procedure Tmainwnd.infochangeClick(Sender: TObject);
var sql : string;
begin
  proc.ProcedureName := 'changepsd';
  proc.Parameters.Clear;
  proc.Close;
  proc.Parameters.CreateParameter('newpsd', ftstring, pdinput, 32, NULL);
  proc.Parameters.CreateParameter('sid', ftinteger, pdinput, 1, NULL);
  proc.Parameters[0].Value := MD5(newpsd.Text);
  proc.Parameters[1].Value := logedid;
  proc.Prepared := true;
  proc.ExecProc;
  Application.MessageBox('密码重置成功', '提示', MB_OK);
end;

procedure Tmainwnd.submitClick(Sender: TObject);
var
res : integer;
begin  //checkflag
    res := 0;
    proc.ProcedureName := 'checkflag';
    proc.Parameters.Clear;
    proc.Close;
    proc.Parameters.CreateParameter('flag', ftstring, pdinput, 20, NULL);
    proc.Parameters.CreateParameter('sid', ftinteger, pdinput, 1, NULL);
    proc.Parameters.CreateParameter('res', ftinteger, pdoutput, 1, NULL);
    proc.Parameters[0].Value := flag.Text;
    proc.Parameters[1].Value := logedid;
    proc.Parameters[2].Value := res;
    proc.Prepared := true;
    proc.ExecProc;
    res := proc.Parameters.ParamByName('res').Value;
    if res = -1 then
    begin
      Application.MessageBox('答案提交错误', '提示', MB_ICONWARNING);
      exit;
    end
    else
    begin
       Application.MessageBox('Flag Accepted!', '提示', MB_OK);
       solven.Caption := inttostr(strtoint(solven.Caption)+1);
       score.Caption := inttostr(strtoint(score.Caption) + res);
    end;
end;

end.
