use InforsecSys
select * from student

create table honor(
title varchar(20) primary key,
flolimit int,
toplimit int
)
select * from news
select * from challenge
create table student(
id int identity(1,1) primary key,
username char(20) not null,
psd binary(20) not null,
email varchar(50),
solveNum int,
score int,
title varchar(20) foreign key references honor(title),
)
create table teacher(
id int identity(1,1) primary key,
username char(20) not null,
psd binary(20) not null,
email varchar(50),
upname int
)

create table challenge(
id int identity(1,1) primary key,
clas int,
nam char(20),
addr varchar(50) null,
val int,
flag binary(20),
uper int foreign key references teacher(id),
uptime date
)
create table solve(
stuid int,
chaid int,
solvetime date
)
create table news(
id int identity(1,1) primary key,
title varchar(50),
content varchar(100),
puber int foreign key references teacher(id),
pubtime date
)

--��ʼ���óƺŵȼ�
insert into honor values('·�˼�', 0 ,100)
insert into honor values('��ϰCTFer',100 ,250)
insert into honor values('��ʽ��ñ��',250,500)
insert into honor values('���İ�ñ��',500,1000)
insert into honor values('����ʥ��',1000,9999999)
select * from student

--ѧ���˻���֤
--drop function checkuser
create function checkuser  
(@username char(20), @password char(32))
returns int
as
begin
	declare @psd binary(20)
	set @psd = HASHBYTES('sha1', @password)
	if exists (select * from student where username = @username and psd = @psd)
	begin
		return (select id from student where username = @username)
	end
	else 
	begin
		return 0
	end
	return 0
end
--��ʦ�˺���֤
--drop function checkteacher
create function checkteacher
(@username char(20), @password char(32))
returns int
as
begin
	declare @psd binary(20)
	set @psd = HASHBYTES('sha1', @password)
	if exists (select * from teacher where username = @username and psd = @psd)
		return (select id from teacher where username = @username)
	return 0
end
--ע��ѧ���˺�
--drop proc createStudent
create proc createStudent
@username varchar(20),
@password char(32),
@email varchar(50) = '',
@res varchar(50) output
as
begin
	if (select count(*) from student where username = @username)>0
	begin
		set @res = '���û����ѱ�ʹ��'
		return 
	end
	declare @psd binary(20)
	set @psd = HASHBYTES('sha1', @password)
	insert into student values(@username, @psd, @email, 0,0, '·�˼�')
	set @res = 'ע��ɹ�'
end
--ע���ʦ�˺�
select * from teacher
--drop proc createTeacher
create proc createTeacher
@username varchar(20),
@password char(32),
@email varchar(50) = '',
@res varchar(50) output
as
begin
	if (select count(*) from teacher where username = @username)>0
	begin
		set @res = '���û����ѱ�ʹ��'
		return 
	end
	declare @psd binary(20)
	set @psd = HASHBYTES('sha1', @password)
	insert into teacher values(@username, @psd, @email, 0)
	set @res = 'ע��ɹ�'
end


--ѧ���˺Ÿ���//�޸��ǳơ��޸������

--��ʦ�ϴ���Ŀ
select * from challenge
--drop proc upchallenges
create proc upchallenges
@cname char(20), 
@ctype char(10),
@cvalue int,
@caddr char(50),
@cflag char(50),
@upper int
as
begin
	declare @chatype int;
	declare @flag binary(20);
	if @ctype = 'pwn'
		set @chatype = 1;
	else if @ctype = 'reverse'
		set @chatype = 2;
	else if @ctype = 'web'
		set @chatype = 3;
	else if @ctype = 'crypto'
		set @chatype = 4;
	else if @ctype = 'misc'
		set @chatype = 5;
	else 
		--raiserror(403,10,1,'illeagal choice!', );
		return;
	set @flag = HASHBYTES('sha1', @cflag);
	insert into challenge values(@chatype, @cname, @caddr,@cvalue, @flag, @upper, GETDATE());
end

select * from challenge
upchallenges 'challenge1', 'pwn', 100, 'www.baidu.com' , 'flag{test}', 1
upchallenges 'babyweb', 'web', 100, 'www.baidu.com' , 'flag{web}', 1

create proc checkflag
@flag char(50),
@sid int,
@res int output--���ص���Ŀ����
as
begin
	declare @cflag binary(20);
	set @cflag = HASHBYTES('sha1', @flag);
	if exists (select * from challenge where flag = @cflag)
	begin
		set @res = (select max(val) from challenge where flag = @cflag);
		declare @sc int;
		declare @nu int;
		declare @chaid int;
		set @chaid = (select id from challenge where flag = @cflag)
		set @sc = (select score from student where id = @sid);
		set @nu = (select solveNum from student where id = @sid);
		update student set score = @sc+@res where id = @sid;
		update student set solveNum = @nu +1 where id = @sid;
		--select * from student
		insert into solve values(@sid, @chaid, GETDATE());
		update student set title = 
			(select title from honor where
			 student.score>=honor.flolimit and student.score < honor.toplimit and student.id = @sid) where id = @sid
		return;
	end
	set @res = -1;
	return;
end
select * from student

update student set score = 50 where id = 6
--������Ϣ
create proc pubnews
@title varchar(50),
@content varchar(100),
@puber int
as 
begin
	insert into news values(@title, @content, @puber, GETDATE());
end

create proc changepsd
@newpsd char(32),
@sid int
as
begin
	declare @pass binary(20)
	set @pass = HASHBYTES('sha1', @newpsd)
	update student set psd = @pass where id = @sid
end
