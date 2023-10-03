
CREATE PROCEDURE  [dbo].[Create_Customer_Deleted_Log] 
(

@result int out,
@customer_id int,
@name varchar(255),
@email varchar(255),
@customersince DateTime,
@gender varchar(255),
@dob varchar(50),
@card_id_1 varchar(255),
@card_id_2 varchar(255),
@card_id_3 varchar(255),

@admin_email varchar(255),
@action_object varchar(255),
@action_type varchar(255)
)
AS
BEGIN 
DECLARE @current_date datetime
DECLARE @user_id_tmp int

DECLARE @log_id int
DECLARE @action_id int
DECLARE @admin_username_tmp varchar(255)

IF @dob IS NULL OR @dob ='' OR @dob=' '
SET @dob = NULL

Set @user_id_tmp = (Select admin_user_id from admin_user where email = @admin_email) 
select @user_id_tmp AS user_id_tmp
Set @log_id  = (Select top 1 admin_log.id from admin_log where user_id = @user_id_tmp order by id desc)
select @log_id AS log_id
Set @admin_username_tmp = (Select user_name from admin_log where admin_log.id = @log_id)
select @admin_username_tmp AS admin_username_tmp

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

INSERT INTO action_log
           ([log_id]
           ,[action_time]
           ,[admin_user_name]
		   ,[admin_user_email]
           ,[action_object]
           ,[action_type]
           ,[action_table_name]
		   ,[link_url]
           )
     VALUES
           (@log_id
           ,@current_date
           ,@admin_username_tmp
		   ,@admin_email
           ,@action_object
           ,@action_type
           ,'custmer_deletion_log'
		   ,'adminactiondetail/customerdetail');


 IF ((SELECT @@IDENTITY) > 0)
     BEGIN
      SET @action_id  =  (SELECT SCOPE_IDENTITY());
     END   

	 --select @action_id AS action_id

INSERT INTO custmer_deletion_log
           ([action_id]
           ,[customer_id]
           ,[Name]
           ,[Email]
           ,[CustomerSince]
           ,[Gender]
           ,[Dob]
           ,[Card_ID_1]
           ,[Card_ID_2]
           ,[Card_ID_3])
     VALUES
           (@action_id
		   ,@customer_id
		   ,@name
           ,@email
           ,@customersince
           ,@gender
           ,@dob
           ,@card_id_1
           ,@card_id_2         
           ,@card_id_3
          );
    IF ((SELECT @@IDENTITY) > 0)
     BEGIN
	 update admin_log set action_count = (select action_count from admin_log where admin_log.id = @log_id) + 1 where admin_log.id = @log_id
      SET @result  =  (SELECT SCOPE_IDENTITY());
     END  
SELECT @result
     
 
END
