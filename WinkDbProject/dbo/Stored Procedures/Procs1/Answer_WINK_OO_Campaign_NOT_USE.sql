CREATE Procedure [dbo].[Answer_WINK_OO_Campaign_NOT_USE]
(
   @customer_id int,
  @answer varchar(100),
  @gps varchar(200)
)
AS
BEGIN
	Declare @current_date datetime
	Declare @lucky_id int
	Declare @total_quantity int
	Declare @campaign_id int
	
	
	

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
	BEGIN
		select 0 as response_code , 'Account locked. Please contact customer service.' as response_message
		Return
	END

	
	IF(@customer_id !=0)
	BEGIN

	if(@answer =9)
	begin

	delete from wink_oo_campaign_luckydraw_winner where customer_id = @customer_id

	Select 1 as response_code, 'Demo reset' as response_message
    Return
	--update wink_oo_campaign_luckydraw_winner set redemption_status 
	end

	---- Check Default or Merchant Campaign

		IF EXISTS (select 1 from wink_oo_campaign_luckydraw_detail as a 
		where @current_date > a.from_time  and  @current_date <= a.to_time
		and a.luckydraw_satus =1 and campaign_type ='merchant')

		BEGIN
			select @lucky_id = a.id,@total_quantity = a.total_quantity,@campaign_id =a.campaign_id  from wink_oo_campaign_luckydraw_detail as a
			where @current_date > a.from_time  and   @current_date <= a.to_time
			and a.luckydraw_satus =1 and campaign_type ='merchant'

		END
		ELSE
			BEGIN
				select @lucky_id = a.id,@total_quantity = a.total_quantity,@campaign_id =a.campaign_id  from wink_oo_campaign_luckydraw_detail as a
				where @current_date > a.from_time  and   @current_date <= a.to_time
				and a.luckydraw_satus =1 and campaign_type ='default'

			END


	IF  (@lucky_id>0)
	BEGIN
	print('a')
		------ Check the limitation 20 participants 
		Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
		IF( (select count(*) from wink_oo_campaign_luckydraw_winner as b where 
		b.lucky_draw_id =@lucky_id) < @total_quantity And @total_quantity !=0)

		BEGIN
		print('b')
			IF EXISTS (select 1 from wink_oo_campaign_luckydraw_detail where id =@lucky_id
			and answer =@answer and @current_date > from_time  and   @current_date <= to_time)

			BEGIN
			     
				IF NOT EXISTS (select 1 from [wink_oo_campaign_luckydraw_winner] where [lucky_draw_id] =@lucky_id
				and  customer_id = @customer_id)
				BEGIN
				print('c')
				INSERT INTO [dbo].[wink_oo_campaign_luckydraw_winner]
						   ([campaign_id]
						   ,[lucky_draw_id]
						   ,[created_at]					 
						   ,[updated_at]
						   ,customer_id
						   ,gps
						   )
					 VALUES
						   (@campaign_id
						   ,@lucky_id
						   ,@current_date
						   ,@current_date
						   ,@customer_id
						   ,@gps
						   )
						  
					IF(@@ROWCOUNT>0)
					BEGIN
					print('d')
					Select 1 as response_code, 'Your answer is correct. Please check redemption status.' as response_message
			         Return
					
					END	 
					END

					ELSE 

					BEGIN
					 Select 0 as response_code, 'Already participated in this contest. Please wait the next contest.' as response_message
			         Return

					END
			END
			ELSE

				BEGIN
				Select 0 as response_code, 'Incorrect answer.' as response_message
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
		Select 0 as response_code, 'Please wait the next contest.' as response_message

	END
	END

	ELSE
	BEGIN
	
		 Select 0 as response_code, 'Invalid customer' as response_message
		-- select customer_id from customer where auth_token = @token_id and status ='enable'
			         Return

	END

END



/*

select * from [wink_oo_campaign_luckydraw_winner]
alter table [wink_oo_campaign_luckydraw_winner] add customer_id int*/

--select * from wink_oo_campaign_luckydraw_winner




