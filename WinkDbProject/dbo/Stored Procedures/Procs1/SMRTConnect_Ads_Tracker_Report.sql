CREATE PROCEDURE [dbo].[SMRTConnect_Ads_Tracker_Report]
(
  @from_date varchar(20),
  @to_date varchar(20),
  @mobile_platform varchar(100),
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

IF (@mobile_platform is null or @mobile_platform ='')
	BEGIN
	set @mobile_platform = NULL
	END
ELSE
	BEGIN
		IF(@mobile_platform = 'iOS')
			BEGIN
				SET @platformName = 'iphone'
			END
		ELSE IF(@mobile_platform = 'Android')
			BEGIN
				SET @platformName = 'android'
			END
END
IF(@from_date is null or @from_date ='' or @to_date is null or @to_date is null)
	BEGIN
		set @from_date = NULL
		set @to_date = NULL

	END

	select created_at, os,ip_address

	from smrtconnect_app_tracker

	where (@ip_address is null or ip_address like '%'+@ip_address+'%')

	and (@platformName is null or os like '%'+@platformName+'%')
	and (@from_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
	order by created_at desc

END

