
CREATE PROCEDURE [dbo].[Get_Points_Winks_Confiscation_Report]
(
	@customer_id int,
	@customer_email varchar(150),
	@from_date datetime,
	@to_date datetime,
	@confiscation_type varchar(100),
	@customer_name varchar(100),
	@wid varchar(50),
	@status varchar(50)
)
AS
BEGIN

		IF(@customer_id is null or @customer_id ='')
		set @customer_id = NULL

		IF(@customer_email is null or @customer_email ='')
		set @customer_email = NULL

		IF(@from_date is null or @from_date ='')
		set @from_date = NULL

		IF(@to_date is null or @to_date ='')
		set @to_date = NULL

		IF(@confiscation_type is null or @confiscation_type ='')
		set @confiscation_type = NULL

		IF(@customer_name is null or @customer_name ='')
		SET @customer_name = null

		IF(@wid is null or @wid ='')
		BEGIN
			SET @wid = null
		END
		IF(@status is null or @status='')
		BEGIN
			SET @status = NULL
		END

		select p.account_filtering_id,p.confiscated_points,p.confiscated_winks,
		p.created_at,p.customer_id,p.total_points,p.total_winks, c.WID,
		c.email,c.first_name,c.last_name,c.[status],n.filtering_status_name as confiscation_type
		
		 from points_and_winks_confiscation_detail as p join customer as c
		 on p.customer_id = c.customer_id
		 join wink_account_filtering_status_new as n
		 on n.filtering_status_key = p.confiscation_type
		and (@customer_email IS NULL OR c.email like @customer_email +'%')
		and (@wid IS NULL OR c.WID like '%'+@wid +'%')
		and  (@confiscation_type IS NULL OR confiscation_type = @confiscation_type)

		AND (@from_date IS NULL OR CAST(p.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		and (@customer_id  is NULL OR c.customer_id = @customer_id)
		and (@customer_name  is NULL OR (c.first_name like @customer_name +'%' OR c.last_name like @customer_name +'%'))
		AND (@status is null or c.[status] = @status)
		order by created_at desc
END




