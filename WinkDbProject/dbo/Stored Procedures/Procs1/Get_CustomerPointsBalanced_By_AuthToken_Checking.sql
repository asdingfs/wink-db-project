CREATE PROCEDURE [dbo].[Get_CustomerPointsBalanced_By_AuthToken_Checking]
(@customer_tokenid varchar(255)
)
AS
BEGIN
DECLARE @CUSTOMER_ID INT
DECLARE @RATE_VALUE INT
DECLARE @CUSTOMER_POINTS_BALANCE INT

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid)                            
	BEGIN 
	   
		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 
		
		 -- Checking Gender DOB Mobile Number
	    IF EXISTS (SELECT top 1 customer.customer_id from customer where customer.auth_token = @customer_tokenid and 
	    (ISNULL(customer.date_of_birth,'') ='' OR ISNULL(customer.gender,'') ='' OR ISNULL(customer.phone_no,'') =''))
	    BEGIN
	         SELECT '0' AS response_code,
			'Please update your profile.Date of Birth, Mobile No. and Gender can not be empty to convert point to WINK. ' as response_message
		   RETURN
	    
	    END 
		
		IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
		BEGIN
			SELECT @RATE_VALUE = RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'points_per_wink'

			SELECT @CUSTOMER_POINTS_BALANCE =(TOTAL_POINTS - (USED_POINTS + CONFISCATED_POINTS)) FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID
			IF (@CUSTOMER_POINTS_BALANCE >= @RATE_VALUE)
			BEGIN
			SELECT @CUSTOMER_POINTS_BALANCE AS BALANCED_POINTS , '1' AS response_code,
			'Success' as response_message
			RETURN
			END
			ELSE
		    			
			SELECT 0 AS BALANCED_POINTS , '0' AS response_code,
			'You need 50 points to redeem 1 WINK' as response_message
			RETURN
		END
		Else
		BEGIN
			SELECT 0 AS BALANCED_POINTS , '0' AS response_code,
			'You need 50 points to redeem 1 WINK' as response_message
			RETURN
		END
		
		
	END
	/*ELSE
		BEGIN
		   SELECT '0' AS response_code,
			'Customer is not authenticate' as response_message
		   RETURN
	END*/
	
	
END
