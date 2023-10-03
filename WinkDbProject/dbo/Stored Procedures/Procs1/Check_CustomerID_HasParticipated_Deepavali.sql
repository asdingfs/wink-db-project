-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Check_CustomerID_HasParticipated_Deepavali]
	-- Add the parameters for the stored procedure here
	(@campaign_id int,
     @customer_id int
	 )
AS
BEGIN
	
	DECLARE @CURRENT_DATE date ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 

		IF EXISTS (select 1 from winktag_customer_earned_points where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = @CURRENT_DATE)
			Select 1 as success , 'You have already participated in the survey.' as response_message
			return
END
