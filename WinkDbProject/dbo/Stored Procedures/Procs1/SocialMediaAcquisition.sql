
CREATE PROCEDURE  [dbo].[SocialMediaAcquisition] 
(
    @customerId int ,
	@winnerEntryId int,
	@points int
)
AS
BEGIN 
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	IF NOT EXISTS (SELECT * from customer_balance WHERE customer_id = @customerId)
	BEGIN
		INSERT INTO customer_balance 
		(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans,total_redeemed_amt)
		VALUES
		(@customerId,@points,0,0,0,0,0,0,0.00);

		IF(@@ROWCOUNT>0)
		BEGIN
			INSERT INTO [dbo].[winners_points]
					([entry_id]
					,[customer_id]
					,[points]
					,[location]
					,[created_at])
				VALUES
					(@winnerEntryId
					,@customerId
					,@points
					,''
					,@current_datetime);
		END
	END
END
