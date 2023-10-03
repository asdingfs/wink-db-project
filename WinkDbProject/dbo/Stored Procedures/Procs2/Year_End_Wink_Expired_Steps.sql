CREATE PROCEDURE [dbo].[Year_End_Wink_Expired_Steps] 
(
@year varchar(10)
)	
AS
BEGIN
--take DB snapshot
--snapshot will be taken on RDS side.


--backup customer_balance in case any failures.
/*
drop table [dbo].[customer_balance_wink_expired_2020]
SELECT *
INTO customer_balance_wink_expired_2020
FROM customer_balance
*/

--Create store_procedure_log
IF  NOT EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[wink_store_procedure_log]') AND type in (N'U'))

BEGIN
CREATE TABLE [dbo].[wink_store_procedure_log](
	 [id] [int] IDENTITY(1,1) PRIMARY KEY,
	 [sp_name] VARCHAR(256),
	 [msg_type]  VARCHAR(20),   
	 [msg_content]  VARCHAR(2048),
	 [created_time] DATETIME
) 

END

BEGIN TRANSACTION;
SAVE TRANSACTION YearEndWinkExpiredSteps;

Declare @current_time DATETIME, 
		@winks_to_confiscate int,
		@final_winks_after_winks_expired int,
		@current_avaiable_winks int,
		@total_conficated_winks int,
		@campaign_total_winks int,
		@campaign_total_winks_confiscated int,
		@total_winks_For_customer_to_redeem int,
		@prev_total_winks_For_customer_to_redeem int,
		@prev_winks_to_confiscate int,
		@return_value int,
		@msg varchar(2000)


BEGIN try
	
	EXEC GET_CURRENT_SINGAPORT_DATETIME  @current_time OUTPUT

	Declare @T Table 
	
	(current_avaiable_winks int, 
	yearly_end_confiscated_winks_From_customer_balance int, 
	year_end_total_winks_From_wink_confiscated_detail int,
	final_winks_after_winks_expired int,
	campaign_total_winks int,
	campaign_total_winks_confiscated int,
	total_winks_For_customer_to_redeem int,
	total_winks_From_customer_balance int,
	total_winks_From_customer_earned_winks int,
	used_winks_From_customer_balance int,
	confiscated_winks_From_customer_balance int
	)
	Insert @T Exec Get_Current_Available_WINKs_Internal @year=@year
	
	Select @current_avaiable_winks = current_avaiable_winks, 
			@final_winks_after_winks_expired = final_winks_after_winks_expired, 
			@campaign_total_winks = campaign_total_winks,
			@campaign_total_winks_confiscated = campaign_total_winks_confiscated,
			@winks_to_confiscate=yearly_end_confiscated_winks_From_customer_balance,
			@total_winks_For_customer_to_redeem = total_winks_For_customer_to_redeem   
	from @T 
	

	set @prev_total_winks_For_customer_to_redeem  = @total_winks_For_customer_to_redeem
	set @prev_winks_to_confiscate  = @winks_to_confiscate
	-- Yearly wink confiscated
	--select * from @T;
	set @msg = 'Current available wink:' +  Convert(varchar(50),@current_avaiable_winks) + ',winks to be confiscated:' +
			 Convert(varchar(50),@winks_to_confiscate) +
			 ',final winks after winks expired:' +  Convert(varchar(50),@final_winks_after_winks_expired) +
			 ',compaign total winks:' + Convert(varchar(50),@campaign_total_winks) +
			 ',campaign total winks confiscated:' + Convert(varchar(50),@campaign_total_winks_confiscated) +
			 ',total winks for customer to redeem:' + Convert(varchar(50),@total_winks_For_customer_to_redeem);

	INSERT INTO wink_store_procedure_log(sp_name,msg_type, msg_content,created_time)
			values('YearEndWinkExpiredSteps','INFO', @msg,@current_time);

	--confiscated wink
	--EXEC	@return_value = [dbo].[Yearly_WINK_Confiscated] @year=@year
	
	COMMIT TRANSACTION 
	
	-- check total winks.
	DELETE from @T;
	Insert @T Exec Get_Current_Available_WINKs_Internal @year=@year
	
	Select @current_avaiable_winks = current_avaiable_winks, @winks_to_confiscate=yearly_end_confiscated_winks_From_customer_balance, 
	@total_conficated_winks= year_end_total_winks_From_wink_confiscated_detail,
	@campaign_total_winks = campaign_total_winks,
	@campaign_total_winks_confiscated = campaign_total_winks_confiscated,
	@total_winks_For_customer_to_redeem = total_winks_For_customer_to_redeem   from @T 

	--if balance not equal to expected
	--print message as well as save info into DB 
	if (@current_avaiable_winks != @final_winks_after_winks_expired or
		(@prev_total_winks_For_customer_to_redeem + @prev_winks_to_confiscate)!= @total_winks_For_customer_to_redeem )
	BEGIN
		--print the msg
		
		set @msg = 'expected final winks:' +  Convert(varchar(50),@final_winks_after_winks_expired) + ',current available winks:' +
			 Convert(varchar(50),@current_avaiable_winks) +
			 ',year end total winks confiscated:' +  Convert(varchar(50),@total_conficated_winks) +
			 ',compaign total winks:' + Convert(varchar(50),@campaign_total_winks) +
			 ',campaign_total_winks_confiscated:' + Convert(varchar(50),@campaign_total_winks_confiscated) +
			 ',total winks for customer to redeem:' + Convert(varchar(50),@total_winks_For_customer_to_redeem);

		print(@msg);
		INSERT INTO wink_store_procedure_log(sp_name,msg_type, msg_content,created_time)
			values('YearEndWinkExpiredSteps','ERROR',@msg,@current_time);
	END
	ELSE
	BEGIN
		set @msg = 'Current available winks:' + Convert(varchar(50),@current_avaiable_winks) +
			 ',winks confiscated:' + Convert(varchar(50),@total_conficated_winks)+
			 ',compaign total winks:' + Convert(varchar(50),@campaign_total_winks) +
			 ',campaign_total_winks_confiscated:' + Convert(varchar(50),@campaign_total_winks_confiscated) +
			 ',total winks for customer to redeem:' + Convert(varchar(50),@total_winks_For_customer_to_redeem);

	 	INSERT INTO wink_store_procedure_log(sp_name,msg_type, msg_content,created_time)
			values('YearEndWinkExpiredSteps','OK', @msg,@current_time);
	END
	-- check the customer balance
	-- if check customer balance fail, save the info into DB
	-- on beta, always failed because some customer's winks not balanced with redeemed.
	Declare @T2 Table 
	(RESPONSE_CODE int, response_message VARCHAR(1024))

	Declare @RESPONSE_CODE int, @response_message VARCHAR(1024)
	Insert @T2 Exec Check_Customer_Balance_For_internal
	select @RESPONSE_CODE = RESPONSE_CODE, @response_message = response_message from @T2;

	if (@RESPONSE_CODE = 1) 
		 INSERT INTO wink_store_procedure_log(sp_name,msg_type, msg_content, created_time)
			values('YearEndWinkExpiredSteps','OK','NO Error',@current_time);
	ELSE
			INSERT INTO wink_store_procedure_log(sp_name,msg_type, msg_content,created_time)
			values('YearEndWinkExpiredSteps','WARNING', @response_message,@current_time);
	-- Run total scans for dashboard yearly, no such storeprocedure on Beta

	--EXEC	@return_value = [dbo].[Execute_TotalScan_YearEnd_ForMonthly]
	--	@year = '2020'
	 
END TRY
 BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION YearEndWinkExpiredSteps; -- rollback to MySavePoint
			-- here to insert to tables to record the failed.
			INSERT INTO wink_store_procedure_log(sp_name,msg_type, msg_content,created_time)
			values('YearEndWinkExpiredSteps','ERROR', 'Failed to commit, rollback',@current_time);
        END
    END CATCH

END

