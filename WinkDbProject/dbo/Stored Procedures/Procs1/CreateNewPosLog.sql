CREATE PROCEDURE CreateNewPosLog
(

 @response_message varchar (255),
 @merchant_key varchar (255),
 @merchant_id varchar (255),
 @verification_code varchar (50)
 )
AS
BEGIN
Declare @CURRENT_DATE datetime
Declare @resutl int 
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT
	Insert into posthirdparty_redemption_log (response_message,merchant_key,merchant_id,verification_code,created_at,updated_at)
	values (@response_message,@merchant_key,@merchant_id,@verification_code,@CURRENT_DATE,@CURRENT_DATE)
	
    IF @@ERROR <> 0
         SET @resutl = -1
    ELSE
        SET @resutl = (select SCOPE_IDENTITY())
	SELECT @resutl
END
