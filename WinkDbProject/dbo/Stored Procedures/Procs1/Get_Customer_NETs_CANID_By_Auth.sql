CREATE procedure [dbo].[Get_Customer_NETs_CANID_By_Auth]
(

 @cust_auth varchar(150),
 @redeemed_winks int 
)
AS
BEGIN

Declare @customer_id int

Declare @balanced_winks  int 
Declare @response_message varchar(400)
Declare @amount decimal (10,2)
--Declare @total_winks_charges int

Declare @total_topupWINKs int 

set @total_topupWINKs = @redeemed_winks/2

--- Check Account Locked--------
   IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @cust_auth and customer.status='disable') --CUSTOMER EXISTS                           
    BEGIN
   SELECT '4' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
		RETURN 
	END-- END

if(@redeemed_winks %2 !=0 OR @redeemed_winks <4)
BEGIN
select 0 as response_code , 'No. of WINKs must be in multiples of 2<br/>(min. 4 WINKs)' as response_message
END

set @customer_id =(select customer_id from customer where auth_token = @cust_auth and status='enable')
-- Customer -----
IF (@customer_id is null and @customer_id ='')
BEGIN
select 0 as response_code , 'Invalid Customer' as response_message

RETURN

END

--- Check Balanced WINKs 
If((select c.total_winks - c.used_winks - c.confiscated_winks  from customer_balance as c where c.customer_id = @customer_id) < @redeemed_winks)

BEGIN

select 0 as response_code , 'Insufficient WINKs' as response_message

RETURN

END

--- GET CAN IDs 

IF EXISTS (select 1 from can_id where customer_id = @customer_id and CAST(LEFT(customer_canid, 4) AS varchar) ='1111')
BEGIN

SELECT @amount = (@total_topupWINKs)*RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'cents_per_wink'
--- Convert eVoucher Cent To Dollar------------------------
SET @amount = @amount/100

---Balanced WINKs 

print (@amount)

--set @balanced_winks =(select c.total_winks - c.used_winks - c.confiscated_winks  from customer_balance as c where c.customer_id = @customer_id)

/*
SET @response_message = Concat('You can convert $ ', @amount , ' now or collect more WINKs for conversion later
<br/>(Note: WINK+ rate is 4 WINKs for every dollar of NETS FlashPay top-up.)
<br/>Please complete top-up by tapping your FlashPay card at applicable NETS top-up machines three days after redemption.
<br/>Top-up at NETS terminal must be done within 7 days.')*/

/*
SET @response_message = Concat('Top-up amount is $', @amount , '. You can convert now or collect more WINKs for conversion later.
<br/>(Note: WINK+ rate is 4 WINKs for every dollar of NETS FlashPay top-up.)
<br/>Please go to Account -> NETS Redemption Status and check if your NETS FlashPay Card is ready for top-up.')*/

SET @response_message = Concat('Top-up amount is $', @amount , '. You can redeem now or collect more WINKs for redemption later.
<br/>(Note: WINK+ rate is 4 WINKs for every dollar of NETS FlashPay top-up.)')




select customer_canid, customer_id , 1 as response_code, @response_message as response_message,@amount as amount_topup from can_id where customer_id = @customer_id and CAST(LEFT(customer_canid, 4) AS varchar) ='1111'

END

ELSE

BEGIN

select 0 as response_code , 'Please add NETs CAN ID' as response_message

END


END


