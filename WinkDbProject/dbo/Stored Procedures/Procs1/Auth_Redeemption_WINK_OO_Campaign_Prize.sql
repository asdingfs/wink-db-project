CREATE Procedure [dbo].[Auth_Redeemption_WINK_OO_Campaign_Prize]
(
  @customer_id int,
   @winner_id int
)
AS
BEGIN
	Declare @current_date datetime

	Declare @lucky_drawimage varchar(100)

	Declare @campaign_image varchar(100) = 'wink_oo_redeemed.jpg'

	Declare @campaign_id int
	

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

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

		  IF EXISTS (Select 1 from wink_oo_campaign_winner where customer_id = @customer_id
		  and id = @winner_id)
		  BEGIN
			
					IF EXISTS (Select 1 from wink_oo_campaign_winner where customer_id = @customer_id
				  and id = @winner_id and redemption_status =0)
				  BEGIN

							select @campaign_id= campaign_id from wink_oo_campaign_winner where id =@winner_id
							
							select @lucky_drawimage = prize_image,@campaign_image = campaign_image from wink_oo_campaign where campaign_id =@campaign_id

							Select 1 as response_code, 'Valid' as response_message , @lucky_drawimage as prize_image,@campaign_image as campaign_image 
						    Return
					END
                  ELSE
					BEGIN
					Select 0 as response_code, 'Already redeemed' as response_message
						Return
					END
		  END
		  ELSE
				BEGIN
				Select 0 as response_code, 'Invalid eVoucher redemption' as response_message
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


--select * from wink_oo_campaign_luckydraw_winner

/*select * from wink_oo_campaign_luckydraw_detail*/


