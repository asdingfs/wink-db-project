CREATE Procedure [dbo].[Redeem_WINKs_To_Nets_TopUp]
(
 @cust_auth varchar(150),
 @winks_to_redeem int,
 @can_id varchar(25)

)
AS
BEGIN

Declare @customer_id int 
Declare @CURRENT_DATETIME datetime
Declare @response_code varchar(10)
Declare @eVoucher varchar(20)
DECLARE @EVOUCHER_AMOUNT DECIMAL (10,2)
DECLARE @RATE_VALUE INT
DECLARE @EVOUCHER_EXPIRED_DATE DateTime
DECLARE @EVOUCHER_CODE varchar(10)
Declare @VERIFICATION_CODE varchar(20)
Declare @eVoucher_id int
DECLARE @VERIFICATION_VALID_TILL DATETIME
Declare @branch_code varchar(10)
DECLARE @INCREMENT_Value numeric(3,0)
DECLARE @TRANS_REF_NO INT
Declare @VERIFICATION_ID int
Declare @MERCHANT_ID int

Declare @after_winks_charge int
Declare @globl_campaign_id int

Declare @globl_merchant_id int

Declare @nets_redeemed_wink int

Declare @nets_confiscated_wink int




Exec GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output
/*************Testing**************/
Set @branch_code = 1234 -- NETs branch code
set @MERCHANT_ID =237 --- NETs Merchant ID
set @globl_campaign_id =1 --testing
set @globl_merchant_id = 64


/***************50%****************/



set @after_winks_charge = @winks_to_redeem/2

set @nets_redeemed_wink = @after_winks_charge

set @nets_confiscated_wink = @after_winks_charge


if(CAST(LEFT(@can_id, 4) AS nvarchar) != '1111' OR LEN(@can_id) != 16)
BEGIN
set @response_code = 6

GOTO Result

END

--- Check Account Locked--------
   IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @cust_auth and customer.status='disable') --CUSTOMER EXISTS                           
    BEGIN
   SELECT '4' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
		RETURN 
   END-- END

-- Check Customer Multiple Logins 

IF EXISTS (select 1 from customer where customer.auth_token = @cust_auth)
BEGIN

Set @customer_id = (select customer_id from customer where customer.auth_token = @cust_auth and status ='enable')
		-- Check Customer Status 
		if(@customer_id is not null and @customer_id !=0)
		BEGIN
		
		-- Check WINKs before redemption
		IF EXISTS (select 1 from customer_balance where @winks_to_redeem <= (total_winks-used_winks-confiscated_winks)
		and customer_id = @customer_id)
			BEGIN 
			-- Redeem WINKs
			UPDATE CUSTOMER_BALANCE SET USED_WINKS = USED_WINKS+@nets_redeemed_wink,
			TOTAL_EVOUCHERS = TOTAL_EVOUCHERS+1,
			confiscated_winks = isnull(confiscated_winks,0) + @nets_confiscated_wink 
			WHERE CUSTOMER_ID = @CUSTOMER_ID
			AND @winks_to_redeem <= (total_winks-used_winks-confiscated_winks)

				-- Check Successfull redeem WINKs
            If(@@ROWCOUNT>0)
			BEGIN
					SELECT @EVOUCHER_AMOUNT = @after_winks_charge * RATE_VALUE,@RATE_VALUE =rate_value FROM RATE_CONVERSION WHERE RATE_CODE = 'cents_per_wink'
					--- Convert eVoucher Cent To Dollar------------------------
					SET @EVOUCHER_AMOUNT = @EVOUCHER_AMOUNT/100
		
					SELECT @EVOUCHER_EXPIRED_DATE = DATEADD(day, system_value , @CURRENT_DATETIME) FROM system_key_value WHERE system_key = 'evoucher_expire_after_days'
			
					EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
			
					WHILE EXISTS(SELECT 1 FROM customer_earned_evouchers WHERE eVoucher_code = @EVOUCHER_CODE)
					BEGIN
						EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
					END

					IF(@EVOUCHER_AMOUNT>0)
					BEGIN
					--- Insert eVoucher and Used 
					INSERT INTO customer_earned_evouchers
						([customer_id],[redeemed_winks],[eVoucher_code],[eVoucher_amount],[expired_date],[created_at],[used_status],[updated_at]) VALUES
						(@CUSTOMER_ID,@nets_redeemed_wink,@EVOUCHER_CODE,@EVOUCHER_AMOUNT,@EVOUCHER_EXPIRED_DATE,@CURRENT_DATETIME,1,@CURRENT_DATETIME)
			        
					 SET @eVoucher_id = SCOPE_IDENTITY();

					 Print('@eVoucher_id')
					 Print(@eVoucher_id)

					 END




					IF(@eVoucher_id is not null and @eVoucher_id !=0)
					BEGIN
					SELECT @VERIFICATION_CODE= CONVERT(numeric(12,0),rand() * 899999999999) + 100000000000
					WHILE EXISTS(SELECT * FROM eVoucher_verification WHERE eVoucher_verification.verification_code = @VERIFICATION_CODE)
						BEGIN
						--SELECT @VERIFICATION_CODE= CONVERT(numeric(8,0),rand() * 89999999) + 10000000
					SELECT @VERIFICATION_CODE= CONVERT(numeric(12,0),rand() * 899999999999) + 100000000000
					
						END	
					SELECT @VERIFICATION_VALID_TILL = DATEADD(second,system_value,@CURRENT_DATETIME)FROM system_key_value WHERE system_key = 'evoucher_lock_seconds'			

                     -- eVoucher_verification 
					INSERT INTO eVoucher_verification
					(eVoucher_id,eVoucher_code,verification_code,customer_id,branch_id,created_at,valid_till) VALUES 
					(@eVoucher_id,@eVoucher_id,@VERIFICATION_CODE,@CUSTOMER_ID,@branch_code,@CURRENT_DATETIME,@VERIFICATION_VALID_TILL)
					SET @VERIFICATION_ID = SCOPE_IDENTITY();

					 Print('@VERIFICATION_ID')
					 Print(@VERIFICATION_ID)
					
				
				    -- INSERT TRANSACTION
                    IF(@VERIFICATION_ID is not null and @VERIFICATION_ID !=0)
					BEGIN

					-- eVoucher_redemption
					SET @INCREMENT_Value= CONVERT(numeric(3,0),rand() * 999)
					SET @TRANS_REF_NO =(SELECT TOP 1 TRANSACTION_ID  FROM eVoucher_transaction ORDER BY TRANSACTION_ID DESC)
					SET @TRANS_REF_NO = @TRANS_REF_NO+@INCREMENT_Value


					INSERT INTO eVoucher_transaction
					([transaction_id]
					,[merchant_id]
					,[branch_code]
					,[eVoucher_id]
					,[eVoucher_amount]
					,[customer_id]	
					,[created_at]
					,[updated_at]
					,[verification_id]
					,[verification_code]
					,customer_name
					,customer_email
					)
					select 
					@TRANS_REF_NO ,
					@MERCHANT_ID,
					@BRANCH_CODE,
					@EVOUCHER_ID,
					@EVOUCHER_AMOUNT,
					@CUSTOMER_ID,
					@CURRENT_DATETIME,
					@CURRENT_DATETIME,
					@VERIFICATION_ID,
					@VERIFICATION_CODE,
					first_name +' ' +last_name,
					email from customer
					where customer.customer_id =@customer_id
					

					--- Insert NETs Records 

					IF(@@ROWCOUNT>0)
					BEGIN
					UPDATE customer_balance SET total_used_evouchers = total_used_evouchers+1 WHERE customer_balance.customer_id= @CUSTOMER_ID
					INSERT INTO [dbo].[NETs_CANID_Redemption_Record_Detail]
					   ([can_id]
					   ,[customer_id]
					   ,[evoucher_id]
					   ,[evoucher_amount]
					   ,[created_at]
					   ,[updated_at]
					   ,redemption_date
					   ,wink_charges
					   )
				 VALUES
					   (@can_id,@customer_id,@eVoucher_id,@EVOUCHER_AMOUNT,
					    @CURRENT_DATETIME,@CURRENT_DATETIME,@CURRENT_DATETIME,
						@nets_confiscated_wink
						)
				    -- Insert to global confiscated
					IF(@@ROWCOUNT>0)
					BEGIN
					UPDATE campaign set total_wink_confiscated =total_wink_confiscated+@after_winks_charge,updated_at=@CURRENT_DATETIME where campaign_id =@globl_campaign_id 
					-- Insert into confiscation detail

					INSERT INTO [dbo].[wink_confiscated_detail]
					   ([customer_id]
					   ,[merchant_id]
					   ,[created_at]
					   ,[updated_at]
					   ,[total_winks]
					   ,[year_end]
					   ,[confiscated_from]
					   ,evoucher_id
					   )
				 VALUES
					   (@customer_id
					   ,@globl_merchant_id
					   ,@CURRENT_DATETIME
					   ,@CURRENT_DATETIME
					   ,@nets_confiscated_wink
					   ,''
					   ,'NETs'
					   ,@eVoucher_id
					   )
					END
					
					  		set @response_code = 4
							GOTO Result

					
					END

					END

					

					END

					ELSE

					BEGIN

					Set @response_code =5 ---Not enough WINKs
					GOTO Result
					END

					
			END
			

		    END
		Else
			BEGIN
			Set @response_code =3 ---Not enough WINKs
			GOTO Result
			END

		END
		Else 
		BEGIN

		set @response_code = 2
		GOTO Result
		END


END
ELSE
BEGIN

set @response_code = 1

GOTO Result

END

Result:
if(@response_code =1)
Begin
select  0 as response_code , 'Mulitple logins not allowed' as response_message
Return
End
else if (@response_code =2)
Begin
select  0 as response_code , 'Account locked. Please Contact customer service' as response_message
Return
End
else if (@response_code =3)
Begin
select  0 as response_code , 'Not enough WINKs to redeem' as response_message
Return
End

else if (@response_code =4)
Begin
/*select  1 as response_code , 'Please complete top-up by tapping your FlashPay card at applicable NETS top-up machines three days after redemption.
 Top-up at NETS terminal must be done within 7 days.' as response_message*/

 select  1 as response_code , 'Please go to Account -> NETS Redemption Status and check if your NETS FlashPay Card is ready for top-up.' as response_message

Return
End
else if (@response_code =5)
Begin
select  0 as response_code , 'Fail to convert to eVoucher' as response_message
Return
End
else if (@response_code =6)
Begin
select  0 as response_code , 'Invalid CAN ID' as response_message
Return
End

END



/*select * from campaign where campaign_id =1 --62810

select top 1 * from [wink_confiscated_detail] order by created_at desc*/


--select * from eVoucher_transaction where cast(created_at as date) = cast('2017-09-24' as date)  order by created_at desc

/*select * from customer_earned_evouchers where earned_evoucher_id =4904

select * from [wink_confiscated_detail] where [confiscated_from] = 'NETs'*/

