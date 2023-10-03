-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Online_Ordering_Code_Auth]
(
  @campaign_id int,
  @redemptionCode varchar(10),
  @customer_id int
)
AS
BEGIN
	Declare @current_date datetime
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF(@customer_id !=0)
	BEGIN
		IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
		BEGIN
			select 0 as response_code , 'Account locked. Please contact customer service.' as response_message
			Return
		END
		ELSE
		BEGIN
			-- update it when it's live for winktag status = 1
			IF EXISTS(SELECT 1 from winktag_campaign where internal_testing_status = '1' and campaign_id = @campaign_id)
			BEGIN
				IF EXISTS (
				select 1 from winktag_redemption_staffs 
				where staff_code like @redemptionCode and campaign_id = @campaign_id)
				BEGIN
					IF EXISTS (SELECT 1 from wink_delights_online where campaign_id = @campaign_id and completion = 0)
					BEGIN
						Select 1 as response_code, 'success' as response_message
						Return
					END
					ELSE
					BEGIN
						Select 0 as response_code, 'There are no pending orders. Please check again later.' as response_message
						Return
					END
				END
				ELSE
				BEGIN
					Select 0 as response_code, 'Invalid code,<br> please try again!' as response_message
					Return
				END	
			END
			ELSE
			BEGIN
				Select 0 as response_code, 'The campaign has ended.' as response_message
				Return
			END
				
		END
	END
	ELSE
	BEGIN
		Select 0 as response_code, 'Invalid customer' as response_message
		Return
	END
END
