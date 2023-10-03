CREATE PROCEDURE [dbo].[Get_WinkNewsList_By_Auth_testing]
	(
	 @token_id varchar(100),
	 @status varchar (10)
	 
	 )
AS
BEGIN
    Declare @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output

    Declare @customer_id int
  
    IF (@token_id !='' and @token_id IS NOT NULL)
    BEGIN
		set @customer_id = (select customer_id from customer where auth_token = @token_id);

   		SELECT MIN(w.id) as id, w.news_status as news_status, w.created_at as created_at, w.updated_at as updated_at,w.title as title ,w.news as news, 
		MAX(CASE r.customer_id
			WHEN @customer_id THEN '1' 
			ELSE '0'
			END) as readingStatus
		FROM wink_news as w
		LEFT OUTER JOIN customer_read_news as r ON w.id = r.news_id
	
		where w.id not in 
		(select news_id from customer_delete_news
		where customer_id = @customer_id)
		AND w.news_status =@status 
		group by w.title, w.news, w.created_at, w.updated_at,w.news_status
		order by w.created_at desc

    END
	
END



