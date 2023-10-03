CREATE PROC [dbo].[Get_Customer_Balance_Bak27032016]
@customer_tokenid VARCHAR(50)

AS
DECLARE @CUSTOMER_ID INT
DECLARE @WINK_BALANCE INT
DECLARE @POINT_BALANCE INT
DECLARE @eVoucher_balance int

BEGIN 

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid)                            
	BEGIN 
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		
		IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
		BEGIN
			SELECT @WINK_BALANCE = TOTAL_WINKS-USED_WINKS, @POINT_BALANCE=TOTAL_POINTS-USED_POINTS,
			 @eVoucher_balance = total_evouchers - total_used_evouchers
			 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID
			
			SELECT '1' as response_code, 'Success' as response_message, @WINK_BALANCE AS winks_balance
			, @POINT_BALANCE as points_balance ,@eVoucher_balance as evouchers_balance
			RETURN
		END
		ELSE
		BEGIN
			SELECT '1' as response_code, 'Success' as response_message, 0 AS winks_balance, 0 as points_balance ,
			0 As evouchers_balance
			RETURN
		END
	END
	ELSE
	BEGIN
		SELECT '1' as response_code, 'Success' as response_message, 0 AS winks_balance, 0 as points_balance ,
			0 As evouchers_balance
		RETURN
	END
	
END
