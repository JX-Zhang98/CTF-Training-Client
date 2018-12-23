unit tealog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls, IdHashMessageDigest, DB, ADODB;

type
  Ttealogin = class(TForm)
    logback: TImage;
    username: TLabel;
    password: TLabel;
    usr: TEdit;
    psd: TEdit;
    ok: TButton;
    toReg: TButton;
    db: TADOConnection;
    query: TADOQuery;
    procedure okClick(Sender: TObject);
    procedure toRegClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  tealogin: Ttealogin;

implementation

{$R *.dfm}

uses reg, teawork, common;

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
res: System.Int8;


procedure Ttealogin.okClick(Sender: TObject);
begin
    //这里进行初步的用户名密码格式合法性验证
     if pos('--', usr.Text)+pos('''',usr.Text)>0 then
     begin
          Application.MessageBox('Don''t be evil!','Warning!', MB_ICONWARNING);
          exit;
     end;
      //传入数据库进行查询
      query.SQL.Clear;
      //sql := 'select dbo.checkuser("' +  usr.Text + '", "' + psd.Text + '")';
      query.SQL.Add('select dbo.checkteacher(:usr, :psd)');
      query.Parameters[0].Value := usr.Text;
      query.Parameters[1].Value := MD5(psd.Text);
      query.Prepared := True;
      query.Open;
      res := query.Fields[0].AsInteger;
      if res>0 then
      begin
          logedid := res;
          Application.MessageBox('登录成功', '提示', MB_OK);
          Application.CreateForm(Tteacherwork, teacherwork);
          teacherwork.Show;
          tealogin.Hide;
      end
      else
      begin
          Application.MessageBox('用户名或密码错误', '提示', MB_ICONERROR);
          psd.Clear;
      end;
end;

procedure Ttealogin.toRegClick(Sender: TObject);
begin
    usr.Clear;
    psd.Clear;
    tealogin.Hide;
    Application.CreateForm(Tregist, regist);
    regist.Show;
end;

end.
