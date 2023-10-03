CREATE PROC [dbo].[GET_WINKTAG_ACTIVE_CAMPAIGN]

AS
BEGIN
	SELECT campaign_id, campaign_name FROM WINKTAG_CAMPAIGN 
	WHERE WINKTAG_STATUS = '1' and internal_testing_status = 0 
	AND CAST(dateadd(hour,8,getdate()) as datetime) >= CAST(from_date as datetime)
	AND CAST(dateadd(hour,8,getdate()) as datetime) <= CAST(to_date as datetime)
	AND winktag_type not like 'wink_fee'
	order by position
	  
END
