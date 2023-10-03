CREATE PROCEDURE [dbo].[GetTotalWink_ConvertedWink_ByDate]
	(@start_date datetime,
	 @end_date datetime,
	 @status varchar(25))
AS
BEGIN
DECLARE @filter_date datetime 
EXEC GET_CURRENT_SINGAPORT_DATETIME @filter_date OUTPUT
-- Campaign Temp Table
	IF OBJECT_ID('tempdb..#CAMPAIGN_Temp') IS NOT NULL DROP TABLE #CAMPAIGN_Temp

	CREATE TABLE #CAMPAIGN_Temp
	(
		total_winks int,
		redeemed_winks int,
		 period int
 
	)

-- Redeemed Temp Table
	IF OBJECT_ID('tempdb..#Redeemed_Temp') IS NOT NULL DROP TABLE #Redeemed_Temp

	CREATE TABLE #Redeemed_Temp
	(
		total_winks int,
		redeemed_winks int,
		period int
	)

		-- Filte By Today
		IF (@status = 'today')
		BEGIN
		  SET @filter_date = CAST(@filter_date as Date)
		END
		ELSE IF (@status ='y')
			BEGIN
					SET @filter_date = dateadd(day,-1, cast(@filter_date as date))

			END
				-- Insert Total WINKs to Temp Table
				INSERT INTO #CAMPAIGN_Temp (#CAMPAIGN_Temp.total_winks)
				(SELECT SUM(campaign.total_winks) from campaign
				WHERE 
	
				(( campaign.wink_purchase_only=1 and campaign.wink_purchase_status ='activate')
				OR 
				( CAST(campaign.campaign_start_date as Date) BETWEEN @filter_date AND @filter_date))
	
				)
				
				-- Insert Redeemed WINKs Temp Table
				INSERT INTO #Redeemed_Temp (#Redeemed_Temp.redeemed_winks,
				#Redeemed_Temp.period) 
				SELECT  SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks ,
				datepart(HOUR,customer_earned_winks.created_at) as period
				from customer_earned_winks
				WHERE CAST(customer_earned_winks.created_at As Date) = @filter_date
				GROUP BY datepart(HOUR,customer_earned_winks.created_at)
				
				Select * FROM #CAMPAIGN_Temp
				UNION
				Select * from #Redeemed_Temp


END
--select * from customer_earned_winks
