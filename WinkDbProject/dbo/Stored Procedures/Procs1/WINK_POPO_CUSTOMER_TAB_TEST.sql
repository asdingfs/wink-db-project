
CREATE PROCEDURE [dbo].[WINK_POPO_CUSTOMER_TAB_TEST]
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
	  @pagesize int,
	  @canid varchar(50)
	  )
AS
BEGIN

	Declare @Table Table 
	(
		total_count varchar(50),
		rowindex varchar(50),
		auth_token varchar(255),
		created_at varchar(255),
		customer_id varchar(255),
		date_of_birth varchar(255),
		email varchar(255),
		first_name varchar(255),
		last_name varchar(255),
		password varchar(255),
		gender varchar(255),
		status varchar(255),
		group_id varchar(255),
		phone_no varchar(255),
		subscribe_status varchar(255),
		nick_name varchar(255),
		skin_name varchar(255),
		team_name varchar(255),
		avatar_name varchar(255),
		ip_address varchar(255),
		canid1 varchar(255),
		canid2 varchar(255),
		canid3 varchar(255)
	)


	--=============set start row and end row=============
	DECLARE @intStartRow int;
	DECLARE @intEndRow int;

	SET @intStartRow = (@pageno -1) * @pagesize + 1;
	SET @intEndRow = @pageno * @pagesize;
	--=============set start row and end row=============

	DECLARE @SQL NVARCHAR(4000)

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
	
	If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='')
	BEGIN
		
		select * from (

			Select Row_Number() over (order by customer.created_at desc) as RowIndex,customer.auth_token,customer.created_at,
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
			where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE @email+'%' 
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
		
		/*
		select * from (
			Select Row_Number() over (order by customer.created_at desc) as RowIndex, customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
			customer.status,customer.group_id,
			customer.phone_no,
			customer.subscribe_status,
		    customer.nick_name,
		    UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
			--customer.skin_name,
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
			where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE @email+'%' 
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
			*/

			/*
			Insert @Table EXEC SP_EXECUTESQL @SQL,N'@InnerParamcol INT,@InnerParamcol2 INT',@customer_id,@ip_address
			Select * from @Table
			*/

			/*
			select * from VW_CUSTOMER_DETAILS
			*/

			SET @SQL = 'SELECT * FROM (SELECT COUNT(*) OVER() AS total_count,Row_Number() over (order by vw_c.created_at desc) as RowIndex,* 
			FROM VW_CUSTOMER_DETAILS as vw_c with (Nolock) WHERE 1= 1'

			IF @customer_id IS NOT NULL
			SET @SQL = @SQL + ' AND customer_id=@InnerParamcol1'

			IF @ip_address IS NOT NULL
			SET @SQL = @SQL + ' AND ip_address = @InnerParamcol2'

			IF @phone_no IS NOT NULL
			SET @SQL = @SQL + ' AND phone_no=@InnerParamcol3'

			IF @avartar IS NOT NULL
			SET @SQL = @SQL + ' AND avatar_name like @InnerParamcol4 +''%'''

			IF @team IS NOT NULL
			SET @SQL = @SQL + ' AND team_name like @InnerParamcol5 +''%'''

			IF @skin IS NOT NULL
			SET @SQL = @SQL + ' AND skin_name like @InnerParamcol6 +''%'''

			IF @status IS NOT NULL
			SET @SQL = @SQL + ' AND status like @InnerParamcol7 +''%'''

			IF @subscribe_status IS NOT NULL
			SET @SQL = @SQL + ' AND subscribe_status like @InnerParamcol8 +''%'''

			IF @email IS NOT NULL
			SET @SQL = @SQL + ' AND Lower(email) LIKE @InnerParamcol9 +''%'''

			--Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%'

			IF @email IS NOT NULL
			SET @SQL = @SQL + ' AND Lower(email) LIKE @InnerParamcol9 +''%'''



			IF @intStartRow IS NOT NULL
			SET @SQL = @SQL + ') AS temp WHERE temp.RowIndex >= @InnerParamcol9'

			IF @intEndRow IS NOT NULL
			SET @SQL = @SQL + ' AND temp.RowIndex <=  @InnerParamcol10'

			PRINT @SQL

			Insert @Table EXEC SP_EXECUTESQL @SQL,
			N'@InnerParamcol varchar(255),
			@InnerParamcol2 varchar(255),
			@InnerParamcol3 varchar(255),
			@InnerParamcol4 varchar(255),
			@InnerParamcol5 varchar(255),
			@InnerParamcol6 varchar(255),
			@InnerParamcol7 varchar(255),
			@InnerParamcol8 varchar(255),
			@InnerParamcol9 INT,
			@InnerParamcol10 INT',@customer_id,@ip_address,@phone_no,@avartar,@team,@skin,@status,@subscribe_status,@intStartRow,@intEndRow
			Select * from @Table

			END
END




