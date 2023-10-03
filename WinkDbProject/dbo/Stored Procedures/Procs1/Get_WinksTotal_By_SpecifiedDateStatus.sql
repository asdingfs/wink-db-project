CREATE PROCEDURE [dbo].[Get_WinksTotal_By_SpecifiedDateStatus]
	(
	 @status varchar(25))
AS
BEGIN
DECLARE @filter_date datetime 
EXEC GET_CURRENT_SINGAPORT_DATETIME @filter_date OUTPUT
		-- Filte By Today
		IF (@status = 'today')
		BEGIN
		  SET @filter_date = CAST(@filter_date as Date)
		END
		ELSE IF (@status ='y') -- Filter By Yestersday
			BEGIN
					SET @filter_date = dateadd(day,-1, cast(@filter_date as date))

			END
	
	 SELECT CAST ( ISNULL(SUM(campaign.total_winks),0) AS int) AS total_winks
	 from campaign
	 WHERE 
	(( campaign.wink_purchase_only=1 and campaign.wink_purchase_status ='activate')
	OR 
	( CAST(@filter_date as Date) BETWEEN CAST(campaign.campaign_start_date as Date) AND CAST(campaign.campaign_end_date as Date)))
	AND campaign.campaign_status = 'enable'
	
END
--select * from customer_earned_winks

--Alter table campaign add redeemed_winks
