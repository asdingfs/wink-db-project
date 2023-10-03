CREATE PROCEDURE [dbo].[QRNormalisation]
(
	@affectedDate varchar(50),
	@adminEmail varchar(100)
)	
AS
BEGIN
	DECLARE @CURRENT_DATETIME Datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT;
	DECLARE @RETURN_NO VARCHAR(10)
	DECLARE @existDuplicates int = 0
	IF(@adminEmail is null)
	BEGIN
		SELECT 0 as success,'You are not authorised to create the campaign' as response_message
		return
	END

	DECLARE @customerId int, @qrCode varchar(200), @duplicateCount int

	DECLARE DuplicateQRCursor CURSOR FOR 
	select customer_id, qr_code, count(*)-1 as duplicateCount
	from customer_earned_points
	where cast(created_at as date) = cast (@affectedDate as date)
	group by customer_id, qr_code
	having count(*) > 1;

	 
	OPEN DuplicateQRCursor 

	FETCH NEXT FROM DuplicateQRCursor INTO @customerId, @qrCode, @duplicateCount
	print(@@FETCH_STATUS);
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		print('current customer')
		print(@customerId);
		print('QR code');
		print(@qrCode);
		print('Duplicate count');
		print(@duplicateCount);

		DECLARE CustomerDuplicateCursor CURSOR FOR
		SELECT TOP(@duplicateCount) earned_points_id
		FROM customer_earned_points
		WHERE customer_id = @customerId
		AND qr_code like @qrCode
		AND cast(created_at as date) = cast (@affectedDate as date)
		ORDER BY created_at DESC

		DECLARE @earnPointsId int

		OPEN CustomerDuplicateCursor

		FETCH NEXT FROM CustomerDuplicateCursor INTO
		@earnPointsId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			print('deleted earn points ID');
			print(@earnPointsId);

			DELETE FROM customer_earned_points WHERE earned_points_id = @earnPointsId;
			FETCH NEXT FROM CustomerDuplicateCursor INTO
			@earnPointsId
		END
		CLOSE CustomerDuplicateCursor
		DEALLOCATE CustomerDuplicateCursor
		 
		DECLARE @scanValue int;
		SELECT @scanValue = scan_value FROM asset_type_management WHERE qr_code_value like @qrCode;

		print('QR value')
		print(@scanValue)

		DECLARE @normalisedPts int;
		SET @normalisedPts = @scanValue * @duplicateCount;

		print('Normalised points')
		print(@normalisedPts)

		UPDATE customer_balance
		SET total_points = total_points - @normalisedPts, total_scans = total_scans - @duplicateCount
		WHERE customer_id = @customerId;

		INSERT INTO [dbo].[duplicate_qr_normalisation]
           ([customerId]
           ,[qrCode]
           ,[duplicateCount]
           ,[normalisedPoints]
           ,[affectedDate]
           ,[createdOn])
		 VALUES
			(@customerId
			,@qrCode
			,@duplicateCount
			,@normalisedPts
			,@affectedDate
			,@CURRENT_DATETIME);
		
		IF(@existDuplicates = 0)
		BEGIN
			SET @existDuplicates = 1;
		END
		FETCH NEXT FROM DuplicateQRCursor INTO
		@customerId, @qrCode, @duplicateCount
		
	END
	CLOSE DuplicateQRCursor
	DEALLOCATE DuplicateQRCursor

	--Start Create Log 
	Declare @result int
	---Call Push Log Storeprocedure Function 
	EXEC Create_Duplicate_Normalisation_Log
	@adminEmail,@affectedDate,'Duplicate QR Scans', @result output;
			
	IF(@result=1)
	BEGIN
		DECLARE @msg varchar(250) = 'Duplicate QR records have been successfully normalised.';

		IF(@existDuplicates = 0)
		BEGIN
			SET @msg = 'No duplicates found.'
		END
		select '1' as response_code , @msg as response_message;
		return
	END
	ELSE
	BEGIN
		select '0' as response_code , 'Failed to normalise the records.' as response_message;
		return
	END
END