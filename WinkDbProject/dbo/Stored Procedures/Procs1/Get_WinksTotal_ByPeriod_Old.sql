CREATE PROCEDURE [dbo].[Get_WinksTotal_ByPeriod_Old]
	(
	  @from_date datetime,
	  @to_date datetime
	  	 
	 )
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
				campaign.campaign_status ='enable' AND
				(( campaign.wink_purchase_only=1 and campaign.wink_purchase_status ='activate')
				OR 
				/*( CAST(campaign.campaign_start_date as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))*/
				( CAST(@from_date as Date) BETWEEN CAST(campaign.campaign_start_date as Date) AND CAST(campaign.campaign_end_date as Date))
								
				OR 
				/*( CAST(campaign.campaign_end_date AS Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))*/
				( CAST(@to_date as Date) BETWEEN CAST(campaign.campaign_start_date as Date) AND CAST(campaign.campaign_end_date as Date))
				)
				
				
				
		
	 Select SUM(#CAMPAIGN_Temp.total_winks) As total_winks from #CAMPAIGN_Temp
	 Where #CAMPAIGN_Temp.total_winks - #CAMPAIGN_Temp.converted_winks >0
	
END
--select * from customer_earned_winks

--Alter table campaign add redeemed_winks
