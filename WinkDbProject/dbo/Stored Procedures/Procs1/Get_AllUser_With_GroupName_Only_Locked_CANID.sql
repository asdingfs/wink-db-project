

CREATE PROCEDURE [dbo].[Get_AllUser_With_GroupName_Only_Locked_CANID]
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
	 
		
		select * from (

			Select Row_Number() over (order by customer.customer_id desc) as RowIndex,
			--customer.auth_token,
			customer.created_at,
			customer.customer_id,customer.date_of_birth,
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
			--customer.skin_name,
		    UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,

			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
			COUNT(*) OVER() AS total_count,
			
			(SELECT CANID1 FROM
				(
					SELECT can_id.customer_id  ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID
					FROM CAN_ID where can_id.customer_id = customer.customer_id	  
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID1,
				
			(SELECT CANID2 FROM
				(
					SELECT can_id.customer_id ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID   
					FROM CAN_ID where can_id.customer_id = customer.customer_id
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID2,

			(SELECT CANID3 FROM
				(
					SELECT can_id.customer_id ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID   
					FROM CAN_ID where can_id.customer_id = customer.customer_id
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID3

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
			or g.group_id = @imob_group_id5 or g.group_id = @imob_group_id6
			)

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
			where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@email))+'%') 
			and customer.status Like @status+'%'
			and subscribe_status Like @subscribe_status+'%'
			--and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
			and customer.skin_name like @skin+'%'
			and wink_team.team_name like @team+'%'
			and avatar.avatar_name like @avartar +'%'
			and (@phone_no is null OR customer.phone_no like @phone_no + '%')
			and (@customer_id is null OR customer.customer_id = @customer_id)
			and (@ip_address is null OR customer.ip_address = @ip_address)
			) as temp  
			where temp.RowIndex >= @intStartRow and temp.RowIndex <= @intEndRow
	END

	
	ELSE If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='')
	BEGIN

	print('Filter date not selecting locked account')
		
		select * from (

			Select Row_Number() over (order by customer.customer_id desc) as RowIndex,
			--customer.auth_token,
			customer.created_at,
			customer.customer_id,customer.date_of_birth,
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
			--customer.skin_name,
		    UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,

			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
			COUNT(*) OVER() AS total_count,
			
			(SELECT CANID1 FROM
				(
					SELECT can_id.customer_id  ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID
					FROM CAN_ID where can_id.customer_id = customer.customer_id	  
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID1,
				
			(SELECT CANID2 FROM
				(
					SELECT can_id.customer_id ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID   
					FROM CAN_ID where can_id.customer_id = customer.customer_id
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID2,

			(SELECT CANID3 FROM
				(
					SELECT can_id.customer_id ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID   
					FROM CAN_ID where can_id.customer_id = customer.customer_id
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID3

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
			or g.group_id = @imob_group_id5 or g.group_id = @imob_group_id6
			)
			where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@email))+'%') 
			and customer.status Like @status+'%'
			and subscribe_status Like @subscribe_status+'%'
			and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
			and customer.skin_name like @skin+'%'
			and wink_team.team_name like @team+'%'
			and avatar.avatar_name like @avartar +'%'
			and (@phone_no is null OR customer.phone_no like @phone_no + '%')
			and (@customer_id is null OR customer.customer_id = @customer_id)
			and (@ip_address is null OR customer.ip_address = @ip_address)
			) as temp  
			where temp.RowIndex >= @intStartRow and temp.RowIndex <= @intEndRow
	END
		
	ELSE	
	BEGIN
	print('Not Filter date')
		select * from (
			Select Row_Number() over (order by customer.customer_id desc) as RowIndex, 
			--customer.auth_token,
			customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
			customer.status,customer.group_id,
			customer.phone_no,
			customer.subscribe_status,
		    customer.nick_name,
		    UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
			--customer.skin_name,
			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
			g.group_name,
			COUNT(*) OVER() AS total_count,

			(SELECT CANID1 FROM
				(
					SELECT can_id.customer_id  ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID
					FROM CAN_ID where can_id.customer_id = customer.customer_id	  
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID1,
				
			(SELECT CANID2 FROM
				(
					SELECT can_id.customer_id ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID   
					FROM CAN_ID where can_id.customer_id = customer.customer_id
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID2,

			(SELECT CANID3 FROM
				(
					SELECT can_id.customer_id ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID   
					FROM CAN_ID where can_id.customer_id = customer.customer_id
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2) as CANID3
			
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
			or g.group_id = @imob_group_id5 or g.group_id = @imob_group_id6
			)
			where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@email))+'%') 
			and customer.status Like @status+'%'
			and subscribe_status Like @subscribe_status+'%'
			and customer.skin_name like @skin+'%'
			and wink_team.team_name like @team+'%'
			and avatar.avatar_name like @avartar +'%'
			and (@phone_no is null OR customer.phone_no like @phone_no + '%')
			and (@customer_id is null OR customer.customer_id = @customer_id)
			and (@ip_address is null OR customer.ip_address = @ip_address)
			) as temp
			where temp.RowIndex >= @intStartRow and temp.RowIndex <= @intEndRow
	END
END




