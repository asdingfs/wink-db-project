CREATE Procedure [dbo].[Confirm_Digital_Redemption_By_iMOBWinner]
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
Declare @total_win int
Declare @imob_customer_id int 
        
        Set @customer_id = (select customer_id from imobpurchase_event_winner where email= @customer_email and event_name =@event_name)
		set @imob_customer_id = (select imob_customer_id from imobpurchase_event_winner where email= @customer_email and event_name =@event_name)
		Set @total_redemption = (select count(*) from iMOBWINNER_digital_redemption where imob_customer_id = @imob_customer_id and event_name =@event_name)
		Set @total_win = (select count(*) from imobpurchase_event_winner where email = @customer_email and event_name =@event_name)
		
		
		print (@total_win)
		print (@total_redemption)

        IF EXISTS (select 1 from imobpurchase_event_winner where email = @customer_email and event_name =@event_name)
        BEGIN
					    IF Exists (select 1 from iMOBWINNER_digital_redemption  where NRIC =@NRIC and @NRIC!='' and event_name =@event_name)
						BEGIN	
						--Declare @redeem_customer_id int
						
						IF(@customer_email != (select distinct email from iMOBWINNER_digital_redemption where NRIC=@NRIC))
						BEGIN

						select '0' as success, 'Already redeemed under this NRIC/FIN.' as response_message
						RETURN
						END
						END
        
        
		IF (@customer_id is not null or @customer_id !='' or @customer_id !=0)
			Begin
				-- Check already redemption
				
				
				IF @total_redemption<@total_win
					BEGIN 
		               print ('Not Redeem')
		               		               
					   insert into iMOBWINNER_digital_redemption (email,customer_id , NRIC,dob,redemption_status,event_name,created_at,imob_customer_id)
					   values (@customer_email,@customer_id,@NRIC,@dob,1,@event_name,@current_date,@imob_customer_id)
   
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