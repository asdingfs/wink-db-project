CREATE PROC [dbo].[Viral_Leaders_Result]
(
	@winktag_report varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int
	
	
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF(@CAMPAIGN_ID = 103)
	BEGIN
	
		
			(SELECT COUNT(customer_id) AS num FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @CAMPAIGN_ID AND answer like '82xs') 

			 UNION ALL

			(SELECT COUNT(customer_id) FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @CAMPAIGN_ID AND answer like 'mp32') 
	END

END



