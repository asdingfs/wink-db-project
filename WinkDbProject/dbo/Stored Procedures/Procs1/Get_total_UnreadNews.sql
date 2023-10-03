CREATE PROCEDURE [dbo].[Get_total_UnreadNews]
	(
	 @token_id varchar(100),
	 @total int output
	 )
AS
BEGIN
   Declare @customer_id int
   Declare @latest_news_id int
   set @total =0
   
   select @customer_id = customer_id from customer
   where customer.auth_token = @token_id
   
   select @latest_news_id = MAX(news_id) from customer_read_news where customer_id = @customer_id
   IF (@customer_id is not null or @customer_id !='')
   Begin
   IF EXISTS (select 1 from customer_read_news where customer_id =@customer_id)
   BEGIN
   
   set @total= ( select COUNT(*) as total from wink_news where id>@latest_news_id and wink_news.news_status=1)
   
   END
   ELSE
   BEGIN
    set @total=(select COUNT(*) as total from wink_news)
   
   END
   END
    
    
    
END







