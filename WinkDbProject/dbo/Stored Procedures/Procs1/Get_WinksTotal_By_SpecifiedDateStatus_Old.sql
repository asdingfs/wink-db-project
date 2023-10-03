CREATE PROCEDURE [dbo].[Get_WinksTotal_By_SpecifiedDateStatus_Old]
	(
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
		converted_winks int,
		campaign_id int
 
	)

-- Redeemed Temp Table
	IF OBJECT_ID('tempdb..#Redeemed_Temp') IS NOT NULL DROP TABLE #Redeemed_Temp

	CREATE TABLE #Redeemed_Temp
	(
		total_winks int,
		converted_winks int,
		period int
	)

		-- Filte By Today
		IF (@status = 'today')
		BEGIN
		  SET @filter_date = CAST(@filter_date as Date)
		END
		ELSE IF (@status ='y') -- Filter By Yestersday
			BEGIN
					SET @filter_date = dateadd(day,-1, cast(@filter_date as date))

			END
		INSERT INTO #CAMPAIGN_Temp
		SELECT ISNULL(campaign.total_winks,0) AS total_winks,
		 (
			 ISNULL(
			(Select Sum(customer_earned_winks.total_winks) from customer_earned_winks where customer_earned_winks.campaign_id =campaign.campaign_id
			group by customer_earned_winks.campaign_id
	
		) ,0) )AS converted_winks,
		campaign.campaign_id
		
		
		 from campaign
				WHERE 
	
				(( campaign.wink_purchase_only=1 and campaign.wink_purchase_status ='activate')
				OR 
				( CAST(@filter_date as Date) BETWEEN CAST(campaign.campaign_start_date as Date) AND CAST(campaign.campaign_end_date as Date)))
				--( CAST(campaign.campaign_start_date as Date) BETWEEN @filter_date AND @filter_date))
				
		
	 Select ISNULL(SUM(#CAMPAIGN_Temp.total_winks),0) As total_winks from #CAMPAIGN_Temp
	 Where #CAMPAIGN_Temp.total_winks - #CAMPAIGN_Temp.converted_winks >0
	
END
--select * from customer_earned_winks

--Alter table campaign add redeemed_winks
