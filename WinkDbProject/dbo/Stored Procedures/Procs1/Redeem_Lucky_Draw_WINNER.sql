CREATE Procedure [dbo].[Redeem_Lucky_Draw_WINNER]
(
  @email varchar(50),
  @nric varchar(20),
  @phone_no varchar(16),
  @event_name varchar(20),
  @redemption_type varchar(20)
)
AS
BEGIN
Declare @customer_id int 
Declare @qr_code varchar(100)
--Declare @redemption_type varchar(15)
Declare @prize varchar(30)
Declare @current_date datetime 

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

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
		-- Check already Redeem
		
		IF EXISTS (select 1 from wink_treasure_winner as w where w.customer_id = @customer_id and redemption_status = '1')
			-- Check Redeem Type
			BEGIN
			
			select 0 as success , 'Already redeemed' as response_message , 1 as redemption_status 
			Return
			END
		Else
			Begin
			select @prize = SUM(cast(prize as int)) from wink_treasure as a ,wink_treasure_winner as w where 
			a.id = w.winner_prize_id and 
			w.customer_id = @customer_id
			and w.event_name = @event_name
			
			update wink_treasure_winner set redemption_status = 1,redemption_type = @redemption_type,nric=@nric where customer_id = @customer_id
			
			IF(@@ROWCOUNT>0)
			BEGIN
			print ('@prize')
			print (@prize)
			print ('points')
			print (@redemption_type)
		    if(@prize>0 and @redemption_type ='points')
		    BEGIN
		    
		    Declare @total_points int
		    Declare @total_tag int
		    
		    Set @total_points = @prize * 100
		    Set @total_tag = (select ISNULL(total_facebook_tag,0) from CNY_2017_Rewards where customer_id = @customer_id)
		    
		    if(@total_tag!=0)
		    begin
		    Set @total_points = @total_points * @total_tag
		    
		    end 
		    
		    print ('@total_points')
			print (@total_points)
			print ('@total_tag')
			print (@total_tag)
			
		    IF(@total_points>0)
		    BEGIN
		    insert into customer_earned_points_by_event (customer_id , points,event_name,created_at)
		    values (@customer_id,@total_points,@event_name,@current_date)
		    
		    IF(@@ROWCOUNT>0)
		    BEGIN
		    print ('qq')
		    update customer_balance set total_points = total_points+@total_points
		    where customer_id = @customer_id
		    
		    IF(@@ROWCOUNT>0)
		    BEGIN
		    if(@total_points>1)
		    BEGIN
		    select 1 as success, '1' as redemption_status , Concat('Total ', @total_points ,' points have already added to your account') as response_message
		    Return
		    END
		    ELSE
		    BEGIN
		    select 1 as success, '1' as redemption_status , Concat('Total ', @total_points ,' point has already added to your account')  as response_message
		    Return
		    END
		    END
		    
		    END
		    
		    END
		    
		    	    
		   
		    
		    END
		    else 
		    BEGIN
		    select 1 as success , 'You have successfully chosen to redeem cash' as response_message,'1' as redemption_status 
		    Return
		    END
		    
			
			END
			
			
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

/*select * from wink_treasure
select * from wink_treasure_winner

select * from CNY_2017_Rewards

alter table wink_treasure add prize_type varchar(20) default('points') not null

update wink_treasure set prize_type = 'amount'*/





