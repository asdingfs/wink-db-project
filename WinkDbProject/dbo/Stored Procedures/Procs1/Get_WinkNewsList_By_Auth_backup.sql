CREATE PROCEDURE [dbo].[Get_WinkNewsList_By_Auth_backup]
	(
	 @token_id varchar(100),
	 @status varchar (10)
	 
	 )
AS
BEGIN
    Declare @current_datetime datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime Output
    Declare @email varchar(100)
    Declare @customer_id int
    Declare @news_id int
  
    IF (@token_id !='' and @token_id IS NOT NULL)
    BEGIN
    set @customer_id = (select customer_id from customer where auth_token = @token_id)
    select * from wink_news where news_status =@status and id not in (select news_id from customer_delete_news
    where customer_id = @customer_id)
	order by wink_news.created_at desc
    
      
    
    END
	
END



