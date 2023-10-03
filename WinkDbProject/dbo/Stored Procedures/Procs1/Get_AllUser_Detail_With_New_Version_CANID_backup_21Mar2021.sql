
CREATE PROCEDURE [dbo].[Get_AllUser_Detail_With_New_Version_CANID_backup_21Mar2021]
	 (@email varchar(150),
	  @name varchar (200),
	  @status varchar(20),
	  @created_from varchar(50),
	  @created_to varchar(50),
	  @ip_address varchar(100),
	  @customer_id varchar(100),
	  @subscribe_status varchar(10),
	  @phone_staus varchar(10),
	  @phone_no varchar(20),
	  @team varchar(10),
	  @skin varchar(10),
	  @avartar varchar(35),
	  @group_id varchar(10),
	  @gender varchar(10),
	  @canid varchar(100),
	  @dob varchar(100),
	  @wid varchar(100),
	  @pageno int,
	  @pagesize int
	 
	  )
AS
BEGIN

	DECLARE @intStartRow int;
	DECLARE @intEndRow int;

	SET @intStartRow = (@pageno -1) * @pagesize + 1;
	SET @intEndRow = @pageno * @pagesize;

	Declare @imob_group_id1 int ;
	Declare @imob_group_id2 int ;
	Declare @imob_group_id3 int ;
	Declare @imob_group_id4 int ;
	Declare @imob_group_id5 int ;
	Declare @imob_group_id6 int ;

	set @imob_group_id1 =@group_id;
	set @imob_group_id2 =@group_id;
	set @imob_group_id3 =@group_id;
	set @imob_group_id4 =@group_id;
	set @imob_group_id5 =@group_id;
	set @imob_group_id6 =@group_id;

	If (@wid is null OR @wid ='')
	BEGIN
		set @wid = NULL
	END

	If (@canid is null OR @canid ='')
	BEGIN
		set @canid = NULL
	END

	If (@dob is null OR @dob ='')
	BEGIN
		set @dob = NULL
	END
	
	If (@gender is null OR @gender ='')
	BEGIN
		set @gender = NULL
	END

	IF (@gender ='No')
	BEGIN
		set @gender = ''
	END
 

	If (@phone_no is null OR @phone_no ='')
	BEGIN
		set @phone_no = NULL
	END
 
	If (@ip_address is null OR @ip_address ='')
	BEGIN
		set @ip_address = NULL
	END
 
	If (@customer_id is null OR @customer_id ='')
	BEGIN
		set @customer_id = NULL
	END
	If (@pageno is null OR @pageno ='' OR @pageno = 0)
	BEGIN
		set @pageno = 1
	END

	If (@pagesize is null OR @pagesize ='' OR @pagesize = 0)
	BEGIN
		set @pagesize = 100
	END

	if(@group_id is null or @group_id ='')
	BEGIN
	set @group_id = NULL

	END
	Else if(@group_id = 1)
	BEGIN
	set @imob_group_id1 =9;
	set @imob_group_id2 =7;
	set @imob_group_id3 =8;
	set @imob_group_id4 =11;
	set @imob_group_id5 =12;
	set @imob_group_id6 =15;
	END



	If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='' AND @status ='disable' )
	BEGIN
	 print('Filter Locked')
	 
		IF (@canid is null)
		BEGIN
		select * from (
			Select Row_Number() over (order by customer.customer_id desc) as RowIndex,
			customer.created_at,
			customer.customer_id,
			customer.WID AS W_id,
			customer.date_of_birth,
			customer.email,
			customer.first_name,
			customer.last_name,
			customer.password,
			customer.gender,
			customer.status,
			customer.group_id,
			customer.phone_no,
			customer.subscribe_status,
			customer.nick_name,
			g.group_name,
		    UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
			COUNT(*) OVER() AS total_count,
			(	select count(*) 
				FROM can_id
				where can_id.customer_id = customer.customer_id
				group by customer_id) AS CANID_Count,
  
			(
				select count(*) 
				FROM push_device_token
				where push_device_token.customer_id = customer.customer_id
				group by customer_id
			) AS token_count
			from customer
			join wink_team
			on customer.team_id = wink_team.team_id
			join avatar
			on customer.avatar_id = avatar.id
			join customer_group as g
			on customer.group_id = g.group_id
			and (@group_id is null or g.group_id = @group_id
			or g.group_id = @imob_group_id1 or g.group_id = @imob_group_id2 
			or g.group_id = @imob_group_id3 or g.group_id = @imob_group_id4
			or g.group_id = @imob_group_id5 or g.group_id = @imob_group_id6)
			--------- Join Lock Account
			Join 
			(
			    select distinct customer.customer_id  from customer where
				status = 'disable'
				and 
				(( customer_id in 
				 (select c.customer_id from action_log as a
				join custmer_old_detail_log as b
				on a.action_id = b.action_id 
				and b.Status ='enable'
				join custmer_deletion_log as c
				on c.action_id = a.action_id
				and c.Status = 'disable'
				where cast(a.action_time as date) >= CAST(@created_from as date)
				and cast(a.action_time as date) <= CAST(@created_to as date)))

				OR (customer_id in (select customer_id from System_Log where action_status ='disable'
				and  cast(created_at as date) >= CAST(@created_from as date)
				and cast(created_at as date) <= CAST(@created_to as date)))

			     )
			) As locked_customer

			on customer.customer_id = locked_customer.customer_id
			and customer.status = 'disable'
					
			where  ((@name is null) or (Lower(LTRIM(RTRIM(customer.first_name))  +' ' + LTRIM(RTRIM(customer.last_name))) LIKE '%'+Lower(@name)+'%'))
			AND Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@email))+'%') 			
			and customer.status Like @status+'%'
			and subscribe_status Like @subscribe_status+'%'
			and customer.skin_name like @skin+'%'
			and wink_team.team_name like @team+'%'
			and avatar.avatar_name like @avartar +'%'
			and (@phone_no is null OR customer.phone_no like @phone_no + '%')
			and (@customer_id is null OR customer.customer_id = @customer_id)
			and (@ip_address is null OR customer.ip_address = @ip_address)
			and (@gender is null OR customer.gender =@gender)
			and (@dob is null OR customer.date_of_birth =@dob)
			and (@wid is null OR customer.WID =@wid)
			             
			) as temp  
			where temp.RowIndex >= @intStartRow and temp.RowIndex <= @intEndRow
	
	    END
		ELSE 
		BEGIN
			select * from (
				Select Row_Number() over (order by customer.customer_id desc) as RowIndex,
				customer.created_at,
				customer.customer_id,
				customer.WID AS W_id,
				customer.date_of_birth,
				customer.email,
				customer.first_name,
				customer.last_name,
				customer.password,
				customer.gender,
				customer.status,
				customer.group_id,
				customer.phone_no,
				customer.subscribe_status,
				customer.nick_name,
				g.group_name,
				UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
				wink_team.team_name,
				avatar.avatar_name,
				customer.ip_address,
				COUNT(*) OVER() AS total_count,
				(	select count(*) 
					FROM can_id
					where can_id.customer_id = customer.customer_id
					group by customer_id) AS CANID_Count,
				(
					select count(*) 
					FROM push_device_token
					where push_device_token.customer_id = customer.customer_id
					group by customer_id
				) AS token_count
				from customer
				join 
				(select distinct customer_id  from customer as w 
						where EXISTS  (select customer_id  FROM can_id where customer_canid like @canid +'%')
				) as can
				on can.customer_id = customer.customer_id
				join wink_team
				on customer.team_id = wink_team.team_id
				join avatar
				on customer.avatar_id = avatar.id
				join customer_group as g
				on customer.group_id = g.group_id
				and (@group_id is null or g.group_id = @group_id
				or g.group_id = @imob_group_id1 or g.group_id = @imob_group_id2 
				or g.group_id = @imob_group_id3 or g.group_id = @imob_group_id4
				or g.group_id = @imob_group_id5 or g.group_id = @imob_group_id6)
				--------- Join Lock Account
				Join 
				(
					select distinct customer.customer_id  from customer where
					status = 'disable'
					and 
					(( customer_id in 
					 (select c.customer_id from action_log as a
					join custmer_old_detail_log as b
					on a.action_id = b.action_id 
					and b.Status ='enable'
					join custmer_deletion_log as c
					on c.action_id = a.action_id
					and c.Status = 'disable'
					where cast(a.action_time as date) >= CAST(@created_from as date)
					and cast(a.action_time as date) <= CAST(@created_to as date)))

					OR (customer_id in (select customer_id from System_Log where action_status ='disable'
					and  cast(created_at as date) >= CAST(@created_from as date)
					and cast(created_at as date) <= CAST(@created_to as date)))
					)
				) As locked_customer
				on customer.customer_id = locked_customer.customer_id
				and customer.status = 'disable'
				where  ((@name is null) or (Lower(LTRIM(RTRIM(customer.first_name))  +' ' + LTRIM(RTRIM(customer.last_name))) LIKE '%'+Lower(@name)+'%'))
				AND Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@email))+'%') 			
				and customer.status Like @status+'%'
				and subscribe_status Like @subscribe_status+'%'
				and customer.skin_name like @skin+'%'
				and wink_team.team_name like @team+'%'
				and avatar.avatar_name like @avartar +'%'
				and (@phone_no is null OR customer.phone_no like @phone_no + '%')
				and (@customer_id is null OR customer.customer_id = @customer_id)
				and (@ip_address is null OR customer.ip_address = @ip_address)
				and (@gender is null OR customer.gender =@gender)
				and (@dob is null OR customer.date_of_birth =@dob)
				and (@wid is null OR customer.WID =@wid)
			             
				) as temp  
				where temp.RowIndex >= @intStartRow and temp.RowIndex <= @intEndRow

		END
	
	END
	ELSE If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='')
	BEGIN
		select * from (
			Select Row_Number() over (order by customer.customer_id desc) as RowIndex,
			customer.created_at,
			customer.customer_id,
			customer.WID AS W_id,
			customer.date_of_birth,
			customer.email,
			customer.first_name,
			customer.last_name,
			customer.[password],
			customer.gender,
			customer.[status],
			customer.group_id,
			customer.phone_no,
			customer.subscribe_status,
			customer.nick_name,
			g.group_name,
		    UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
			COUNT(*) OVER() AS total_count,
			(	select count(*) 
				FROM can_id
				where can_id.customer_id = customer.customer_id
				group by customer_id
			) AS CANID_Count,
			(
				select count(*) 
				FROM push_device_token
				where push_device_token.customer_id = customer.customer_id
				group by customer_id
			) AS token_count
			from customer
			join wink_team
			on customer.team_id = wink_team.team_id
			join avatar
			on customer.avatar_id = avatar.id
			join customer_group as g
			on customer.group_id = g.group_id
			and (@group_id is null or g.group_id = @group_id
			or g.group_id = @imob_group_id1 or g.group_id = @imob_group_id2 
			or g.group_id = @imob_group_id3 or g.group_id = @imob_group_id4
			or g.group_id = @imob_group_id5 or g.group_id = @imob_group_id6)
			where  ((@name is null) or (Lower(LTRIM(RTRIM(customer.first_name))  +' ' + LTRIM(RTRIM(customer.last_name))) LIKE '%'+Lower(@name)+'%'))
			AND Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@email))+'%') 			
			and customer.status Like @status+'%'
			and subscribe_status Like @subscribe_status+'%'
			and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
			and customer.skin_name like @skin+'%'
			and wink_team.team_name like @team+'%'
			and avatar.avatar_name like @avartar +'%'
			and (@phone_no is null OR customer.phone_no like @phone_no + '%')
			and (@customer_id is null OR customer.customer_id = @customer_id)
			and (@ip_address is null OR customer.ip_address = @ip_address)
			and (@gender is null OR customer.gender =@gender)
			and (@dob is null OR customer.date_of_birth =@dob)
			and (@wid is null OR customer.WID =@wid)
			and (@canid is null OR customer.customer_id in (select customer_id  FROM can_id where customer_canid like  @canid+'%'))
		) as temp  
		where temp.RowIndex >= @intStartRow and temp.RowIndex <= @intEndRow
	END
	ELSE	
	BEGIN
		select * from (
			Select Row_Number() over (order by customer.customer_id desc) as RowIndex,
			customer.created_at,customer.customer_id,
			customer.WID AS W_id,
			customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
			customer.status,customer.group_id,
			customer.phone_no,
			customer.subscribe_status,
			customer.nick_name,
			UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
			g.group_name,
			COUNT(*) OVER() AS total_count,
			(
				select count(*) 
				FROM can_id
				where can_id.customer_id = customer.customer_id
				group by customer_id
			) AS CANID_Count,
			(
				select count(*) 
				FROM push_device_token
				where push_device_token.customer_id = customer.customer_id
				group by customer_id
			) AS token_count
			from customer
			join wink_team
			on customer.team_id = wink_team.team_id
			join avatar
			on customer.avatar_id = avatar.id
			join customer_group as g
			on customer.group_id = g.group_id
			and (@group_id is null or g.group_id = @group_id
			or g.group_id = @imob_group_id1 or g.group_id = @imob_group_id2 
			or g.group_id = @imob_group_id3 or g.group_id = @imob_group_id4
			or g.group_id = @imob_group_id5 or g.group_id = @imob_group_id6)
			
			where  ((@name is null) or (Lower(LTRIM(RTRIM(customer.first_name))  +' ' + LTRIM(RTRIM(customer.last_name))) LIKE '%'+Lower(@name)+'%'))
			AND Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@email))+'%') 			
			and customer.status Like @status+'%'
			and subscribe_status Like @subscribe_status+'%'
			and customer.skin_name like @skin+'%'
			and wink_team.team_name like @team+'%'
			and avatar.avatar_name like @avartar +'%'
			and (@phone_no is null OR customer.phone_no like @phone_no + '%')
			and (@customer_id is null OR customer.customer_id = @customer_id)
			and (@ip_address is null OR customer.ip_address = @ip_address)
			and (@gender is null OR customer.gender =@gender)
			and (@dob is null OR customer.date_of_birth = @dob)
			and (@wid is null OR customer.WID =@wid)
			and (@canid is null OR customer.customer_id in (select customer_id  FROM can_id where can_id.customer_canid like @canid +'%'))
		) as temp
		where temp.RowIndex >= @intStartRow and temp.RowIndex <= @intEndRow
	END
END






