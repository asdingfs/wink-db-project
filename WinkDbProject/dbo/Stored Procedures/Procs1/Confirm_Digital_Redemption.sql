CREATE Procedure [dbo].[Confirm_Digital_Redemption]
(
 @customer_email varchar(250),
 @NRIC varchar(100),
 @dob varchar(100),
 @event_name varchar(100)
)
AS
BEGIN
Declare @valid int
Declare @customer_id int
Declare @current_date datetime
Declare @total_scan int
Declare @maxID int 
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

BEGIN
Declare @total_redemption int
Declare @total_purchase int
        
        Set @customer_id = (select customer_id from event_winner where email= @customer_email and event_name =@event_name)
		Set @total_redemption = (select count(*) from wink_digital_redemption where customer_id = @customer_id and event_name =@event_name)
		Set @total_purchase = (select count(*) from iMOBSpecial where customer_id = @customer_id and event_name =@event_name)
		
		  

        IF EXISTS (select 1 from event_winner where customer_id = @customer_id and event_name = @event_name)
        BEGIN
					    IF Exists (select 1 from wink_digital_redemption  where NRIC =@NRIC and @NRIC!='' and event_name =@event_name)
						BEGIN	
						Declare @redeem_customer_id int
						
						IF(@redeem_customer_id != @customer_id)
						BEGIN

						select '0' as success, 'Already redeemed under this NRIC/FIN.' as response_message
						RETURN
						END
						END
        
        
		IF (@customer_id is not null or @customer_id !='' or @customer_id !=0)
			Begin
				-- Check already redemption
				
				
				IF @total_redemption<@total_purchase
					BEGIN 
		               print ('Not Redeem')
		               		               
					   insert into wink_digital_redemption (email,customer_id , NRIC,dob,redemption_status,event_name,created_at)
					   values (@customer_email,@customer_id,@NRIC,@dob,1,@event_name,@current_date)
   
					   IF(@@ERROR=0)
					   Begin
					   select '1' as success, 'Successfully Redeemed' as response_message
					   End
					   else 
					   Begin
					   select '0' as success, 'Fail to redeem' as response_message
					   END
   
					 END
					ELSE 
					BEGIN
					print ('Already')
					select '0' as success, 'Already redeemed' as response_message
				    END
   
			END
				ELSE
				  BEGIN
					select '0' as success, 'There is no email in the list' as response_message
				  END 
        END
        ELSE
        BEGIN
        select '0' as success, 'There is no email in the list' as response_message
		RETURN
        END
END


END