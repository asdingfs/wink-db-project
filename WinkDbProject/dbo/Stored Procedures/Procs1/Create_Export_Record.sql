


CREATE PROCEDURE [dbo].[Create_Export_Record] 
(

	@result int out,

	@admin_email varchar(255),
	@action_object varchar(255),
	@action_type varchar(255),
	@export_content varchar(255)
    ,@advertiser_name varchar(255)
    ,@mas_code varchar(255)
    ,@search_from varchar(255)
    ,@search_to varchar(255)
    ,@campaign_name varchar(255)
    ,@contract_no varchar(255)
	,@wid varchar(50)
    ,@customer_id int
    ,@customer_name varchar(255)
    ,@customer_email varchar(255)
    ,@ip_address varchar(255)
    ,@scanned_ip varchar(255)
    ,@status varchar(50)
    ,@eVouchers varchar(255)
    ,@used_status varchar(50)
    ,@branch_name varchar(255)
    ,@branch_id int
    ,@expired varchar(50)
    ,@asset_type varchar(255)
    ,@qr_code varchar(255)
    ,@lucky_draw varchar(255)
    ,@asset_name varchar(255)
    ,@asset_code varchar(255)
    ,@advertiser_email varchar(255)
    ,@redemption_merchant_name varchar(255)
    ,@phone_no varchar(255)
    ,@in_app varchar(50)
    ,@subscribe varchar(50)
	,@gateId varchar(100)
	,@refereeCid int
    ,@refereeName varchar(255)
    ,@refereeEmail varchar(255)
	,@referrerCid int
    ,@referrerName varchar(255)
    ,@referrerEmail varchar(255)
)
AS
BEGIN 

	DECLARE @current_date datetime
	DECLARE @user_id_tmp int

	DECLARE @log_id int
	DECLARE @action_id int
	DECLARE @admin_username_tmp varchar(255)


	select @admin_email
	Set @user_id_tmp = (Select admin_user_id from admin_user where email = @admin_email) 
	select @user_id_tmp
	Set @log_id  = (Select top 1 admin_log.id from admin_log where user_id = @user_id_tmp order by id desc)
	select @log_id
	Set @admin_username_tmp = (Select user_name from admin_log where admin_log.id = @log_id)
	select @admin_username_tmp

	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	select @current_date
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
           ,'export_details_log'
		   ,'adminactiondetail/exportdetail');


 IF ((SELECT @@IDENTITY) > 0)
     BEGIN
      SET @action_id  =  (SELECT SCOPE_IDENTITY());

  BEGIN
   select @action_id AS action_id
  

	

	INSERT INTO export_details_log
    (
		[action_id]
		,[action_time]
		,[export_content]
		,[advertiser_name]
		,[mas_code]
		,[search_from]
		,[search_to]
		,[campaign_name]
		,[contract_no]
		,[wid]
		,[customer_id]
		,[customer_name]
		,[customer_email]
		,[ip_address]
		,[scanned_ip]
		,[status]
		,[eVouchers]
		,[used_status]
		,[branch_name]
		,[branch_id]
		,[expired]
		,[asset_type]
		,[qr_code]
		,[lucky_draw]
		,[asset_name]
		,[asset_code]
		,[advertiser_email]
		,[redemption_merchant_name]
		,[phone_no]
		,[in_app]
		,[subscribe]
		,[created_on]
		,[gateId]
		,[refereeCid]
		,[refereeName]
		,[refereeEmail]
		,[referrerCid]
		,[referrerName]
		,[referrerEmail])
     VALUES
           (
		   
	   @action_id
      ,@current_date
      ,@export_content
      ,@advertiser_name
      ,@mas_code
      ,@search_from
      ,@search_to
      ,@campaign_name
      ,@contract_no
	  ,@wid
      ,@customer_id
      ,@customer_name
      ,@customer_email
      ,@ip_address
      ,@scanned_ip
      ,@status
      ,@eVouchers
      ,@used_status
      ,@branch_name
      ,@branch_id
      ,@expired
      ,@asset_type
      ,@qr_code
      ,@lucky_draw
      ,@asset_name
      ,@asset_code
      ,@advertiser_email
      ,@redemption_merchant_name
      ,@phone_no
      ,@in_app
      ,@subscribe
	  ,@current_date
	  ,@gateId
	  ,@refereeCid
      ,@refereeName
      ,@refereeEmail
	  ,@referrerCid
      ,@referrerName
      ,@referrerEmail
    );


    IF ((SELECT @@IDENTITY) > 0)
     BEGIN
	 update admin_log set action_count = (select action_count from admin_log where admin_log.id = @log_id) + 1 where admin_log.id = @log_id
      SET @result  =  (SELECT SCOPE_IDENTITY());
     END  
SELECT @result
     

END 


END
END
