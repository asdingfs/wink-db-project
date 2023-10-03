-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_AsmBooking_StartDate_EndDate_By_CampaignId]
(@campaignId int ,
 @start_date datetime,
 @end_date datetime)
 As
 BEGIN
    IF EXISTS (SELECT * FROM asset_management_booking WHERE asset_management_booking.campaign_id = @campaignId)
		BEGIN
	Update asset_management_booking set asset_management_booking.start_date=@start_date,
	asset_management_booking.end_date =@end_date WHERE asset_management_booking.campaign_id = @campaignId
	IF (@@ROWCOUNT>0)
		BEGIN
			SELECT '1' AS response_code 
		END
	ELSE 
		BEGIN
			SELECT '0' AS response_code , 'Fail to update' as response_message
		END
	    END
   ELSE 
		BEGIN
			SELECT '1' AS response_code 
		END
	    
	
 
 
 END
