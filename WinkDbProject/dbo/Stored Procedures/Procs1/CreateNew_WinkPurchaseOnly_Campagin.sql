CREATE PROCEDURE  [dbo].[CreateNew_WinkPurchaseOnly_Campagin] 
(
@campaign_id int out,
@merchant_id int,
@campaign_name varchar(255),
@campaign_code varchar(255),
@campaign_amount Decimal(10,2),
@cents_per_wink Decimal(10,2),
@percent_for_wink Decimal(10,2),
@sales_code varchar(255),
@sales_commission Decimal(10,2),
@total_winks int,
@total_winks_amount Decimal(10,2),
@agency bit,
@agency_name varchar(255),
@campaign_start_date DateTime,
@campaign_end_date DateTime,
@wink_purchase_only int ,
@wink_purchase_status varchar(50),
@created_at DateTime,
@updated_at DateTime
)
AS
BEGIN 
DECLARE @maxID int

DECLARE @agency_comm decimal(10,2)
--DECLARE @sales_comm decimal(10,2)
DECLARE @7di_comm decimal(10,2)
SET @agency_comm =0
SET @sales_commission =0
IF @agency = 1
	BEGIN
Set @agency_comm = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = 'agency_com'),0)
	END
IF @sales_code !='' AND @sales_code IS NOT NULL
	BEGIN
Set @sales_commission = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = 'sales_com'),0)
	END

Set @7di_comm = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = '7di'),0)

INSERT INTO campaign
           ([merchant_id]
           ,[campaign_name]
           ,[campaign_code]
           ,[campaign_amount]
           ,[cents_per_wink]
           ,[percent_for_wink]
           ,[sales_code]
           ,[sales_commission]
           ,[agency_comm]
           ,[revenue_share]
           ,[total_winks]
           ,[total_winks_amount]
           ,[agency]
           ,[agency_name]
           ,[campaign_start_date]
           ,[campaign_end_date]
           ,[wink_purchase_only]
           ,[wink_purchase_status]
           ,[created_at]
           ,[updated_at])
     VALUES
           (@merchant_id
           ,@campaign_name
           ,@campaign_code
           ,@campaign_amount
           ,@cents_per_wink
           ,@percent_for_wink
           ,@sales_code
           ,@sales_commission
           ,@agency_comm
           ,@7di_comm
           ,@total_winks
           ,@total_winks_amount
           ,@agency
           ,@agency_name
           ,@campaign_start_date
           ,@campaign_end_date
           ,@wink_purchase_only
           ,@wink_purchase_status
           ,@created_at
           ,@updated_at);
          SET @maxID = (SELECT @@IDENTITY);
     
     IF (@maxID > 0)
     BEGIN
      SET @campaign_id  =  (SELECT SCOPE_IDENTITY());
         END   
     
 
END
