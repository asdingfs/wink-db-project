




CREATE PROCEDURE  [dbo].[Create_Customer_Updated_Log_With_PointsConfis] 
(

@result int out,
@customer_id int,

@old_name varchar(255),
@new_name varchar(255),

@old_email varchar(255),
@new_email varchar(255),

@customersince DateTime,

@old_gender varchar(255),
@new_gender varchar(255),

@old_dob varchar(50),
@new_dob varchar(50),

@old_status varchar(50),
@new_status varchar(50),

@old_card_id_1 varchar(255),
@new_card_id_1 varchar(255),

@old_card_id_2 varchar(255),
@new_card_id_2 varchar(255),

@old_card_id_3 varchar(255),
@new_card_id_3 varchar(255),

@old_confiscated_wink_status varchar(10),
@new_confiscated_wink_status varchar(10),

@old_confiscated_point_status varchar(10),
@new_confiscated_point_status varchar(10),

@admin_email varchar(255),
@action_object varchar(255),
@action_type varchar(255)

)
AS
BEGIN 

DECLARE @WINK_CONFIS_CHECK  varchar(5)
DECLARE @POINT_CONFIS_CHECK  varchar(5)

DECLARE @current_date datetime
DECLARE @user_id_tmp int

DECLARE @log_id int
DECLARE @action_id int
DECLARE @unlock_action_id int
DECLARE @admin_username_tmp varchar(255)

DECLARE @OLD_WINK_CONFIS_AMOUNT  varchar(255)
DECLARE @NEW_WINK_CONFIS_AMOUNT  varchar(255)

SET @OLD_WINK_CONFIS_AMOUNT = '0';
SET @NEW_WINK_CONFIS_AMOUNT = '0';



DECLARE @OLD_POINTS_CONFIS_AMOUNT  varchar(255)
DECLARE @NEW_POINTS_CONFIS_AMOUNT  varchar(255)


SET @OLD_POINTS_CONFIS_AMOUNT = '0';
SET @NEW_POINTS_CONFIS_AMOUNT = '0';


IF @old_dob IS NULL OR @old_dob ='' OR @old_dob=' '
IF @new_dob IS NULL OR @new_dob ='' OR @new_dob=' '

--SET @dob = NULL
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
           ,'custmer_deletion_log'
		   ,'adminactiondetail/customerediteddetail');


 IF ((SELECT @@IDENTITY) > 0)
     BEGIN
      SET @action_id  =  (SELECT SCOPE_IDENTITY());

	  
  --REPLACE(CONVERT(CHAR(10),wink_confiscated_detail.created_at,111), '/', '-')  < CONVERT(CHAR(10),@current_date,111)));

  IF (@old_status like 'disable' AND @new_status like 'enable')
  BEGIN
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
           ,'Customer'
		   ,'Unlock'
		   ,'custmer_deletion_log'
		   ,'adminactiondetail/customerediteddetail');
	IF ((SELECT @@IDENTITY) > 0)
	BEGIN
		SET @unlock_action_id = (SELECT SCOPE_IDENTITY());
		update admin_log set action_count = (select action_count from admin_log where admin_log.id = @log_id) + 1 where admin_log.id = @log_id;
				 
	END  
  END

  IF( @old_confiscated_wink_status = '0' AND @new_confiscated_wink_status = '1' )
  BEGIN

  SET @OLD_WINK_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail where 
  
  wink_confiscated_detail.customer_id = @customer_id
  AND 
  CONVERT(CHAR(10),wink_confiscated_detail.created_at,111) < CONVERT(CHAR(10),@current_date,111)));


  SET @NEW_WINK_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail where 
  wink_confiscated_detail.customer_id = @customer_id
     AND CONVERT(CHAR(10),wink_confiscated_detail.created_at,111) = CONVERT(CHAR(10),@current_date,111)));
  


  END
  
  IF( @old_confiscated_wink_status = '1' AND @new_confiscated_wink_status = '1' )
  BEGIN

   SET @OLD_WINK_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail where 
  wink_confiscated_detail.customer_id = @customer_id));

  SET @NEW_WINK_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail where 
  wink_confiscated_detail.customer_id = @customer_id));


  END

  IF( @old_confiscated_point_status = '0' AND @new_confiscated_point_status = '1' )
  BEGIN

  SET @OLD_POINTS_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail where 
  
  points_confiscated_detail.customer_id = @customer_id
  AND 
   CONVERT(CHAR(10),points_confiscated_detail.created_at,111) < CONVERT(CHAR(10),@current_date,111)));

    SET @NEW_POINTS_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail where 
  
  points_confiscated_detail.customer_id = @customer_id
  AND 
  CONVERT(CHAR(10),points_confiscated_detail.created_at,111) = CONVERT(CHAR(10),@current_date,111)));

  END

  IF( @old_confiscated_point_status = '1' AND @new_confiscated_point_status = '1' )
  BEGIN

	SET @OLD_POINTS_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail where 
  
  points_confiscated_detail.customer_id = @customer_id));
 
    SET @NEW_POINTS_CONFIS_AMOUNT = CONVERT(varchar(10), (select isnull(sum(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail where 
  
  points_confiscated_detail.customer_id = @customer_id));
 

  END
  
   
   END

	 select @action_id AS action_id

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
           ,[Card_ID_3]
		   ,[Status]
		   ,[confiscated_wink_status]
		   ,[confiscated_points_status])
     VALUES
           (@action_id
		   ,@customer_id
		   ,@new_name
           ,@new_email
           ,@customersince
           ,@new_gender
           ,@new_dob
           ,@new_card_id_1
           ,@new_card_id_2         
           ,@new_card_id_3
		   ,@new_status
		   ,@NEW_WINK_CONFIS_AMOUNT
		   ,@NEW_POINTS_CONFIS_AMOUNT

          );


		  INSERT INTO custmer_old_detail_log
           ([action_id]
           ,[customer_id]
           ,[Name]
           ,[Email]
           ,[CustomerSince]
           ,[Gender]
           ,[Dob]
           ,[Card_ID_1]
           ,[Card_ID_2]
           ,[Card_ID_3]
		   ,[Status]
		   ,[confiscated_wink_status]
		   ,[confiscated_points_status])
     VALUES
           (@action_id
		   ,@customer_id
		   ,@old_name
           ,@old_email
           ,@customersince
           ,@old_gender
           ,@old_dob
           ,@old_card_id_1
           ,@old_card_id_2         
           ,@old_card_id_3
		   ,@old_status
		   ,@OLD_WINK_CONFIS_AMOUNT
		   ,@OLD_POINTS_CONFIS_AMOUNT
          );

	IF(@unlock_action_id != 0)
	BEGIN
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
           ,[Card_ID_3]
		   ,[Status]
		   ,[confiscated_wink_status]
		   ,[confiscated_points_status])
     VALUES
           (@unlock_action_id
		   ,@customer_id
		   ,@new_name
           ,@new_email
           ,@customersince
           ,@new_gender
           ,@new_dob
           ,@new_card_id_1
           ,@new_card_id_2         
           ,@new_card_id_3
		   ,@new_status
		   ,@NEW_WINK_CONFIS_AMOUNT
		   ,@NEW_POINTS_CONFIS_AMOUNT

          );


		  INSERT INTO custmer_old_detail_log
           ([action_id]
           ,[customer_id]
           ,[Name]
           ,[Email]
           ,[CustomerSince]
           ,[Gender]
           ,[Dob]
           ,[Card_ID_1]
           ,[Card_ID_2]
           ,[Card_ID_3]
		   ,[Status]
		   ,[confiscated_wink_status]
		   ,[confiscated_points_status])
     VALUES
           (@unlock_action_id
		   ,@customer_id
		   ,@old_name
           ,@old_email
           ,@customersince
           ,@old_gender
           ,@old_dob
           ,@old_card_id_1
           ,@old_card_id_2         
           ,@old_card_id_3
		   ,@old_status
		   ,@OLD_WINK_CONFIS_AMOUNT
		   ,@OLD_POINTS_CONFIS_AMOUNT
          );			
	END

    IF ((SELECT @@IDENTITY) > 0)
     BEGIN
	 update admin_log set action_count = (select action_count from admin_log where admin_log.id = @log_id) + 1 where admin_log.id = @log_id
      SET @result  =  (SELECT SCOPE_IDENTITY());
     END  
SELECT @result
     

END 



