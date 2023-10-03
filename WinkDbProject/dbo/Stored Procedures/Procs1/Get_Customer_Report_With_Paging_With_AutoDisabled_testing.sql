CREATE PROCEDURE [dbo].[Get_Customer_Report_With_Paging_With_AutoDisabled_testing]      
 (
  @customer_name varchar(150),      
  @customer_email varchar(150),
  @ip_address varchar(50),
  @status varchar(50),
  @customer_id INT,
  @ip_scanned varchar(30),
  @wid varchar(50),
  @group_id varchar(10),
  @intPage int,
  @intPageSize int
	
  )      
AS      
BEGIN     

	DECLARE @intStartRow int;
    DECLARE @intEndRow int;
    DECLARE @total int
  
    SET @intStartRow = (@intPage -1) * @intPageSize + 1;
    SET @intEndRow = @intPage * @intPageSize;
    
    IF(@wid is null or @wid = '')
	BEGIN
		SET @wid = null;
	END
	IF(@customer_name is null or @customer_name = '')
	BEGIN
		SET @customer_name = null;
	END

	IF(@customer_email is null or @customer_email = '')
	BEGIN
		SET @customer_email = null;
	END
	IF(@ip_address is null or @ip_address ='')
	BEGIN 
		SET @ip_address = null;
	END
	IF(@ip_scanned is null or @ip_scanned ='')
	BEGIN 
		SET @ip_scanned = null;
	END
	IF(@status is null or @status = '')
	BEGIN
		SET @status = null;
	END

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

	if(@group_id is null or @group_id ='')
	BEGIN
		SET @group_id = NULL;
	END
	ELSE IF(@group_id = 1)
	BEGIN
		SET @imob_group_id1 =9;
		SET @imob_group_id2 =7;
		SET @imob_group_id3 =8;
		SET @imob_group_id4 =11;
		SET @imob_group_id5 =12;
		SET @imob_group_id6 =15;
	END
     
	Declare @CURRENT_DATETIME Datetime      
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT   
	DECLARE @auto_status varchar(5)     

	CREATE TABLE #Customer_AutoLog_Table      
	 (      
	 customer_id int,
	 locked_desc varchar(50)
	 ) 
 
	 --pp add
	IF OBJECT_ID(N'tempdb..#temp') IS NOT NULL
	BEGIN
		DROP TABLE #temp
	END
	CREATE TABLE #temp      
 (      
 customer_id int,
 created_at date
 ) 
 
	insert into #temp (created_at,customer_id)
	(
		select CAST (MAX(a.action_time) as datetime) as date1, c.customer_id 
		from custmer_deletion_log as c,action_log as a where [Status]='enable' and a.action_id=c.action_id group by c.customer_id
	) 
	 --pp add

	SET @auto_status ='';
	IF(@status='auto')
	BEGIN
		SET @status ='disable';
		SET @auto_status ='1';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select t.customer_id,@status
			from #temp as t
			right join System_Log as s on s.customer_id = t.customer_id
			group by t.created_at, t.customer_id,s.reason
			having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
			and s.reason != 'invalid_login' and s.reason != 'lbs'
		) 
	END
	ELSE IF(@status='login')
	BEGIN
		Print('Login');
		SET @status ='disable';
		SET @auto_status ='2';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select t.customer_id, @status
			from #temp as t
			right join System_Log as s on s.customer_id = t.customer_id
			group by t.created_at, t.customer_id,s.reason
			having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
			and s.reason = 'invalid_login'
		)
	END
	ELSE IF(@status='lbs')
	BEGIN
		Print('lbs');
		SET @status ='disable';
		SET @auto_status ='3';

		insert into #Customer_AutoLog_Table (customer_id, locked_desc)
		(
			select t.customer_id, @status
			from #temp as t
			right join System_Log as s on s.customer_id = t.customer_id
			group by t.created_at, t.customer_id,s.reason
			having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
			and s.reason = 'lbs'
		)
	END
	ELSE IF(@status='IP')
	BEGIN
		Print('IP');
		SET @status ='disable';
		SET @auto_status ='4';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select t.customer_id,@status
			from #temp as t
			right join System_Log as s on s.customer_id = t.customer_id
			group by t.created_at, t.customer_id,s.reason
			having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
			and s.reason = 'SameIP_SameCode'
		)
	END
	ELSE IF(@status='tokenm')
	BEGIN
		Print('tokenm');
		SET @status ='disable';
		SET @auto_status ='5';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer_id,locked_desc 
			from System_Log 
			where reason = 'Token_M'
		)
	END
	ELSE IF(@status='multipleinstalls')
	BEGIN
		Print('multipleinstalls');

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer_id,locked_desc 
			from System_Log 
			where reason = @status
		)

		SET @status ='disable';
		SET @auto_status ='6';
	END
	----------------------No Need to Change-------------------------------
 
	IF(@customer_id IS NOT NULL AND @customer_id != '')    
	BEGIN
		--------------------------------IP Is not null ---------------------------------------
		IF(@ip_address is not null and @ip_address !='')
		BEGIN
			select f.customer_id,f.total_points,f.total_winks,f.total_used_evouchers,
			f.used_points,f.used_winks,f.confiscated_points,
			f.confiscated_winks,f.expired_winks,
			f.first_name,f.last_name ,f.email,f.[status],f.ip_address,f.ip_scanned,f.WID,f.[group],
			intRow,total_count,
			ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0) as balanced_evouchers
			,ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0) as balanced_points
			,ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0) as balanced_winks
			,ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
			ISNULL (total_evouchers,0) as Total_eVoucher , 
			ISNULL (No_Of_Scan,0) as No_Of_Scan,
			ISNULL(Total_Winks,0) as Total_Winks,
			ISNULL (confiscated_winks,0) as total_winks_confiscated,
			ISNULL (confiscated_points,0) as total_points_confiscated,
			ISNULL(used_winks,0) as Redeemed_Winks
			from
			( 
				select * from
				(
					select c.customer_id,c.total_points,c.total_winks,c.total_used_evouchers,
					c.used_points,c.used_winks,c.confiscated_points,c.total_evouchers,
					c.confiscated_winks,c.expired_winks,
					c.first_name,c.last_name ,c.email,c.[status],c.ip_address,c.ip_scanned,c.WID, c.[group],
					ROW_NUMBER() OVER(ORDER BY isnull(No_Of_Scan,0) DESC) as intRow,
					total_count ,
					ISNULL(No_Of_Scan,0) as No_Of_Scan
					from 
					(
						select a.customer_id,a.total_points,a.total_winks,a.total_used_evouchers,
						a.used_points,a.used_winks,a.confiscated_points,a.total_evouchers,
						a.confiscated_winks,a.expired_winks,COUNT(*) OVER() AS total_count,
						b.first_name,b.last_name ,b.email,b.locked_desc as [status],b.ip_address,b.ip_scanned,b.WID,b.[group]
						from customer_balance as a
						join
						(
							select customer.*,temp.locked_desc,cusGroup.group_name as [group] 
							from customer 
							join customer_group as cusGroup
							on customer.group_id = cusGroup.group_id
							and (@group_id is null or cusGroup.group_id = @group_id
							or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
							or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
							or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
							inner join #Customer_AutoLog_Table temp
							on customer.customer_id = temp.customer_id
						) as b
						on a.customer_id = b.customer_id
						where a.customer_id != 15
						AND (@ip_scanned is null or b.ip_scanned like '%'+ @ip_scanned+'%')
						AND (@wid is null or b.WID like '%'+ @wid+'%')
						AND (@customer_name is null  or Lower(b.first_name +' '+ b.last_name) LIKE Lower( '%'+@customer_name +'%'))      
						AND (@customer_email is null  or Lower(b.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
						AND (@status is null  or Lower(b.[status]) LIKE Lower(@status+'%'))
						and b.ip_address like '%'+ @ip_address+'%'
						and a.customer_id = @customer_id
						and  a.customer_id in (select customer_id from #Customer_AutoLog_Table)
					) as c
					left join 
					(
						select count(*) as No_Of_Scan ,customer_id
						from customer_earned_points 
						Group by customer_id
                     	Having COUNT(*)>0
					) as d
					on d.customer_id = c.customer_id
				) as e
				where e.intRow between @intStartRow and @intEndRow
			) as f
			left Join 
			-----------------------------------
			(select COUNT(*) AS 

				Expired_Evoucher,customer_id from customer_earned_evouchers 
				where CAST (customer_earned_evouchers.expired_date AS 

				Date) <= CAST (@CURRENT_DATETIME AS Date)  
				and customer_earned_evouchers.used_status=0         
			  
				Group By customer_id 
			        
			)as expired_eVouchers_temp
			        
			on f.customer_id = expired_eVouchers_temp.customer_id
			where ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0)>=0
			and ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0)>=0
			and ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0)>=0
			order by intRow 
		END
		------------------------------ Ip scanned is not null -----------------------
		ELSE IF (@ip_scanned is not null and @ip_scanned !='')
		BEGIN
			select f.customer_id,f.total_points,f.total_winks,f.total_used_evouchers,
			f.used_points,f.used_winks,f.confiscated_points,
			f.confiscated_winks,f.expired_winks,
			f.first_name,f.last_name ,f.email,f.status,f.ip_address,f.ip_scanned,f.WID,f.[group],
			intRow,total_count,
			ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0) as balanced_evouchers
			,ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0) as balanced_points
			,ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0) as balanced_winks
			,ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
			ISNULL (total_evouchers,0) as Total_eVoucher , 
			ISNULL (No_Of_Scan,0) as No_Of_Scan,
			ISNULL(Total_Winks,0) as Total_Winks,
			ISNULL (confiscated_winks,0) as total_winks_confiscated,
			ISNULL (confiscated_points,0) as total_points_confiscated,
			ISNULL(used_winks,0) as Redeemed_Winks
				
					 
				from
			( select * from
 
			(select c.customer_id,c.total_points,c.total_winks,c.total_used_evouchers,
				c.used_points,c.used_winks,c.confiscated_points,c.total_evouchers,
				c.confiscated_winks,c.expired_winks,
				c.first_name,c.last_name ,c.email,c.status,c.ip_address,c.ip_scanned,c.WID,c.[group],
				ROW_NUMBER() OVER(ORDER BY isnull(No_Of_Scan,0) DESC) as intRow,
				total_count ,
				ISNULL(No_Of_Scan,0) as No_Of_Scan
					  
					  
				from 
					  

			(select a.customer_id,a.total_points,a.total_winks,a.total_used_evouchers,
				a.used_points,a.used_winks,a.confiscated_points,a.total_evouchers,
				a.confiscated_winks,a.expired_winks,COUNT(*) OVER() AS total_count,
				b.first_name,b.last_name ,b.email,b.locked_desc as [status],b.ip_address,b.ip_scanned
				,b.WID,b.[group]	   
					   
				from customer_balance as a
					 
			join
			(
				select customer.*,temp.locked_desc,cusGroup.group_name as [group]
				from customer
				join customer_group as cusGroup
				on customer.group_id = cusGroup.group_id
				and (@group_id is null or cusGroup.group_id = @group_id
				or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
				or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
				or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
				inner join #Customer_AutoLog_Table temp
				on customer.customer_id = temp.customer_id
			) as b

				on a.customer_id = b.customer_id
				where a.customer_id != 15
				AND (@wid is null or b.WID like '%'+ @wid+'%')
				AND (@customer_name is null  or Lower(b.first_name +' '+ b.last_name) LIKE Lower( '%'+@customer_name +'%'))      
				AND (@customer_email is null  or Lower(b.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
				AND (@status is null  or Lower(b.[status]) LIKE Lower(@status+'%'))
				AND b.ip_scanned like '%'+ @ip_scanned+'%'
				AND a.customer_id = @customer_id
				AND  a.customer_id in (select customer_id from #Customer_AutoLog_Table)
				)
				as c
				left join 
				(
				select count(*) as No_Of_Scan ,customer_id 
					
									from customer_earned_points 
									Group by customer_id
                     				Having COUNT(*)>0
				) as d
				on d.customer_id = c.customer_id
					  
				) as e
				where e.intRow between @intStartRow and @intEndRow
				) as f
				left Join 
				-----------------------------------
			(select COUNT(*) AS 

				Expired_Evoucher,customer_id from customer_earned_evouchers 
				where CAST (customer_earned_evouchers.expired_date AS 

				Date) <= CAST (@CURRENT_DATETIME AS Date)  
				and customer_earned_evouchers.used_status=0         
			  
				Group By customer_id 
			        
			)as expired_eVouchers_temp
			        
			on f.customer_id = expired_eVouchers_temp.customer_id
			where ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0)>=0
			and ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0)>=0
			and ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0)>=0
			order by intRow 
		END
		ELSE 
		BEGIN
			select f.customer_id,f.total_points,f.total_winks,f.total_used_evouchers,
			f.used_points,f.used_winks,f.confiscated_points,
			f.confiscated_winks,f.expired_winks,
			f.first_name,f.last_name ,f.email,f.status,f.ip_address,f.ip_scanned,f.WID,f.[group],
			intRow,total_count,
			ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0) as balanced_evouchers
			,ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0) as balanced_points
			,ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0) as balanced_winks
			,ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
			ISNULL (total_evouchers,0) as Total_eVoucher , 
			ISNULL (No_Of_Scan,0) as No_Of_Scan,
			ISNULL(Total_Winks,0) as Total_Winks,
			ISNULL (confiscated_winks,0) as total_winks_confiscated,
			ISNULL (confiscated_points,0) as total_points_confiscated,
			ISNULL(used_winks,0) as Redeemed_Winks
				
					 
			from
			( 
				select * from
				(
					select c.customer_id,c.total_points,c.total_winks,c.total_used_evouchers,
					c.used_points,c.used_winks,c.confiscated_points,c.total_evouchers,
					c.confiscated_winks,c.expired_winks,
					c.first_name,c.last_name ,c.email,c.status,c.ip_address,c.ip_scanned,c.WID,c.[group],
					ROW_NUMBER() OVER(ORDER BY isnull(No_Of_Scan,0) DESC) as intRow,
					total_count ,
					ISNULL(No_Of_Scan,0) as No_Of_Scan
					from 
					(
						select a.customer_id,a.total_points,a.total_winks,a.total_used_evouchers,
						a.used_points,a.used_winks,a.confiscated_points,a.total_evouchers,
						a.confiscated_winks,a.expired_winks,COUNT(*) OVER() AS total_count,
						b.first_name,b.last_name ,b.email,b.locked_desc as [status],b.ip_address,b.ip_scanned,
						b.WID,b.[group]
						from customer_balance as a
					 
						join
						(
							select customer.*,temp.locked_desc,cusGroup.group_name as [group] 
							from customer  
							join customer_group as cusGroup
							on customer.group_id = cusGroup.group_id
							and (@group_id is null or cusGroup.group_id = @group_id
							or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
							or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
							or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
							inner join #Customer_AutoLog_Table temp
							on customer.customer_id = temp.customer_id
						) as b

						on a.customer_id = b.customer_id
						where a.customer_id != 15
						AND (@wid is null or b.WID like '%'+ @wid+'%')
						AND (@customer_name is null  or Lower(b.first_name +' '+ b.last_name) LIKE Lower( '%'+@customer_name +'%'))      
						AND (@customer_email is null  or Lower(b.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
						AND (@status is null  or Lower(b.[status]) LIKE Lower(@status+'%'))
						and a.customer_id = @customer_id
						and  a.customer_id in (select customer_id from #Customer_AutoLog_Table)
						)
						as c
						left join 
							(
							select count(*) as No_Of_Scan ,customer_id 
					
												from customer_earned_points 
												Group by customer_id
                     							Having COUNT(*)>0
							) as d
							on d.customer_id = c.customer_id
					  
							) as e
							where e.intRow between @intStartRow and @intEndRow
							) as f
							left Join 
							-----------------------------------
						(select COUNT(*) AS 

							Expired_Evoucher,customer_id from customer_earned_evouchers 
							where CAST (customer_earned_evouchers.expired_date AS 

							Date) <= CAST (@CURRENT_DATETIME AS Date)  
							and customer_earned_evouchers.used_status=0         
			  
							Group By customer_id 
			        
						)as expired_eVouchers_temp
			        
						on f.customer_id = expired_eVouchers_temp.customer_id
						where ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0)>=0
						and ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0)>=0
						and ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0)>=0
						order by intRow 
		END
	END
	------------------------- End Customer Filer--------------------------------------
	ELSE
	BEGIN
		--------------------------------IP Is not null ---------------------------------------
		IF(@ip_address is not null and @ip_address !='')
		BEGIN

			select f.customer_id,f.total_points,f.total_winks,f.total_used_evouchers,
			f.used_points,f.used_winks,f.confiscated_points,
			f.confiscated_winks,f.expired_winks,
			f.first_name,f.last_name ,f.email,f.status,f.ip_address,f.ip_scanned,f.WID,f.[group],
			intRow,total_count,
			ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0) as balanced_evouchers
			,ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0) as balanced_points
			,ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0) as balanced_winks
			,ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
			ISNULL (total_evouchers,0) as Total_eVoucher , 
			ISNULL (No_Of_Scan,0) as No_Of_Scan,
			ISNULL(Total_Winks,0) as Total_Winks,
			ISNULL (confiscated_winks,0) as total_winks_confiscated,
			ISNULL (confiscated_points,0) as total_points_confiscated,
			ISNULL(used_winks,0) as Redeemed_Winks
			from
			( 
				select * from
				(
					select c.customer_id,c.total_points,c.total_winks,c.total_used_evouchers,
					c.used_points,c.used_winks,c.confiscated_points,c.total_evouchers,
					c.confiscated_winks,c.expired_winks,
					c.first_name,c.last_name ,c.email,c.status,c.ip_address,c.ip_scanned,c.WID,c.[group],
					ROW_NUMBER() OVER(ORDER BY isnull(No_Of_Scan,0) DESC) as intRow,
					total_count ,
					ISNULL(No_Of_Scan,0) as No_Of_Scan
					from 
					(
						select a.customer_id,a.total_points,a.total_winks,a.total_used_evouchers,
						a.used_points,a.used_winks,a.confiscated_points,a.total_evouchers,
						a.confiscated_winks,a.expired_winks,COUNT(*) OVER() AS total_count,
						b.first_name,b.last_name ,b.email,b.locked_desc as status,b.ip_address,b.ip_scanned,b.WID,b.[group]
						from customer_balance as a
						join
						(
							select customer.*,temp.locked_desc,cusGroup.group_name as [group] 
							from customer 
							join customer_group as cusGroup
							on customer.group_id = cusGroup.group_id
							and (@group_id is null or cusGroup.group_id = @group_id
							or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
							or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
							or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
							inner join #Customer_AutoLog_Table temp
							on customer.customer_id = temp.customer_id
						) as b
						on a.customer_id = b.customer_id
						where a.customer_id != 15
						AND (@wid is null or b.WID like '%'+ @wid+'%')
						AND (@customer_name is null  or Lower(b.first_name +' '+ b.last_name) LIKE Lower( '%'+@customer_name +'%'))      
						AND (@customer_email is null  or Lower(b.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
						AND (@status is null  or Lower(b.[status]) LIKE Lower(@status+'%'))
						AND b.ip_address like '%'+ @ip_address+'%'
						AND (@ip_scanned is null or b.ip_scanned like '%'+ @ip_scanned+'%')
						and  a.customer_id in (select customer_id from #Customer_AutoLog_Table)
					)
					as c
					left join 
					(
						select count(*) as No_Of_Scan ,customer_id
						from customer_earned_points 
						Group by customer_id
                     	Having COUNT(*)>0
					) as d
					on d.customer_id = c.customer_id
				) as e
				where e.intRow between @intStartRow and @intEndRow
			) as f
					left Join 
					-----------------------------------
				(select COUNT(*) AS 

					Expired_Evoucher,customer_id from customer_earned_evouchers 
					where CAST (customer_earned_evouchers.expired_date AS 

					Date) <= CAST (@CURRENT_DATETIME AS Date)  
					and customer_earned_evouchers.used_status=0         
			  
					Group By customer_id 
			        
				)as expired_eVouchers_temp
			        
				on f.customer_id = expired_eVouchers_temp.customer_id
				where ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0)>=0
				and ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0)>=0
				and ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0)>=0
				order by intRow 
			END
		------------------------------ Ip scanned is not null -----------------------
		ELSE IF (@ip_scanned is not null and @ip_scanned !='')
		BEGIN
			select f.customer_id,f.total_points,f.total_winks,f.total_used_evouchers,
			f.used_points,f.used_winks,f.confiscated_points,
			f.confiscated_winks,f.expired_winks,
			f.first_name,f.last_name ,f.email,f.[status],f.ip_address,f.ip_scanned,f.WID,f.[group],
			intRow,total_count,
			ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0) as balanced_evouchers
			,ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0) as balanced_points
			,ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0) as balanced_winks
			,ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
			ISNULL (total_evouchers,0) as Total_eVoucher , 
			ISNULL (No_Of_Scan,0) as No_Of_Scan,
			ISNULL(Total_Winks,0) as Total_Winks,
			ISNULL (confiscated_winks,0) as total_winks_confiscated,
			ISNULL (confiscated_points,0) as total_points_confiscated,
			ISNULL(used_winks,0) as Redeemed_Winks	 
			from
			( 
				select * from
 
				(
					select c.customer_id,c.total_points,c.total_winks,c.total_used_evouchers,
					c.used_points,c.used_winks,c.confiscated_points,c.total_evouchers,
					c.confiscated_winks,c.expired_winks,
					c.first_name,c.last_name ,c.email,c.status,c.ip_address,c.ip_scanned,c.WID,c.[group],
					ROW_NUMBER() OVER(ORDER BY isnull(No_Of_Scan,0) DESC) as intRow,
					total_count ,
					ISNULL(No_Of_Scan,0) as No_Of_Scan  
					from 
						(
							select a.customer_id,a.total_points,a.total_winks,a.total_used_evouchers,
							a.used_points,a.used_winks,a.confiscated_points,a.total_evouchers,
							a.confiscated_winks,a.expired_winks,COUNT(*) OVER() AS total_count,
							b.first_name,b.last_name ,b.email,b.locked_desc as [status],b.ip_address,b.ip_scanned,
							b.WID,b.[group]
							from customer_balance as a
							join
							(
								select customer.*,temp.locked_desc,
								cusGroup.group_name as [group]
								from customer  
								join customer_group as cusGroup
								on customer.group_id = cusGroup.group_id
								and (@group_id is null or cusGroup.group_id = @group_id
								or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
								or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
								or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
								inner join #Customer_AutoLog_Table temp
								on customer.customer_id = temp.customer_id
							) as b

							on a.customer_id = b.customer_id
							where a.customer_id != 15
							AND (@wid is null or b.WID like '%'+ @wid+'%')
							AND (@customer_name is null  or Lower(b.first_name +' '+ b.last_name) LIKE Lower( '%'+@customer_name +'%'))      
							AND (@customer_email is null  or Lower(b.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
							AND (@status is null  or Lower(b.[status]) LIKE Lower(@status+'%'))
							and b.ip_scanned like '%'+ @ip_scanned+'%'
							and  a.customer_id in (select customer_id from #Customer_AutoLog_Table)
					  
							)
							as c
							left join 
							(
							select count(*) as No_Of_Scan ,customer_id 
					
												from customer_earned_points 
												Group by customer_id
                     							Having COUNT(*)>0
							) as d
							on d.customer_id = c.customer_id
					  
							) as e
							where e.intRow between @intStartRow and @intEndRow
							) as f
							left Join 
							-----------------------------------
						(select COUNT(*) AS 

							Expired_Evoucher,customer_id from customer_earned_evouchers 
							where CAST (customer_earned_evouchers.expired_date AS 

							Date) <= CAST (@CURRENT_DATETIME AS Date)  
							and customer_earned_evouchers.used_status=0         
			  
							Group By customer_id 
			        
						)as expired_eVouchers_temp
			        
						on f.customer_id = expired_eVouchers_temp.customer_id
						where ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0)>=0
						and ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0)>=0
						and ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0)>=0
						order by intRow 
		END
		--------------------------Not Filter Anything--------------------------
		ELSE 
		BEGIN
			select f.customer_id,f.total_points,f.total_winks,f.total_used_evouchers,
			f.used_points,f.used_winks,f.confiscated_points,
			f.confiscated_winks,f.expired_winks,
			f.first_name,f.last_name ,f.email,f.[status],f.ip_address,f.ip_scanned,f.WID,f.[group],
			intRow,total_count,
			ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0) as balanced_evouchers
			,ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0) as balanced_points
			,ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0) as balanced_winks
			,ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
			ISNULL (total_evouchers,0) as Total_eVoucher , 
			ISNULL (No_Of_Scan,0) as No_Of_Scan,
			ISNULL(Total_Winks,0) as Total_Winks,
			ISNULL (confiscated_winks,0) as total_winks_confiscated,
			ISNULL (confiscated_points,0) as total_points_confiscated,
			ISNULL(used_winks,0) as Redeemed_Winks
			from
			( 
				select * from
				(
					select c.customer_id,c.total_points,c.total_winks,c.total_used_evouchers,
					c.used_points,c.used_winks,c.confiscated_points,c.total_evouchers,
					c.confiscated_winks,c.expired_winks,
					c.first_name,c.last_name ,c.email,c.status,c.ip_address,c.ip_scanned,c.WID,c.[group],
					ROW_NUMBER() OVER(ORDER BY isnull(No_Of_Scan,0) DESC) as intRow,
					total_count ,
					ISNULL(No_Of_Scan,0) as No_Of_Scan
					from 
					(
						select a.customer_id,a.total_points,a.total_winks,a.total_used_evouchers,
						a.used_points,a.used_winks,a.confiscated_points,a.total_evouchers,
						a.confiscated_winks,a.expired_winks,COUNT(*) OVER() AS total_count,
						b.first_name,b.last_name ,b.email,b.locked_desc as status,b.ip_address,b.ip_scanned
					   ,b.WID,b.[group]
						from customer_balance as a
						join
						(
							select customer.*,temp.locked_desc,cusGroup.group_name as [group] 
							from customer 
							join customer_group as cusGroup
							on customer.group_id = cusGroup.group_id
							and (@group_id is null or cusGroup.group_id = @group_id
							or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
							or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
							or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
							inner join #Customer_AutoLog_Table temp
							on customer.customer_id = temp.customer_id
						) as b

							on a.customer_id = b.customer_id
							where a.customer_id != 15
							AND (@wid is null or b.WID like '%'+ @wid+'%')
							AND (@customer_name is null  or Lower(b.first_name +' '+ b.last_name) LIKE Lower( '%'+@customer_name +'%'))      
							AND (@customer_email is null  or Lower(b.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
							AND (@status is null  or Lower(b.[status]) LIKE Lower(@status+'%'))
							and  a.customer_id in (select customer_id from #Customer_AutoLog_Table)
					   
					  
							)
							as c
							left join 
							(
							select count(*) as No_Of_Scan ,customer_id 
					
												from customer_earned_points 
												Group by customer_id
                     							Having COUNT(*)>0
							) as d
							on d.customer_id = c.customer_id
					  
							) as e
							where e.intRow between @intStartRow and @intEndRow
							) as f
							left Join 
							-----------------------------------
						(select COUNT(*) AS 

							Expired_Evoucher,customer_id from customer_earned_evouchers 
							where CAST (customer_earned_evouchers.expired_date AS 

							Date) <= CAST (@CURRENT_DATETIME AS Date)  
							and customer_earned_evouchers.used_status=0         
			  
							Group By customer_id 
			        
						)as expired_eVouchers_temp
			        
						on f.customer_id = expired_eVouchers_temp.customer_id
						where ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0)>=0
						and ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0)>=0
						and ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0)>=0
						order by intRow 
		END
	END
 END




