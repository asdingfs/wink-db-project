
create proc test_register
@user_name varchar(50),
@class varchar(50)

as 

begin
	select @user_name as username, @class as class
end