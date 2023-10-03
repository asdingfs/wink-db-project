CREATE Procedure [dbo].[Authenticate_Lucky_Draw_WINNER]
(
  @email varchar(50),
  @nric varchar(20),
  @phone_no varchar(16),
  @event_name varchar(20)
)
AS
BEGIN
Declare @customer_id int 
Declare @qr_code varchar(100)
Declare @redemption_type varchar(15)
Declare @prize varchar(30)
IF Exists (select 1 from customer where customer.email =@email)
BEGIN
	Set @customer_id = (select customer_id from customer where customer.email = @email and status = 'enable')
	IF(@customer_id is not null and @customer_id !=0 and @customer_id !='')
	BEGIN

	IF EXISTS (select 1 from customer where customer_id = @customer_id and phone_no = @phone_no)
	BEGIN
	-- Check WINNER
	
	IF EXISTS (select 1 from wink_treasure_winner as w where w.customer_id = @customer_id)
	BEGIN
	
	    -- Check already redeem under this NRIC
	    IF EXISTS (select 1 from wink_treasure_winner as w where w.customer_id != @customer_id and nric =@nric)
			
			BEGIN
			
			select 0 as success , 'Already redeemed under this NRIC' as response_message , 1 as redemption_status 
			Return
			END
	    
		-- Check already Redeem
		
		IF EXISTS (select 1 from wink_treasure_winner as w where w.customer_id = @customer_id and redemption_status = '1')
			-- Check Redeem Type
			BEGIN
			
			select 1 as success , 'Already redeemed' as response_message , 1 as redemption_status 
			Return
			END
		Else
			Begin
			
			select @prize = prize from wink_treasure as a ,wink_treasure_winner as b 
			where a.id = b.winner_prize_id
			and b.customer_id = @customer_id
			select 1 as success , 'Authorized to redeem '+ @prize +'$' as response_message , 0 as redemption_status 
			Return
			End
		
		
	
	END
	ELSE
	BEGIN
	
	 select 0 as success , 'Customer is not in the list of winner' as response_message
	
	END
	
	END
	ELSE
	BEGIN
	 select 0 as success , 'Invaid phone no.' as response_message
	 Return

	END
	END
	ELSE 
	BEGIN
	 select 0 as success , 'Account is locked' as response_message
     Return
	
	END
END
ELSE
BEGIN
 select 0 as success , 'Email is not valid' as response_message
 Return

END
END



