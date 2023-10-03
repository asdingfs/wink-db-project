
CREATE PROC [dbo].[WINKTAG_REFERRAL_BOARD]
@campaign_id int,
@customer_id int

AS
BEGIN
	IF EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
	BEGIN
		IF(@campaign_id = 152)
		BEGIN
			DECLARE @CURRENT_DATETIME Datetime ;     
			EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

			DECLARE @startDate datetime,
			@endDate datetime

			DECLARE @inputCampaignId int;
			SET @inputCampaignId = 151;
			DECLARE @voteCount int

			IF(@CURRENT_DATETIME between '2020-08-18 09:00:00.000' and '2020-08-20 08:59:59.999')
			BEGIN
				SET @startDate = '2020-08-18 09:00:00.000';
				SET @endDate = '2020-08-20 08:59:59.999';
			END
			ELSE IF(@CURRENT_DATETIME between '2020-08-20 09:00:00.000' and '2020-08-22 08:59:59.999')
			BEGIN
				SET @startDate = '2020-08-20 09:00:00.000';
				SET @endDate = '2020-08-22 08:59:59.999';
			END
			ELSE IF(@CURRENT_DATETIME between '2020-08-22 09:00:00.000' and '2020-08-24 08:59:59.999')
			BEGIN
				SET @startDate = '2020-08-22 09:00:00.000';
				SET @endDate = '2020-08-24 08:59:59.999';
			END
			ELSE IF(@CURRENT_DATETIME between '2020-08-24 09:00:00.000' and '2020-08-26 08:59:59.999')
			BEGIN
				SET @startDate = '2020-08-24 09:00:00.000';
				SET @endDate = '2020-08-26 08:59:59.999';
			END


			SELECT @voteCount = COUNT(answer)
			FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @inputCampaignId
			AND answer like 
			(SELECT WID FROM customer WHERE customer_id = @customer_id)
			AND (CAST(created_at as datetime) BETWEEN CAST(@startDate as datetime) AND CAST(@endDate as datetime));

			SELECT TOP(10) COUNT(answer) as ranking, @voteCount as myVotes  
			FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @inputCampaignId
			AND (CAST(created_at as datetime) BETWEEN CAST(@startDate as datetime) AND CAST(@endDate as datetime))
			GROUP BY answer
			ORDER BY ranking desc
		END
		RETURN
	END
END





