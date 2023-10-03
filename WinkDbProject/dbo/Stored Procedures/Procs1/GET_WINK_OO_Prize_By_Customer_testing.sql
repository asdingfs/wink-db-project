CREATE Procedure [dbo].[GET_WINK_OO_Prize_By_Customer_testing]
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
Declare @campaign_image varchar(100) = 'wink_oo_redeemed.jpg'

set @redeemed_icon_image = 'wink_oo_redeemed.jpg'
set @unredeemed_icon_image = 'wink_oo_unredeemed.jpg'
set @noprize_icon_image = 'wink_oo_noprize.jpg'


Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

----- GET ADS IMAGE
	  SELECT @campaign_image= campaign_image from wink_oo_campaign_luckydraw_detail as a
	  where @current_date > a.from_time  and  @current_date <= a.to_time
	  and a.luckydraw_satus =1 and campaign_type ='merchant'
    
	IF(@campaign_image is null or @campaign_image ='')
	BEGIN

	  SELECT @campaign_image= campaign_image from wink_oo_campaign_luckydraw_detail as a
	  where @current_date > a.from_time  and  @current_date <= a.to_time
	  and a.luckydraw_satus =1 and campaign_type ='default'

	END

	IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
	BEGIN
		select 0 as response_code , 'Account locked' as response_message
		Return
	END

	IF EXISTs (select 1 from customer where customer_id = @customer_id and status ='enable')
	BEGIN
	  -- set @customer_id = (select customer_id from customer where auth_token = @token_id and status ='enable')
		
		IF(@customer_id is not null and @customer_id !='' and @customer_id !=0)
		BEGIN
		select 1 as response_code,a.id as prize_id,
		 b.id as winner_id , b.redemption_status, a.prize,
		 @redeemed_icon_image as redeemed_icon,
		 @unredeemed_icon_image as unredeemed_icon,
		  @noprize_icon_image as noprize_icon,
		  @campaign_image as campaign_image
		 		 
		  from wink_oo_campaign_luckydraw_detail as a
		left join 
	    wink_oo_campaign_luckydraw_winner as b
		on a.id = b.lucky_draw_id
		and b.customer_id = @customer_id
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


/*select * from wink_oo_campaign_luckydraw_detail

select * from wink_oo_campaign_luckydraw_winner

alter table wink_oo_campaign_luckydraw_detail add prize varchar(200)

alter table wink_oo_campaign_luckydraw_detail add prize_image varchar(200)

update wink_oo_campaign_luckydraw_detail set prize_image = 'WINKSmallbanner.jpg' where id = 2*/

--select * from wink_oo_campaign_luckydraw_detail


---alter table wink_oo_campaign_luckydraw_detail add campaign_type varchar(150)

--update wink_oo_campaign_luckydraw_detail set campaign_image = 'WINKOO_ads.jpg'


