CREATE PROCEDURE [dbo].[GetPtsIssuanceCampaigns]
(
	@start_date varchar(50),
	@end_date varchar(50),
	@campaignName varchar(250)
)
	
AS
BEGIN
	DECLARE @CURRENT_DATE date;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	IF (@start_date is null or @start_date = '')
	BEGIN
		SET @start_date = NULL;
	END

	IF (@end_date is null or @end_date = '')
	BEGIN
		SET @end_date = NULL;
	END

	IF(@campaignName is null or @campaignName = '')
	BEGIN
		set @campaignName = null;
	END

	SELECT id, campaign_name as campaignName, points, created_at as createdOn
	FROM [winkwink].[dbo].[points_issuance_campaign] 
	WHERE (@campaignName is null or campaign_name like '%'+@campaignName+'%')
	AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
	order by created_at desc
END
