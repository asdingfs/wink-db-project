-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 

CREATE PROCEDURE [dbo].[CreateNew_CANID_BY_TokenId]
(
	@customer_tokenid VARCHAR(255),
    @can_id VARCHAR(100),
	@cardTag varchar(20)
)
AS
BEGIN
	DECLARE @CUSTOMER_ID int

	DECLARE @CUSTOMER_EMAIL varchar(255)
	DECLARE @CUSTOMER_NAME varchar(255)
	DECLARE @subscribe_status varchar(10)

	DECLARE @CURRENT_DATETIME datetime
	DECLARE @TOTAL_CANID INT
	SET @CURRENT_DATETIME = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');

	--DECLARE @lenofcanid INT
	DECLARE @digit varchar(2);

	IF (@can_id is null or @can_id = '')
	BEGIN
		SET @can_id = NULL;
	END

	IF (@cardTag is null or @cardTag = '')
	BEGIN
		SET @cardTag = NULL;
	END

	IF EXISTS(SELECT * FROM customer WHERE auth_token = @customer_tokenid) --CUSTOMER EXISTS                           
	BEGIN
		
		SELECT TOP 1 @CUSTOMER_ID = customer.customer_id, @CUSTOMER_EMAIL=customer.email, @subscribe_status= customer.subscribe_status, @CUSTOMER_NAME= customer.first_name +' '+customer.last_name FROM customer WHERE auth_token = @customer_tokenid;
		
		IF NOT EXISTS(SELECT * FROM can_id WHERE can_id.customer_canid =@can_id)
		BEGIN
							
			SET @digit = (select case when @can_id not like '%[^a-z0-9A-Z]%' then '1' else '0' end);
			--select @digit as digitme

			SET @TOTAL_CANID = ISNULL((SELECT COUNT(can_id.id) FROM can_id WHERE can_id.customer_id=@CUSTOMER_ID
			GROUP BY can_id.customer_id),0);

			--DECLARE @maxCardCount int = 3;

			--IF EXISTS (SELECT 1 FROM push_device_token WHERE customer_id = @CUSTOMER_ID AND active_status = '1' AND app_version is not null )
			--BEGIN
			--	SET @maxCardCount = 5;
			--END
			DECLARE @maxCardCount int = 5;
			-- CHECK CUSTOMER TOTAL CAN ID
			IF(@TOTAL_CANID < @maxCardCount)
			BEGIN

				--SET @lenofcanid= (select DATALENGTH(@can_id));
				--if(@lenofcanid = 16)
				--BEGIN
				if(@digit = '1')
				BEGIN
					INSERT INTO can_id(customer_canid,customer_id,created_at,updated_at,can_id_key,card_tag)
					VALUES (@can_id,@CUSTOMER_ID,@CURRENT_DATETIME,@CURRENT_DATETIME,@can_id, @cardTag);
		
					--select @@ROWCOUNT as countinsert
					IF(@@ROWCOUNT>0)
					BEGIN
						--if(SUBSTRING(@can_id,1,6) = '111179')
						--			BEGIN

						
						--			IF(cast(@CURRENT_DATETIME as Date) >= cast('2018-05-02' as Date) AND cast(@CURRENT_DATETIME as Date) <= cast('2018-07-31' as Date) )
						--				BEGIN

						--				IF ((SELECT count(*) from Authen_NETS_Contactless_Cashcard where MONTH(created_at) = MONTH(cast(@CURRENT_DATETIME as Date)) ) < 10000 )
						--				BEGIN

						--				IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where customer_id = @customer_id )
						--				BEGIN
						--				IF NOT EXISTS (SELECT 1 from Authen_NETS_Contactless_Cashcard where nets_card = @can_id )
						--				BEGIN

						--				Insert into Authen_NETS_Contactless_Cashcard (customer_id, nets_card, created_at, updated_at)
						--			Values (@customer_id, @can_id ,@CURRENT_DATETIME, @CURRENT_DATETIME)

						--			END
						--			    END
						--				END

						--				END

						--			END



						--SELECT can_id.customer_canid,'1' as response_code FROM can_id WHERE can_id.customer_id =@CUSTOMER_ID
						SELECT can_id.customer_canid, @CUSTOMER_EMAIL As customer_email, @subscribe_status as subscribe_status, @CUSTOMER_NAME As name, '1' as response_code FROM can_id WHERE can_id.customer_id =@CUSTOMER_ID
						RETURN
					END
					ELSE
					BEGIN
						SELECT '0' as response_code, 'Something is wrong. Please try again later.' as response_message; 
						RETURN
					END
				END
				ELSE
					BEGIN
					 SELECT '0' as response_code, 'Invalid travel card/membership ID' as response_message; 
					 RETURN
				END
				--END
				--ELSE
				--	BEGIN
				--	 SELECT '0' as response_code, 'Invalid travel card/membership ID' as response_message 
				--	 RETURN
				--END
			END
			ELSE
			BEGIN
				SELECT '0' as response_code, 'Max limit of travel card/membership IDs' as response_message; 
				RETURN
			END
		END			
		ELSE 
		BEGIN
			SELECT '0' as response_code, 'Duplicate travel card/membership ID' as response_message; 
			RETURN
		END
		
	END 
	ELSE-- CUSTOMER DOES NOT EXISTS
	BEGIN
		SELECT '0' as response_code, 'Customer is not authorised or Multiple logins are not allowed' as response_message; 
		RETURN
	END
	
END
