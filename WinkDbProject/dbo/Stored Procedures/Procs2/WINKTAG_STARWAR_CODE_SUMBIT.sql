
CREATE PROC [dbo].[WINKTAG_STARWAR_CODE_SUMBIT]
(@CUSTOMER_ID INT,
@CODE VARCHAR(10),
@gps varchar(150)

)
AS
BEGIN

DECLARE @CURRENT_DATETIME Datetime ;
Declare @CAMPAIGN_START_DATE datetime
Declare @campaign_id int
Declare @size int

SELECT  @CAMPAIGN_START_DATE = FROM_DATE, @size = size ,@campaign_id = campaign_id from winktag_campaign where winktag_report = 'starwar_2017'
      
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	IF(@CODE !='SW17')

		BEGIN
			SELECT '0' AS response_code, 'Incorrect code. Please try again.' as response_message
			return
		END		

	
	IF ((select count(*) from winktag_starwar_2017) =@size)
			BEGIN
				SELECT '0' AS response_code, 'Fully redeemed' as response_message
				return
			END		


	IF EXISTS(SELECT 1 FROM winktag_starwar_2017 WHERE customer_id = @customer_id )
			BEGIN
				SELECT '0' AS response_code, 'You have already participated in this promotion.' as response_message
				return
			END	
				
    IF EXISTS (SELECT 1 FROM CUSTOMER WHERE customer_id = @customer_id and cast(created_at as date) < cast (@CAMPAIGN_START_DATE as date))
		BEGIN
			SELECT '0' AS response_code, 'By invitation only' as response_message
			return
		END

 
		INSERT INTO winktag_starwar_2017 (customer_id,starwar_code,created_at,gps)
		VALUES (@CUSTOMER_ID,@CODE,@CURRENT_DATETIME,@gps)

		IF(@@ROWCOUNT>0)
		BEGIN
			SELECT '1' AS response_code, 'Thank you for participating! We will contact you shortly with gift redemption details. May the Force be with You! ' as response_message
			return
		END
	 
END


