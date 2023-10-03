CREATE Procedure [dbo].[Get_NETsCANIDRemptionList_By_TokenId]
(
  @customer_token_id varchar(100)
)
As 
Begin
Declare @customer_id int
select @customer_id = customer_id from customer where customer.auth_token = @customer_token_id and status ='enable'

Declare @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT     
 
IF (@customer_id is not null and @customer_id !=0)
BEGIN

select * from NETs_CANID_Redemption_Record_Detail 
where customer_id =@customer_id 
and ( (CAST ( DATEADD(DAY,10,cronjob_success_date) as date) >= CAST ( @current_date as date))
OR cronjob_status ='Pending' OR cronjob_status ='sent')
order by updated_at desc

END
End