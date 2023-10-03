CREATE PROC GENERATE_VERIFICATION_CODE
(
	@merchant_id int,
	@event_id int
)
AS

DECLARE @EVOUCHER_CODE varchar(10)
DECLARE @returnstatus varchar(10)

BEGIN

	IF EXISTS (SELECT * FROM GAME_EVENT_DATE WHERE EVENT_DATE_ID = @event_id)
	BEGIN
		--check merchant
		IF EXISTS(SELECT * FROM MERCHANT WHERE MERCHANT_ID =@merchant_id)
		BEGIN
			--check branch
			IF EXISTS (SELECT * FROM BRANCH WHERE MERCHANT_ID =@merchant_id)
			BEGIN
				--check event id already exists or not
				IF NOT EXISTS (SELECT * FROM Game_eVoucher_verification WHERE event_id = @event_id)
				BEGIN
					--INSERT INTO Game_eVoucher_verification (evoucher_code,verificaton_code,branch_id,created_at,event_id) SELECT (EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT),(SELECT CONVERT(numeric(9,0),rand() * 899999999) + 100000000), + 100000000,branch_code,getdate(),@event_id) FROM BRANCH WHERE MERCHANT_ID =@merchant_id
					
					INSERT INTO Game_eVoucher_verification (branch_id,created_at,event_id) SELECT branch_code,getdate(),@event_id FROM BRANCH WHERE MERCHANT_ID =@merchant_id
					
					declare @tbl_id int
					declare @verification_code varchar(50)
					declare curr cursor local for select eVoucher_verification_id from Game_eVoucher_verification
					
					OPEN curr
					FETCH NEXT FROM curr INTO @tbl_id

					WHILE (@@FETCH_STATUS = 0)
					BEGIN
						EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
				
						WHILE EXISTS(SELECT * FROM Game_eVoucher_verification WHERE eVoucher_code = @EVOUCHER_CODE)
						BEGIN
							EXEC GET_RANDOM_NO @EVOUCHER_CODE OUTPUT
						END

						SET @verification_code = CONVERT(numeric(9,0),rand() * 899999999) + 100000000
						
						UPDATE Game_eVoucher_verification SET eVoucher_code = @EVOUCHER_CODE, verification_code = @verification_code WHERE eVoucher_verification_id=@tbl_id
						
						FETCH NEXT FROM curr INTO @tbl_id
					END
					close curr
					deallocate curr

					IF(@@ROWCOUNT>0)
					BEGIN
						SELECT '1' AS response_code,'Verification codes are successfully generated' as response_message
						return;
					END
					ELSE
					BEGIN
						SELECT '0' AS response_code,'Insert fails' as response_message
						return;
					END
				END
				ELSE
				BEGIN
					SELECT '0' AS response_code,'Event ID '+ @event_id+' already exists' as response_message
					return;
				END
			END
			ELSE
			BEGIN
				SELECT '0' AS response_code,'There is no branch' as response_message
				return;
			END
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code,'Invalid merchant' as response_message
			RETURN;
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code,'Invalid event id' as response_message
		RETURN;
	END
END