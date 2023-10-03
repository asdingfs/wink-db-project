CREATE PROCEDURE [dbo].[Get_WinksTotal_ByPeriod]
	(
	  @from_date datetime,
	  @to_date datetime
	  	 
	 )
AS
BEGIN
DECLARE @campaign_normal_total_winks int
DECLARE @campaign_po_total_winks int
	
SET @campaign_normal_total_winks =	( SELECT sum(campaign.total_winks) from campaign WHERE 
	 campaign.campaign_status ='enable'
		AND 
		(
		(CONVERT(CHAR(10),@from_date,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		 AND CONVERT(CHAR(10),@from_date,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)
		 )
		 OR
		 
		(CONVERT(CHAR(10),@to_date,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) 
		AND CONVERT(CHAR(10),@to_date,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111))
		
		OR Lower(campaign.wink_purchase_status) ='activate'
		))
		select @campaign_normal_total_winks as total_winks
END
