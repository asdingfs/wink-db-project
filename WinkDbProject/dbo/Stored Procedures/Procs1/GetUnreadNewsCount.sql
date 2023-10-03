CREATE PROCEDURE [dbo].[GetUnreadNewsCount]
(
	@token_id varchar(100)
)
AS
BEGIN
    Declare @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output

    Declare @customer_id int
  
    IF (@token_id !='' and @token_id IS NOT NULL)
    BEGIN
		SET @customer_id = (SELECT customer_id FROM customer WHERE auth_token = @token_id);

   		SELECT COUNT(*) as newsCount
		FROM wink_news as w
		WHERE w.id not in 
		(
			SELECT * FROM (
				SELECT news_id 
				FROM customer_delete_news
				WHERE customer_id = @customer_id
				UNION 
				SELECT news_id
				FROM customer_read_news
				WHERE customer_id = @customer_id
			) as T
		)
		AND w.news_status ='1' 
		AND (DATEDIFF(day,w.created_at,@current_datetime) < 31)

    END
	
END
