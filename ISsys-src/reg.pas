unit reg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, IdHashMessageDigest, DB, ADODB, pngimage;

type
  Tregist = class(TForm)
    Confirm: TButton;
    usr: TEdit;
    email: TEdit;
    psd: TEdit;
    repsd: TEdit;
    regback: TImage;
    usrname: TLabel;
    regemail: TLabel;
    passwd: TLabel;
    repasswd: TLabel;
    proc: TADOStoredProc;
    ident: TLabel;
    chooseIdent: TComboBox;
    procedure ConfirmClick(Sender: TObject);
    procedure usrExit(Sender: TObject);
    procedure emailExit(Sender: TObject);
    procedure psdExit(Sender: TObject);
    procedure repsdExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  regist: Tregist;

implementation

{$R *.dfm}
uses log, tealog, common;

function MD5(const str:string):String;
var
    AMD5:TIdHashMessageDigest5;
begin
    AMD5:=TIdHashMessageDigest5.Create;
    Result:=AMD5.HashStringAsHex(str,TEncoding.UTF8);
    AMD5.Free;
end;


procedure Tregist.ConfirmClick(Sender: TObject);
var
res:string;
begin
    if (usr.Text='') Or (email.Text='')
      or (psd.Text='') or (repsd.Text='') then
      begin
         Application.MessageBox('������������Ϣ', '��ʾ', MB_ICONWARNING);
         exit;
      end;
    res := '';
    if chooseident.Text='ѧ��' then
    begin
        proc.ProcedureName := 'createStudent';
        proc.Connection := login.db;
    end
    else if chooseident.Text='��ʦ' then
    begin
      proc.ProcedureName := 'createTeacher';
      proc.Connection := tealogin.db;
    end
    else
    begin
        chooseident.Text;
        Application.MessageBox('��ѡ��ע�����', '��ʾ', MB_ICONWARNING);
        exit;
    end;
    proc.Parameters.Clear;
    proc.Close;
    proc.Parameters.CreateParameter('username', ftstring, pdinput, 20, NULL);
    proc.Parameters.CreateParameter('password', ftstring, pdinput, 32, NULL);
    proc.Parameters.CreateParameter('email', ftstring, pdinput, 50, NULL);
    proc.Parameters.CreateParameter('res', ftstring, pdOutput, 20, NULL);
    proc.Parameters[0].Value := usr.Text;
    proc.Parameters[1].Value := MD5(psd.Text);
    proc.Parameters[2].Value := email.Text;
    proc.Parameters[3].Value := res;
    proc.Prepared := true;
    proc.ExecProc;
    res := proc.Parameters.ParamByName('res').Value;
    if pos(res, 'ע��ɹ�')>0 then
    begin
        Application.MessageBox('ע��ɹ���', '��ʾ', MB_OK);
        regist.Hide;
        regist.CloseModal;
        if chooseident.Text='ѧ��' then
        begin
           login.ShowModal;
        end
        else if chooseident.Text='��ʦ' then
        begin
          tealogin.ShowModal;
        end;
    end;
    if pos(res, '���û����ѱ�ʹ��')>0 then
    begin
        Application.MessageBox('���û����ѱ�ʹ�ã�', '��ʾ', MB_ICONWARNING);
        usr.Clear;
        usr.SetFocus;
    end;
end;

procedure Tregist.emailExit(Sender: TObject);
begin
    if pos('@',email.Text)=0 then
    begin
      Application.MessageBox('��������ȷ������', '��ʾ', MB_ICONWARNING);
      email.Clear;
      email.SetFocus;
    end;
end;

procedure Tregist.FormCreate(Sender: TObject);
begin
  chooseident.Items.Add('ѧ��');
  chooseident.Items.Add('��ʦ');
  //usr.SetFocus;
end;

procedure Tregist.psdExit(Sender: TObject);
begin
    if Length(psd.Text)<6 then
    begin
      Application.MessageBox('������ڼ�', '��ʾ', MB_ICONWARNING);
      email.Clear;
      email.SetFocus;
    end;

end;

procedure Tregist.repsdExit(Sender: TObject);
begin
    if psd.Text<>repsd.Text then
    begin
      Application.MessageBox('�����������벻һ�£�����������', '��ʾ', MB_ICONWARNING);
      repsd.Clear;
      repsd.SetFocus;
    end;

end;

procedure Tregist.usrExit(Sender: TObject);
begin
    //������г������û��������ʽ�Ϸ�����֤
     if pos('--', usr.Text)+pos('''',usr.Text)>0 then
     begin
          Application.MessageBox('���зǷ��ַ�''",--','����', MB_ICONWARNING);
          usr.Clear;
          usr.SetFocus;
     end;
end;


end.
