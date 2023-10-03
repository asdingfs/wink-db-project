
CREATE PROCEDURE [dbo].[WINK_GO_Banners_List]
	(@campaignId int,
	@campaignName varchar(250),
	@start_date varchar(100),
	@end_date varchar(100),
	@status varchar(10))
AS
BEGIN

	IF(@campaignId = 0)
		SET @campaignId = NULL;

	IF(@campaignName is null or @campaignName ='')
		SET @campaignName = NULL

	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF(@status is null or @status ='')
		SET @status = NULL

	SELECT a.campaign_id, c.campaign_name, a.from_date, a.to_date, a.[image], a.[url], a.points, a.interval, a.[status], a.created_at, a.id
	FROM ASSET_WINKGO AS a 
	LEFT JOIN  campaign AS c 
	ON c.campaign_id = a.campaign_id 
	WHERE (@campaignId is null or a.campaign_id = @campaignId)
	AND (@campaignName is null or c.campaign_name like '%'+@campaignName+'%')
	AND (@status is null or a.[status] like '%'+@status+'%')
	AND (
			(
				(@start_date IS NULL OR (@start_date between c.campaign_start_date AND c.campaign_end_date))
				AND
				(@end_date IS NULL OR (@end_date between c.campaign_start_date AND c.campaign_end_date))
			)
			or
			(
				(@start_date IS NULL OR c.campaign_start_date between @start_date and @end_date) 
				AND 
				(@start_date IS NULL OR c.campaign_end_date between @start_date and @end_date)
			)
			or
			(
				(@start_date IS NULL OR c.campaign_start_date not between @start_date and @end_date) 
				AND 
				(@start_date IS NULL OR c.campaign_end_date between @start_date and @end_date)
			)
			or
			(
				(@start_date IS NULL OR c.campaign_start_date between @start_date and @end_date) 
				AND 
				(@start_date IS NULL OR c.campaign_end_date not between @start_date and @end_date)
			)
		) 

	ORDER BY a.id DESC

END

