program Project1;

uses
  Forms,
  log in 'log.pas' {login},
  reg in 'reg.pas' {regist},
  mainwin in 'mainwin.pas' {mainwnd},
  teawork in 'teawork.pas' {teacherwork},
  tealog in 'tealog.pas' {tealogin},
  common in 'common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  //Application.CreateForm(Tlogin, login);       //学生
  Application.CreateForm(Ttealogin, tealogin);     //教师
  Application.Run;
end.
