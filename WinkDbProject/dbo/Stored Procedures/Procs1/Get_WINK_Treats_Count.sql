CREATE PROCEDURE [dbo].[Get_WINK_Treats_Count] 
	(@auth varchar(150))
AS
BEGIN
	Declare @customer_id int 
	Declare @phone_no varchar(10)
	Declare @CURRENT_DATETIME datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output

	select @customer_id= customer_id, @phone_no = phone_no from customer where auth_token= @auth and [status] like 'enable'
	print (@customer_id)
	
	IF Exists(
			select 1 from [winkwink].[dbo].winktag_campaign  as  d
			where d.winktag_type like 'wink_fee'
			AND d.winktag_status like '1'
			AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
			AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date) 
		)	  
		BEGIN
			select count(*) as winkTreatsCount from
			(
				select d.campaign_id 
				from [winkwink].[dbo].winktag_campaign  as  d
				where d.winktag_type like 'wink_fee'
				AND d.winktag_status like '1'
				AND CONVERT(datetime,@CURRENT_DATETIME) >= CONVERT(datetime,from_date)
				AND CONVERT(datetime,@CURRENT_DATETIME) <= CONVERT(datetime,to_date) 

				union

				Select w.campaign_id 
				from winktag_campaign as w, winktag_approved_phone_list as a 
				where a.campaign_id = w.campaign_id
				and w.winktag_type like 'wink_fee'
				and a.phone_no = @phone_no
				and w.internal_testing_status =1  
				and w.winktag_status like '0' 
			) as T;
		END
		ELSE 
		BEGIN
			print ('Check for internal test')
			--- Check for internal test
			IF EXISTS(
				Select 1 from winktag_campaign as  w, winktag_approved_phone_list as a 
				where a.campaign_id = w.campaign_id
				and w.winktag_type like 'wink_fee'
				and a.phone_no = @phone_no
				and w.internal_testing_status =1  
				and w.winktag_status like '0' 
			)
			BEGIN
				Select count(w.campaign_id) as winkTreatsCount
				from winktag_campaign as w, winktag_approved_phone_list as a 
				where a.campaign_id = w.campaign_id
				and w.winktag_type like 'wink_fee'
				and a.phone_no = @phone_no
				and w.internal_testing_status =1  
				and w.winktag_status like '0' 
			END
			ELSE
			BEGIN
				select 0 as winkTreatsCount;
			END
		END
END