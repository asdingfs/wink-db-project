CREATE PROCEDURE  [dbo].[CreatePtsIssuanceCampaign] 
(
	@campaignName varchar(250),
	@points int,
	@admin_email varchar(100)
)
AS
BEGIN 

	IF(@admin_email is null or @admin_email = '')
	BEGIN
		SELECT 0 as success,'You are not authorised to create the campaign' as response_message
		return
	END

	IF(@campaignName is null or @campaignName = '')
	BEGIN
		SELECT 0 as success,'Please enter a valid campaign name' as response_message
		return
	END

	IF(@points = 0)
	BEGIN
		SELECT 0 as success,'Please enter a valid amount of points' as response_message
		return
	END


	DECLARE @maxID int
	DECLARE @campaignId int;
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
	

	INSERT INTO [dbo].[points_issuance_campaign]
           ([campaign_name]
           ,[points]
           ,[created_at]
           ,[updated_at])
     VALUES
           (@campaignName
           ,@points
           ,@CURRENT_DATETIME
           ,@CURRENT_DATETIME);

	SET @maxID = (SELECT @@IDENTITY);
     
	IF (@maxID > 0)
	BEGIN
		SET @campaignId  =  (SELECT SCOPE_IDENTITY());
		
		Declare @result int
		--- Call WINK+ Gate Campaign Log Store Procedure Function 
		EXEC CreatePtsIssuanceCampaignLog
		@campaignId, @campaignName, @points,
		@admin_email,'Campaign Points Issuance','New', @result output ;
		--print (@result)
		if(@result=2)
		BEGIN
			DELETE FROM points_issuance_campaign WHERE id = @campaignId;
			SELECT 0 as success,'Please try again later' as response_message
			return
		END
		ELSE
		BEGIN
			SELECT 1 as success,'A campaign has been successfully created' as response_message,
			@campaignId as campaignId;
			return
		END
	END
	ELSE
	BEGIN
		SELECT 0 as success,'Please try again later.' as response_message
		return
	END

END

