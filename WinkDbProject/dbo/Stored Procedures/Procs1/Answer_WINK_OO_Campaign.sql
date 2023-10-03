CREATE Procedure [dbo].[Answer_WINK_OO_Campaign]
(
   @customer_id int,
  @answer varchar(100),
  @gps varchar(200)
)
AS
BEGIN
	Declare @current_date datetime
	Declare @total_quantity int
	Declare @campaign_id int
	Declare @campagin_timing_id int
	Declare @points int
	Declare @winktag_campaign_id int
	
	set @answer = LTRIM (RTRIM(@answer))
	
	set @winktag_campaign_id = 13

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
	BEGIN
		select 0 as response_code , 'Account locked. Please contact customer service.' as response_message
		Return
	END

	
	IF(@customer_id !=0)
	BEGIN

	if(@answer ='reset')
	begin

	delete from wink_oo_campaign_winner where customer_id = @customer_id
	delete from wink_oo_campaign_winner_log where customer_id = @customer_id

	Select 1 as response_code, 'Demo reset' as response_message
    Return
	--update wink_oo_campaign_luckydraw_winner set redemption_status 
	end

	    ---1)--------CHECK ACTIVE CAMPAIGN---------

		IF EXISTS (select 1 from wink_oo_campaign_timing as a 
		where @current_date >= a.from_time  and  @current_date <= a.to_time
		and a.timing_status =1)

		BEGIN
			select @total_quantity = a.total_quantity,@campaign_id =a.campaign_id,  
			@campagin_timing_id =id,
			@points = points
			from wink_oo_campaign_timing as a
			where @current_date >= a.from_time  and   @current_date <= a.to_time
			and a.timing_status =1 

		END
		/*ELSE
			BEGIN
			    select @total_quantity = a.total_quantity,@campaign_id =a.campaign_id  from wink_oo_campaign as a
			    where @current_date > a.from_time  and   @current_date <= a.to_time
			    and a.campaign_status =1 and campaign_type ='default'
			

			END*/

			    print 'campaign_id = ' + CAST(@campaign_id as varchar)
				print 'campaign_time_id = ' + CAST(@campagin_timing_id as varchar)
				print 'toal_quantity = ' + CAST(@total_quantity as varchar)

				IF  (@campaign_id>0)
				BEGIN
				
					------ 2) CHECK TOTAL PARTICIPATION PER TIMING

					Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

					IF( (select count(*) from wink_oo_campaign_winner as b where 
					b.campaign_timing_id =@campagin_timing_id) < @total_quantity And @total_quantity !=0  
		
					)

					BEGIN
						------ 3) CHECK THE CORRECT ANSWER  (ASSUMING THE ANSWER IS THE SAME)
						IF EXISTS (select 1 from wink_oo_campaign_timing as c, wink_oo_campaign_answer as a 		
						where 
						c.campaign_id = a.campaign_id and
						c.campaign_id =@campaign_id
						and answer =@answer and @current_date >= c.from_time  and   @current_date <= c.to_time
						and a.answer_status =1   )

						BEGIN
								-----4) CHECK ONE TIME PER CAMPAGIN PER CUSTOMER
							/*IF NOT EXISTS (select 1 from [wink_oo_campaign_winner] where [campaign_id] =@campaign_id
							and  customer_id = @customer_id) */
							IF NOT EXISTS (select 1 from [wink_oo_campaign_winner] where [campaign_id] =@campaign_id
							and  customer_id = @customer_id and cast(created_at as date) = cast(@current_date as date))
							BEGIN
							print('c')
							INSERT INTO [dbo].[wink_oo_campaign_winner]
										([campaign_id]
										,[created_at]					 
										,[updated_at]
										,customer_id
										,answer
										,gps
										,campaign_timing_id
						                ,points
										)
									VALUES
										(@campaign_id
										,@current_date
										,@current_date
										,@customer_id
										,@answer
										,@gps
										,@campagin_timing_id
										,@points
										)
						  
								IF(@@ROWCOUNT>0)
								BEGIN
								---------Give Points ------------------
								IF(@points>0)
								BEGIN
								INSERT INTO [dbo].[winktag_customer_earned_points]
								([campaign_id]
								,[question_id]
								,[customer_id]
								,[points]
								,[GPS_location]
								,[ip_address]
								,[created_at]
								,[row_count]
								,[additional_point_status])

									VALUES
									(
									@winktag_campaign_id,
									0,
									@customer_id,
									@points,
									@gps,
									'',
									@current_date,
									1,
									0

									)

									IF(@@ROWCOUNT>0)
									BEGIN

									IF EXISTs (select 1 from customer_balance where customer_id = @customer_id )
										BEGIN
										Update customer_balance set total_points = total_points+@points where customer_id =@customer_id
										END
									ELSE
										BEGIN
										Insert into customer_balance ( customer_id , total_points )
										values (@customer_id , @points)
										END

									END
					 
									
					
								END

								print('d')
										Select 1 as response_code, 'Congrats! You are a winner! Please approach our WINK<sup>+</sup> Ambassasdors to redeem your voucher. Happy Holidays!' as response_message
										Return

								END	 
								END

								ELSE 

								BEGIN
									Select 0 as response_code, 'You have already participated in this contest. Stay tuned for the next contest. Details on FB @winkwinksg.' as response_message
									Return

								END
						END
						ELSE

							BEGIN

							INSERT INTO [dbo].[wink_oo_campaign_winner_log]
										([campaign_id]
										,[created_at]					 
										,[updated_at]
										,customer_id
										,answer
										,gps
										,campaign_timing_id
						                ,points
										)
									VALUES
										(@campaign_id
										,@current_date
										,@current_date
										,@customer_id
										,@answer
										,@gps
										,@campagin_timing_id
										,@points
										)

							Select 0 as response_code, 'Oops! Please try again with the correct code.' as response_message
								Return
						END
	

					END
					ELSE

					BEGIN
					Select 0 as response_code, 'Oops! 20 people were faster than you! Stay tuned for the next contest. Details on FB @winkwinksg.' as response_message
						INSERT INTO [dbo].[wink_oo_campaign_winner_log]
										([campaign_id]
										,[created_at]					 
										,[updated_at]
										,customer_id
										,answer
										,gps
										,campaign_timing_id
						                ,points
										)
									VALUES
										(@campaign_id
										,@current_date
										,@current_date
										,@customer_id
										,@answer
										,@gps
										,@campagin_timing_id
										,@points
										)
						Return
					END
	

				END
				ELSE
				BEGIN
					
					 
					 INSERT INTO [dbo].[wink_oo_campaign_winner_log]
										([campaign_id]
										,[created_at]					 
										,[updated_at]
										,customer_id
										,answer
										,gps
										,campaign_timing_id
						                ,points
										)
									VALUES
										(0
										,@current_date
										,@current_date
										,@customer_id
										,@answer
										,@gps
										,0
										,0
										)
										Select 0 as response_code, 'Oops! Time is up! Stay tuned for the next contest. Details on FB @winkwinksg.' as response_message
				return
				END
				END

				ELSE
				BEGIN
	
						Select 0 as response_code, 'Invalid customer' as response_message
					-- select customer_id from customer where auth_token = @token_id and status ='enable'
									Return

				END

END


--select * from wink_oo_campaign_timing



