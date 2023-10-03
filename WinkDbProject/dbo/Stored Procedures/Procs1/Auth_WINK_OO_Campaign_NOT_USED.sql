CREATE PROC [dbo].[Auth_WINK_OO_Campaign_NOT_USED]          
( @customer_id int
)                                                                                                                          

AS
BEGIN
	Declare @current_date datetime
	Declare @lucky_id int
	Declare @total_quantity int
	Declare @campaign_id int
	

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF EXISTS (select 1 from customer  where customer_id = @customer_id  and status ='disable' )
	BEGIN
		select 0 as response_code , 'Account locked. Please contact enquiry@winkwink.sg.' as response_message
		Return
	END

	

	IF (@customer_id=0)
	BEGIN
		select 0 as response_code , 'Invalid customer' as response_message
		Return

	END

	IF EXISTs (select 1 from wink_oo_campaign_luckydraw_detail as a
	where @current_date >= a.from_time  and  @current_date <= a.to_time
	and a.luckydraw_satus =1)
	BEGIN


	print('a')
	 

	select @lucky_id = a.id,@total_quantity = a.total_quantity,@campaign_id =a.campaign_id  from wink_oo_campaign_luckydraw_detail as a
	where @current_date >= a.from_time  and  @current_date <= a.to_time
	and a.luckydraw_satus =1

		IF( (select count(*) from wink_oo_campaign_luckydraw_winner as b where 
		b.lucky_draw_id =@lucky_id and cast(created_at as date) = cast (@current_date as date)) < @total_quantity)

		BEGIN
			IF EXISTS (select 1 from [wink_oo_campaign_luckydraw_winner] where [lucky_draw_id] =@lucky_id
			and  customer_id = @customer_id and cast(created_at as date) = cast (@current_date as date))
					BEGIN
					 Select 0 as response_code, 'Already participated in this contest. Please wait the next contest' as response_message
			         Return

					END
					ELSE
					BEGIN

					 Select 1 as response_code, 'Valid' as response_message
			         Return
					END


	

		END
		ELSE

		BEGIN
		Select 0 as response_code, 'Fully redeemed.' as response_message
			Return
		END
	

	END
	ELSE
	BEGIN
		Select 0 as response_code, 'Please wait the next contest' as response_message

	END


END


--select * from wink_oo_campaign_luckydraw_detail 

--select * from wink_oo_campaign_luckydraw_winner