CREATE Procedure [dbo].[Redeem_WINK_OO_Campaign_Prize]
(
  @customer_id int,
  @merchant_code varchar(10),
  @winner_id int
)
AS
BEGIN
	Declare @current_date datetime

	Declare @lucky_drawimage varchar(100)

	Declare @campaign_id int

	--Declare @winner_id int
	Declare @merchant_id int

	--set @winner_id = @lucky_id
	

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	----1) CHECK CUSTOMER ACCOUNT STATUS 
	IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
	BEGIN
		select 0 as response_code , 'Account locked. Please contact customer service.' as response_message
		Return
	END

	--set @customer_id = ISNULL((select customer_id from customer where customer_id = @customer_id and status ='enable'),0)

	

	IF(@customer_id !=0)
	BEGIN
			IF EXISTs (select 1 from customer where customer_id = @customer_id and status ='enable')
			BEGIN
		
				   ----1 CHECK WINNER RECORD
					IF EXISTS (Select 1 from wink_oo_campaign_winner where customer_id = @customer_id
				  and id = @winner_id)
				  BEGIN
					  ----2)--- GET CAMPAIGN ID----

						select @campaign_id = campaign_id from wink_oo_campaign_winner where id=@winner_id
						and customer_id =@customer_id

			          

						---3)---CHECK MERCHANT CODE

						IF EXISTS (select 1 from wink_oo_campaign_merchant as a
						where
						-- a.campaign_id =@campaign_id
						-- and 
						 a.branch_code =@merchant_code)
						BEGIN
					
							---4)---CHECK REDEMPTION STATUS
							IF EXISTS (Select 1 from wink_oo_campaign_winner where customer_id = @customer_id
						  and id = @winner_id and redemption_status =0)
						  BEGIN
									update wink_oo_campaign_winner set redemption_status =1 , redemption_date =@current_date,
									branch_code = @merchant_code
									where customer_id = @customer_id
									and id = @winner_id and redemption_status =0 
			
									IF(@@ROWCOUNT>0)
										BEGIN

										   select @lucky_drawimage = prize_image from wink_oo_campaign where campaign_id =@campaign_id
										   Select 1 as response_code, 'Gift Redeemed! Happy Holidays!' as response_message , @lucky_drawimage as prize_image
										   Return
										END
							END
							ELSE
								BEGIN
								Select 0 as response_code, 'Already redeemed' as response_message
									Return
								END
						END
						ELSE
						BEGIN
							Select 0 as response_code, 'Invalid merchant code.' as response_message
							Return
						END

				  END
				  BEGIN
					   Select 0 as response_code, 'Invalid redemption.' as response_message
					   Return
				  END
		
			END
	END
	ELSE 
	BEGIN
		Select 0 as response_code, 'Invalid customer' as response_message
		Return
	END	
END



--alter table wink_oo_campaign_winner add branch_code varchar(10) 

/*select * from wink_oo_campaign_merchant 

update wink_oo_campaign_merchant set campaign_id = 22

alter table wink_oo_campaign_merchant add campaign_id int default 0 not null

select * from wink_oo_campaign*/