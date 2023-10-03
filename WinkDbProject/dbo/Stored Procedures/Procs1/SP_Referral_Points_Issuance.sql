CREATE PROCEDURE [dbo].[SP_Referral_Points_Issuance]
    @program_id INT,
    @referrer_customer_id INT,
    @referee_customer_id INT,
    @referral_code VARCHAR(50)
AS
BEGIN
    -- Filter the records within the 'referral' table based on the 'reward_type' specifically looking for occurrences of WID.
    -- Then, count these records. Get the values of ‘size’, ‘from_date’ and ‘to_date’ from 'referral_program_config' table based on the ‘reward_type’ -> WID.
    -- If the count is less than the 'size’ and the current date falls within the 'from_date' & 'to_date', issue points to both the referrer and the referee based on the values defined in the 'referral_program_config' table.
    -- If the point issuance process is successful, insert a new record into the 'referral' table to track this referral.
    DECLARE @reward_type VARCHAR(100);
    DECLARE @size_inventory INT;
    DECLARE @from_date DATETIME;
    DECLARE @to_date DATETIME;
    DECLARE @points_for_referrer INT;
    DECLARE @points_for_referee INT;
    DECLARE @current_datetime datetime;
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime OUTPUT;

    SELECT @reward_type = reward_type, @size_inventory = size, @from_date = from_date, @to_date = to_date, 
                          @points_for_referrer = points_for_referrer, @points_for_referee = points_for_referee 
    FROM referral_program_config
    WHERE program_id = @program_id;

    DECLARE @size_redeemed INT = (SELECT COUNT(*) FROM referral WHERE reward_type = @reward_type);
    IF (@size_redeemed < @size_inventory)
    BEGIN
        -- IF both @from_date and @to_date is null or empty, skip checking the datetime condition
        -- IF you set @from_date and @to_date = '', the default value will be "1900-01-01 00:00:00.000" (No worries, this condition will became true)
        IF ((@from_date IS NULL OR @from_date = '') AND (@to_date IS NULL OR @to_date = ''))
        BEGIN
            GOTO START_REFERRAL_POINTS_TRANSACTION;
            RETURN;
        END

        IF (@current_datetime BETWEEN @from_date AND @to_date)
        BEGIN
            GOTO START_REFERRAL_POINTS_TRANSACTION;
            RETURN;
        END
        ELSE
        BEGIN
            -- Current date time is not within the start date and end date time
            SELECT 0 as success, 'The referral code is invalid' as response_message;
            RETURN
        END
    END
    ELSE
    BEGIN
        -- Maximum inventory size reached
        SELECT 0 as success, 'The referral code is invalid' as response_message;
        RETURN
    END

    START_REFERRAL_POINTS_TRANSACTION:
    BEGIN
        BEGIN TRANSACTION; 
        BEGIN TRY
                
            IF EXISTS (SELECT 1 FROM customer_balance WHERE customer_id = @referrer_customer_id)
             BEGIN
                -- Update the referrer customer balance
                UPDATE customer_balance
                SET total_points = (SELECT total_points FROM customer_balance WHERE customer_id = @referrer_customer_id) + @points_for_referrer
                WHERE customer_id = @referrer_customer_id;
            END
            ELSE
            BEGIN
                INSERT INTO customer_balance 
                (customer_id, total_points, used_points, total_winks, used_winks, total_evouchers, total_used_evouchers, confiscated_winks, expired_winks, confiscated_points, ip_scanned, confiscated_winks_year, total_scans, total_redeemed_amt)
                VALUES
                (@referrer_customer_id, @points_for_referrer, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0, 0, 0)
            END

            IF EXISTS (SELECT 1 FROM customer_balance WHERE customer_id = @referee_customer_id)
            BEGIN
                -- Update the referrer customer balance
                UPDATE customer_balance
                SET total_points = (SELECT total_points FROM customer_balance WHERE customer_id = @referee_customer_id) + @points_for_referee
                WHERE customer_id = @referee_customer_id;
            END
            ELSE
            BEGIN
                INSERT INTO customer_balance 
                (customer_id, total_points, used_points, total_winks, used_winks, total_evouchers, total_used_evouchers, confiscated_winks, expired_winks, confiscated_points, ip_scanned, confiscated_winks_year, total_scans, total_redeemed_amt)
                VALUES
                (@referee_customer_id, @points_for_referee, 0, 0, 0, 0, 0, 0, 0, 0, NULL, 0, 0, 0)
            END

            -- Insert into referral table
            INSERT INTO referral
            (referrer_customer_id, referee_customer_id, referrer_earned_points, referee_earned_points, referral_code, reward_type, reward_date)
            VALUES
            (@referrer_customer_id, @referee_customer_id, @points_for_referrer, @points_for_referee, @referral_code, @reward_type, @current_datetime);
            
            -- Commit the transaction if everything is successful
            COMMIT TRANSACTION;
            SELECT 1 as success,'Points have been issued to the referrer and referee' as response_message;
            RETURN 
        END TRY
        BEGIN CATCH
            -- Roll back the transaction in case of an unexpected error
            ROLLBACK TRANSACTION;
            SELECT 0 as success, 'Something went wrong. Please try again later.' as response_message;
        END CATCH
    END
END
