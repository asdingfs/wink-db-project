CREATE Procedure [dbo].[GET_WINK_OO_Prize_By_Customer]
(
  @customer_id int
   
)
AS
BEGIN
	
	/*wink_oo_campaign
wink_oo_campaign_luckydraw_winner
wink_oo_campaign_luckydraw_detail
wink_oo_campaign_merchant*/
--Declare @customer_id int
Declare @current_date datetime
Declare @redeemed_icon_image varchar(100)
Declare @unredeemed_icon_image varchar(100)
Declare @noprize_icon_image varchar(100)
--Declare @campaign_image varchar(100) = 'wink_oo_redeemed.jpg'
Declare @campaign_image varchar(100)

set @redeemed_icon_image = 'wink_oo_redeemed.png'
set @unredeemed_icon_image = 'wink_oo_unredeemed.png'
set @noprize_icon_image = 'wink_oo_noprize.png'


Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	
    
	---1) CHECK CUSTOMER ACCOUNT STATUS 
	
	IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
	BEGIN
		select 0 as response_code , 'Account locked. Please contact customer service.' as response_message
		Return
	END

	----- 2)-----GET ADVERTISING IMAGE
		  print ('1111')
		  print (@campaign_image)
		  SELECT @campaign_image= a.campaign_image from wink_oo_campaign as a,
		  wink_oo_campaign_timing as t
		  where 
		  a.campaign_id = t.campaign_id
		  and 
		  @current_date > t.from_time  and  @current_date <= t.to_time
		  and t.timing_status =1 

	IF EXISTs (select 1 from customer where customer_id = @customer_id and status ='enable')
	BEGIN
	
		
		IF(@customer_id is not null and @customer_id !='' and @customer_id !=0)
		BEGIN

		----- 3)-----GET ADVERTISING IMAGE
		
		select 1 as response_code,a.campaign_id as prize_id,
		 b.id as winner_id , b.redemption_status, a.prize,
		 @redeemed_icon_image as redeemed_icon,
		 @unredeemed_icon_image as unredeemed_icon,
		 @noprize_icon_image as noprize_icon,
		 @campaign_image as campaign_image,
		 b.updated_at ,b.created_at
		
		from wink_oo_campaign_timing as t
		join wink_oo_campaign as a
		on t.campaign_id = a.campaign_id	 
		left join 
	    wink_oo_campaign_winner as b
		on a.campaign_id = b.campaign_id
		and b.customer_id = @customer_id
		and b.campaign_timing_id = t.id
		order by b.created_at desc
		RETURN
		END
		ELSE

			BEGIN
				select 0 as response_code , 'Invalid customer' as response_message
				RETURN
			END

	END
	ELSE

			BEGIN
				select 0 as response_code , 'Invalid customer' as response_message
				RETURN
			END
END


--select * from wink_oo_campaign_timing

--select * from wink_oo_campaign_winner

