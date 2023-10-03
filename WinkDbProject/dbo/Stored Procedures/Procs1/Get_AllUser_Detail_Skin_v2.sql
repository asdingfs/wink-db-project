
CREATE PROCEDURE [dbo].[Get_AllUser_Detail_Skin_v2]
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
	  @group_id varchar(10)
	  )
AS
BEGIN
-- Filer Phone No.

If (@phone_no is null OR @phone_no ='')
BEGIN
print('dfjdkf')
set @phone_no = NULL

END
 
If (@ip_address is null OR @ip_address ='')
BEGIN
print('aaaa')
set @ip_address = NULL

END
 
If (@customer_id is null OR @customer_id ='')
BEGIN
print('gggg')
set @customer_id = NULL

END



IF OBJECT_ID('tempdb..#tmpCustomerDetail') IS NOT NULL     
	Drop table #tmpCustomerDetail

CREATE TABLE #tmpCustomerDetail    
(     auth_token varchar(150),
	  created_at varchar(50),
	  customer_id int,
	  date_of_birth VARCHAR(100),
      email varchar(150),
      first_name varchar(50),
      last_name varchar(50),
      password varchar(100),
      gender varchar(10),
      status varchar(20),
	  group_id varchar(10),
	  phone_no varchar(10),
	  subscribe_status varchar(10),	  
	  ip_address varchar(100),
	  CANID1 VARCHAR(100),
	  CANID2 VARCHAR(100),
	  CANID3 VARCHAR(100)
)  

/*
--INSERT DATA INTO TEMP CAN ID TABLE
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
INSERT INTO #tmpCANID 
SELECT * FROM
(
SELECT CUSTOMER_ID
       ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID
FROM CAN_ID
) AS T
PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) AS T2

--SELECT * FROM #tmpCANID 
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*/	  

	-- Filter Created At
	
	If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='')
	BEGIN
		
			Select customer.auth_token,customer.created_at,
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
			
			UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
		    CANID.CANID1,
		    CANID.CANID2,
		    CANID.CANID3

			from customer
			join wink_team
			on customer.team_id = wink_team.team_id
			join avatar
			on customer.avatar_id = avatar.id
			join 
			(
			  SELECT * FROM
				(
					SELECT can_id.customer_id  ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID
					FROM CAN_ID 
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) as T2
			
			) As CANID
			on customer.customer_id = CANID.customer_id
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
			
			order by customer.customer_id DESC
	END
		
	ELSE	
	BEGIN
	
			Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
			customer.status,customer.group_id,
			customer.phone_no,
			customer.subscribe_status,
		    customer.nick_name,
		    UPPER(LEFT(customer.skin_name,1))+LOWER(SUBSTRING(customer.skin_name,2,LEN(skin_name))) as skin_name,
			--customer.skin_name,
			wink_team.team_name,
			avatar.avatar_name,
			customer.ip_address,
			--(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id order by customer_action_log.created_at desc) as ip_address,
			CANID.CANID1,
		    CANID.CANID2,
		    CANID.CANID3
			
			from customer
			join wink_team
			on customer.team_id = wink_team.team_id
			join avatar
			on customer.avatar_id = avatar.id
			join 
			(
			  SELECT * FROM
				(
					SELECT can_id.customer_id  ,('CANID' + CAST(ROW_NUMBER() OVER(PARTITION BY can_id.CUSTOMER_ID ORDER BY CUSTOMER_CANID) AS VARCHAR(50))) AS CAN_ID_NAME,CUSTOMER_CANID
					FROM CAN_ID 
				) AS T
				PIVOT (MAX(CUSTOMER_CANID) FOR CAN_ID_NAME IN (CANID1, CANID2, CANID3)) as T2
			
			) As CANID
			on customer.customer_id = CANID.customer_id
			where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE @email+'%' 
			and customer.status Like @status+'%'
			and subscribe_status Like @subscribe_status+'%'
			and customer.skin_name like @skin+'%'
			and wink_team.team_name like @team+'%'
			and avatar.avatar_name like @avartar +'%'
			and (@phone_no is null OR customer.phone_no like @phone_no + '%')
			and (@customer_id is null OR customer.customer_id = @customer_id)
			and (@ip_address is null OR customer.ip_address = @ip_address)
			order by customer.customer_id DESC
	END
	
	

END




