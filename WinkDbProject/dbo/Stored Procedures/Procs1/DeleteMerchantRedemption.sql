
CREATE PROCEDURE [dbo].[DeleteMerchantRedemption]
@merchant_id int
AS
BEGIN

	DECLARE @branch_code int
	DECLARE @advertiser_id int

	BEGIN TRY
    BEGIN TRANSACTION 
		
        Delete from merchant_partners where merchant_partners.merchant_id = @merchant_id
			IF @@ROWCOUNT >0
				BEGIN
				BEGIN TRY
			    			
				

				IF ((SELECT COUNT(*) FROM merchant_partners_address WHERE merchant_partners_address.merchant_id = @merchant_id) >0)

					BEGIN

					SET @branch_code = (SELECT Top(1) branch_code FROM merchant_partners_address WHERE merchant_partners_address.merchant_id = @merchant_id)
					SET @advertiser_id = (SELECT merchant_id FROM branch WHERE branch_code = @branch_code)

					UPDATE branch SET branch_status = '0',allowed_device = 'no' where merchant_id = @advertiser_id;
					Delete from merchant_partners_address where merchant_partners_address.merchant_id = @merchant_id;
					
				    END
				     Print ('Commit')
					 COMMIT
					Select '1' as success , 'Successfully deleted' as response_message
				END TRY
				BEGIN CATCH
					IF @@TRANCOUNT > 0
						ROLLBACK
						 Print ('Roll BACK1')
					Select '0' as success , 'Failed to delete' as response_message
					END CATCH
				
				END 
			ELSE 
				BEGIN
				
				Print ('Commit2')
				COMMIT
				
				Select '0' as success , 'Successfully deleted' as response_message
				
				END	
				
		
	END TRY
		BEGIN CATCH
		IF @@TRANCOUNT > 0
        ROLLBACK
         Print ('Roll BACK2')
         Select '0' as success , 'Failed to delete' as response_message
		END CATCH
		
END
