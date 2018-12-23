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

--初始设置称号等级
insert into honor values('路人甲', 0 ,100)
insert into honor values('见习CTFer',100 ,250)
insert into honor values('正式白帽子',250,500)
insert into honor values('核心白帽子',500,1000)
insert into honor values('妇科圣手',1000,9999999)
select * from student

--学生账户验证
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
--教师账号验证
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
--注册学生账号
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
		set @res = '该用户名已被使用'
		return 
	end
	declare @psd binary(20)
	set @psd = HASHBYTES('sha1', @password)
	insert into student values(@username, @psd, @email, 0,0, '路人甲')
	set @res = '注册成功'
end
--注册教师账号
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
		set @res = '该用户名已被使用'
		return 
	end
	declare @psd binary(20)
	set @psd = HASHBYTES('sha1', @password)
	insert into teacher values(@username, @psd, @email, 0)
	set @res = '注册成功'
end


--学生账号更新//修改昵称、修改密码等

--教师上传题目
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
@res int output--返回的题目分数
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
--发布消息
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
