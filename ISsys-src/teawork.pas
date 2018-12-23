unit teawork;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, ComCtrls, pngimage, StdCtrls, DB, ADODB, Grids,
  DBGrids;

type
  Tteacherwork = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    workboard: TPageControl;
    rank: TTabSheet;
    upcha: TTabSheet;
    Image1: TImage;
    Splitter2: TSplitter;
    Image2: TImage;
    proc: TADOStoredProc;
    addnews: TTabSheet;
    query: TADOQuery;
    rankGrid: TDBGrid;
    DataSource: TDataSource;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cflag: TEdit;
    caddr: TEdit;
    cvalue: TEdit;
    ctype: TComboBox;
    cname: TEdit;
    confrim: TButton;
    rankquery: TADOQuery;
    Image4: TImage;
    Label6: TLabel;
    Label7: TLabel;
    title: TEdit;
    content: TMemo;
    cancel: TButton;
    confirmup: TButton;
    procedure confirmClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cancelClick(Sender: TObject);
    procedure confirmupClick(Sender: TObject);
    

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  teacherwork: Tteacherwork;

implementation

uses
tealog, common;
{$R *.dfm}

procedure Tteacherwork.cancelClick(Sender: TObject);
begin
    title.Clear;
    content.Clear;
end;

procedure Tteacherwork.confirmClick(Sender: TObject);
var
chname: string;
chtype: string;
chvalue:Integer;
chaddr:string;
chflag : string;
begin
    chname := cname.Text;
    chtype := ctype.Text;
    chaddr := caddr.Text;
    chflag := cflag.Text;
    if (chname = '') or (chtype = '') or (cvalue.Text = '') or (chaddr = '') or (chflag = '') then
    begin
      Application.MessageBox('请完善题目信息！', '提示', MB_ICONWARNING);
      exit;
    end;
    chvalue := strtoint(cvalue.Text);
    proc.ProcedureName := 'upchallenges';
    proc.Parameters.Clear;
    proc.Close;
    //proc.Parameters.CreateParameter('username', ftstring, pdinput, 20, NULL);
    proc.Parameters.CreateParameter('cname', ftstring , pdinput, 20, NULL);
    proc.Parameters.CreateParameter('ctype', ftstring, pdinput, 10, NULL);
    proc.Parameters.CreateParameter('cvalue', ftinteger, pdinput, 1, NULL);
    proc.Parameters.CreateParameter('caddr', ftstring, pdinput, 50, NULL);
    proc.Parameters.CreateParameter('cflag', ftstring, pdinput, 50, NULL);
    proc.Parameters.CreateParameter('upper', ftinteger, pdinput, 1, NULL);
    proc.Parameters[0].Value := chname;
    proc.Parameters[1].Value := chtype;
    proc.Parameters[2].Value := chvalue;
    proc.Parameters[3].Value := chaddr;
    proc.Parameters[4].Value := chflag;
    proc.Parameters[5].Value := logedid;
    proc.Prepared := true;
    proc.ExecProc;
    Application.MessageBox('题目上传完成！', '提示', MB_OK);
end;

procedure Tteacherwork.confirmupClick(Sender: TObject);
var sql : string;
begin
   proc.ProcedureName := 'pubnews';
   proc.Parameters.Clear;
   proc.Close;
   proc.Parameters.CreateParameter('title', ftstring, pdinput, 50, NULL);
   proc.Parameters.CreateParameter('content', ftstring, pdinput, 100, NULL);
   proc.Parameters.CreateParameter('puber', ftinteger, pdinput, 1, NULL);
   proc.Parameters[0].Value := title.Text;
   proc.Parameters[1].Value := content.Text;
   proc.Parameters[2].Value := logedid;
   proc.Prepared := true;
   proc.ExecProc;
   Application.MessageBox('发布成功', '提示', MB_OK);
   title.Clear;
   content.Clear;
end;


procedure Tteacherwork.FormCreate(Sender: TObject);
begin
    ctype.Items.Add('pwn');
    ctype.Items.Add('web');
    ctype.Items.Add('reverse');
    ctype.Items.Add('crypto');
    ctype.Items.Add('misc');
    rankquery.Close;
    rankquery.SQL.Clear;
    rankquery.SQL.Text := 'select rank() over (order by score desc)as 排名 ,username, score, solveNum, title from student';
    rankquery.Prepared := True;
    rankquery.Open;
end;




end.
