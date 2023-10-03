CREATE PROCEDURE  [dbo].[Create_Campaign_Log_New] 
(
@result int out,
@log_id int,
@action_id int,
@admin_username_tmp varchar(255),
@admin_email varchar(255),
@campaign_name varchar(255),
@campaign_code varchar(255),
@campaign_amount Decimal(10,2),
@cents_per_wink Decimal(10,2),
@percent_for_wink Decimal(10,2),
@sales_code varchar(255),
@sales_commission Decimal(10,2),
@total_winks int,
@total_winks_amount Decimal(10,2),
@agency bit,
@agency_name varchar(255),
@campaign_start_date DateTime,
@campaign_end_date DateTime,
@created_at DateTime,
@updated_at DateTime,
@action_object varchar(255),
@action_type varchar(255),
@campaign_id int

)
AS
BEGIN 
DECLARE @current_date datetime
DECLARE @maxID int
DECLARE @user_id_tmp int

Set @user_id_tmp = (Select admin_user_id from admin_user where email = @admin_email) 
Set @log_id  = (Select admin_log.id from admin_log where user_id = @user_id_tmp AND status = 1)

Set @admin_username_tmp = (Select user_name from admin_log where admin_log.id = @log_id)

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT

INSERT INTO admin_action_log
           ([log_id]
           ,[action_time]
           ,[admin_user_name]
           ,[action_object]
           ,[action_type]
           ,[action_table_name]
           )
     VALUES
           (@log_id
           ,@current_date
           ,@admin_username_tmp
           ,@action_object
           ,@action_type
           ,'campaign_log_new');


 IF ((SELECT @@IDENTITY) > 0)
     BEGIN
      SET @action_id  =  (SELECT SCOPE_IDENTITY());
     END   

INSERT INTO campaign_log_new
           ([campaign_name]
		   ,[action_id]
           ,[campaign_code]
           ,[campaign_amount]
           ,[cents_per_wink]
           ,[percent_for_wink]
           ,[sales_code]
           ,[sales_commission]         
           ,[total_winks]
           ,[total_winks_amount]
           ,[agency]
           ,[agency_name]
           ,[campaign_start_date]
           ,[campaign_end_date]
           ,[created_at]
           ,[updated_at])
     VALUES
           (@campaign_name
		   ,@action_id
           ,@campaign_code
           ,@campaign_amount
           ,@cents_per_wink
           ,@percent_for_wink
           ,@sales_code
           ,@sales_commission         
           ,@total_winks
           ,@total_winks_amount
           ,@agency
           ,@agency_name
           ,@campaign_start_date
           ,@campaign_end_date
           ,@current_date
           ,@current_date);
          SET @maxID = (SELECT @@IDENTITY);
     
     IF (@maxID > 0)
     BEGIN
      SET @result  =  (SELECT SCOPE_IDENTITY());
     END   
     
 
END




