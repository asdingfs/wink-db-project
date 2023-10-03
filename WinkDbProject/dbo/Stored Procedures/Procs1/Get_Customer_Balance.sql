CREATE PROC [dbo].[Get_Customer_Balance]
@customer_tokenid VARCHAR(255)

AS
DECLARE @CUSTOMER_ID INT
DECLARE @WINK_BALANCE INT
DECLARE @POINT_BALANCE Decimal(10,2)
DECLARE @eVoucher_balance int
DECLARE @total_usedeVochers int
BEGIN 

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid)                            
	BEGIN 
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		
		IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
		BEGIN
		-- Update 27/03/2016

		--SELECT CONFISCATED_POINTS
			 --FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID

			SELECT @WINK_BALANCE = TOTAL_WINKS- USED_WINKS - confiscated_winks,
			 @POINT_BALANCE = TOTAL_POINTS - USED_POINTS - CONFISCATED_POINTS,
			 @eVoucher_balance = total_evouchers - total_used_evouchers,
			 @total_usedeVochers = total_used_evouchers
			 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID
			 
			
			
			SELECT '1' as response_code, 'Success' as response_message, @WINK_BALANCE AS winks_balance
			, @POINT_BALANCE as points_balance ,@eVoucher_balance as evouchers_balance,@total_usedeVochers as total_usedeVouchers
			RETURN
		END
		ELSE
		BEGIN
			SELECT '1' as response_code, 'Success' as response_message, 0 AS winks_balance, 0 as points_balance ,
			0 As evouchers_balance, 0 as total_usedeVouchers
			RETURN
		END
	END
	ELSE
	BEGIN
		SELECT '1' as response_code, 'Success' as response_message, 0 AS winks_balance, 0 as points_balance ,
			0 As evouchers_balance,0 as total_usedeVouchers
		RETURN
	END
	
END
