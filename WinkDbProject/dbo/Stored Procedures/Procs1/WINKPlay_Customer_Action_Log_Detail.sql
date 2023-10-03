CREATE PROC [dbo].[WINKPlay_Customer_Action_Log_Detail]
@campaign_id int,
@customer_id int,
@location varchar(250),
@ip_address varchar(50)

AS 

BEGIN

	DECLARE @SURVEY_COMPLETE_STATUS BIT = 0
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	IF EXISTS(SELECT * FROM winktag_customer_earned_points WHERE customer_id = @customer_id AND campaign_id = @campaign_id
		  AND ( @campaign_id != 146  or 
				(@campaign_id = 146 and cast(created_at as date) = cast(@CURRENT_DATETIME as date))))
		SET @SURVEY_COMPLETE_STATUS = 1
	

	INSERT INTO [dbo].[winktag_customer_action_log]
           ([customer_id]
           ,[campaign_id]
           ,[customer_action]
           ,[ip_address]
           ,[location]
		   ,[survey_complete_status]
           ,[created_at])
     VALUES
           (@customer_id,@campaign_id,(SELECT winktag_type FROM winktag_campaign WHERE campaign_id = @campaign_id),@ip_address,@location,@SURVEY_COMPLETE_STATUS,(SELECT TODAY FROM VW_CURRENT_SG_TIME)) 
END
