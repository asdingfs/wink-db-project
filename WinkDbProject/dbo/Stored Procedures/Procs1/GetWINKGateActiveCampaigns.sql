CREATE PROCEDURE [dbo].[GetWINKGateActiveCampaigns]
(
	@authToken VARCHAR(255)
)
	
AS
BEGIN
	DECLARE @CURRENT_DATE date;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	
    IF EXISTS (select 1 from customer where customer.auth_token = @authToken and status ='disable')
    BEGIN
		RETURN 
	END
	
    
	IF NOT EXISTS (SELECT 1 FROM CUSTOMER WHERE auth_token = @authToken )
	BEGIN
		RETURN 
	END 

	SELECT distinct(c.campaign_id) as campaignId
	FROM wink_gate_booking as wb
	left join wink_gate_campaign as wc
	on wb.wink_gate_campaign_id = wc.id
	left join campaign as c
	on wc.campaign_id = c.campaign_id
	left join wink_gate_points_earned as e
	on e.bookingId = wb.id
	WHERE (@CURRENT_DATE between c.campaign_start_date and c.campaign_end_date)
	AND wc.[status] = 1
	AND wb.[status] = 1
	group by wc.total_points, c.campaign_id
	HAVING ISNULL(SUM(e.points),0) < wc.total_points
END
