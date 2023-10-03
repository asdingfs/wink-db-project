CREATE Procedure [dbo].[Redeem_WINK_OO_Campaign_Prize_testing]
(
  @customer_id int,
  @merchant_code varchar(10),
  @lucky_id int
)
AS
BEGIN
	Declare @current_date datetime

	Declare @lucky_drawimage varchar(100)
	

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
	BEGIN
		select 0 as response_code , 'Account locked. Please contact enquiry@winkwink.sg.' as response_message
		Return
	END

	--set @customer_id = ISNULL((select customer_id from customer where customer_id = @customer_id and status ='enable'),0)

	IF(@customer_id !=0)
	BEGIN
	IF EXISTs (select 1 from customer where customer_id = @customer_id and status ='enable')
	BEGIN
		
		IF EXISTS (select 1 from wink_oo_campaign_luckydraw_detail as b
		where b.id =@lucky_id
		and b.merchant_code =@merchant_code)
		BEGIN
		  
		  ---
		  
		  
		  IF EXISTS (Select 1 from wink_oo_campaign_luckydraw_winner where customer_id = @customer_id
		  and lucky_draw_id = @lucky_id)
		  BEGIN
			
					IF EXISTS (Select 1 from wink_oo_campaign_luckydraw_winner where customer_id = @customer_id
				  and lucky_draw_id = @lucky_id and redemption_status =0)
				  BEGIN
							update wink_oo_campaign_luckydraw_winner set redemption_status =1 , redemption_date =@current_date
							where customer_id = @customer_id
							and lucky_draw_id = @lucky_id and redemption_status =0 
			
							IF(@@ROWCOUNT>0)
								BEGIN

								   select @lucky_drawimage = prize_image from wink_oo_campaign_luckydraw_detail where id =@lucky_id
								   Select 1 as response_code, 'Successfully redeemed' as response_message , @lucky_drawimage as prize_image
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
				Select 0 as response_code, 'Invalid redemption' as response_message
					Return
		  END


		END
		ELSE
		BEGIN
		Select 0 as response_code, 'Invalid merchant code' as response_message
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


/*

select * from [wink_oo_campaign_luckydraw_winner]
alter table [wink_oo_campaign_luckydraw_winner] add customer_id int*/

