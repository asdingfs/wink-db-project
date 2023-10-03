CREATE PROC [dbo].[WINKTAG_CREATE_CAMPAIGN]
@campaign_name varchar(100),
@points int,
@content varchar(100),
@winktag_type  varchar(100),
@position int,
@winktag_report varchar(100),
@size int,
@campaign_image_large varchar(200),
@campaign_image_small varchar(200),
@from_date DateTime,
@to_date DateTime

AS
BEGIN

	INSERT INTO [dbo].[winktag_campaign]
			   ([campaign_name]
			   ,[campaign_image_large]
			   ,[campaign_image_small]
			   ,[points]
			   ,[interval_status]
			   ,[interval]
			   ,[limit]
			   ,[winktag_type]
			   ,[winktag_status]
			   ,[created_at]
			   ,[updated_at]
			   ,[from_date]
			   ,[to_date]
			   ,[interval_type]
			   ,[content]
			   ,[survey_type]
			   ,[position]
			   ,[winktag_report]
			   ,[size]
			   ,[min_count]
			   ,[max_count]
			   ,[internal_testing_status])
		 VALUES
			   (@campaign_name,@campaign_image_large,@campaign_image_small ,@points,0,0,1,@winktag_type,1,(select today from VW_CURRENT_SG_TIME),(select today from VW_CURRENT_SG_TIME)
			   ,@from_date,@to_date
			   ,'',@content,'all',@position,@winktag_report,@size,0,0,1)

  If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully created' as response_message
Else 
select '0' as response_code , 'Fail to create new record' as response_message
END


