

CREATE PROCEDURE [dbo].[Append_NETs_CANID_Redemption_Record_Detail]
	( @can_id varchar (20),
	  @business_date datetime,
	  @amount decimal(10,2),
	  @file_name varchar(20),
	  @reason varchar (100)
	 
	 )
	  
AS
BEGIN
INSERT INTO [dbo].[NETs_Appended_CANID_Redemption_Detail]
           ([can_id]
           ,[customer_id]
           ,[evoucher_id]
           ,[evoucher_amount]
           ,[created_at]
           ,[updated_at]
           ,[redemption_date]
           ,[error_date]
           ,[file_name]
           ,[reason])
     
          select top 1 [can_id]
           ,[customer_id]
           ,[evoucher_id]
           ,[evoucher_amount]
           ,Getdate()
           ,Getdate()
           ,[redemption_date]
           ,Getdate()
           ,@file_name
		   ,@reason

		   from NETs_CANID_Redemption_Record_Detail
		   where can_id = @can_id and evoucher_amount =@amount and 
		   cast(created_at as date) = cast (@business_date as date)



END



