unit log;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, DB, ADODB, DBTables, IdHashMessageDigest;

type
  Tlogin = class(TForm)
    usr: TEdit;
    psd: TEdit;
    ok: TButton;
    toReg: TButton;
    back: TImage;
    username: TLabel;
    password: TLabel;
    db: TADOConnection;
    query: TADOQuery;
    procedure toRegClick(Sender: TObject);
    procedure okClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  login: Tlogin;

implementation

{$R *.dfm}
uses reg, mainwin, common;

function MD5(const str:string):String;
var
    AMD5:TIdHashMessageDigest5;
begin
    AMD5:=TIdHashMessageDigest5.Create;
    Result:=AMD5.HashStringAsHex(str,TEncoding.UTF8);
    AMD5.Free;
end;
var
sql: String;
res: integer;

procedure Tlogin.okClick(Sender: TObject);
begin
     //������г������û��������ʽ�Ϸ�����֤
     if pos('--', usr.Text)+pos('''',usr.Text)>0 then
     begin
          Application.MessageBox('Don''t be evil!','Warning!', MB_ICONWARNING);
          exit;
     end;
      //�������ݿ���в�ѯ
      query.SQL.Clear;
      query.SQL.Add('select dbo.checkuser(:usr, :psd)');
      query.Parameters[0].Value := usr.Text;
      query.Parameters[1].Value := MD5(psd.Text);
      query.Prepared := True;
      query.Open;
      res := query.Fields[0].AsInteger;
      if res>0 then
      begin
          logedid := res;
          Application.MessageBox('��¼�ɹ�', '��ʾ', MB_OK);
          Application.CreateForm(Tmainwnd, mainwnd);
          mainwnd.Show;
          login.Hide;
      end
      else
      begin
          Application.MessageBox('�û������������', '��ʾ', MB_ICONERROR);
          psd.Clear;
      end;
end;

procedure Tlogin.toRegClick(Sender: TObject);
begin
    usr.Clear;
    psd.Clear;
    login.Hide;
    Application.CreateForm(Tregist, regist);
    regist.Show;
    //usr.SetFocus;
end;
end.
