CREATE PROCEDURE [dbo].[Microsite_Ads_Tracker_Report]
(
  @from_date varchar(20),
  @to_date varchar(20),
  @source varchar(100),
  @ip_address varchar(20)
)
As
BEGIN
Declare @current_datetime datetime
Declare @platformName varchar(50)

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output



IF (@ip_address is null or @ip_address ='')
BEGIN
set @ip_address = NULL
END

IF (@source is null or @source ='')
BEGIN
set @source = NULL
END

IF(@from_date is null or @from_date ='' or @to_date is null or @to_date is null)
	BEGIN
		set @from_date = NULL
		set @to_date = NULL

	END

	select created_at, source,ip_address
	from microsite_ads_tracker
	where (@ip_address is null or ip_address like '%'+@ip_address+'%')
	and (@source is null or source like '%'+@source+'%')
	and (@from_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
	order by created_at desc

END

