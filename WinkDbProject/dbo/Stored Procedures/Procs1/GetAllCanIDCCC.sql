
CREATE PROCEDURE [dbo].[GetAllCanIDCCC]
AS
BEGIN
		
		BEGIN 

		SELECT (customer.first_name + ' ' + customer.last_name) As name, customer.email, customer.phone_no, can_id, nonstop_card_type.card_type, business_date
		FROM nonstop_net_canid_earned_points 
		join customer
		on nonstop_net_canid_earned_points.customer_id = customer.customer_id
		join nonstop_card_type
		on nonstop_card_type.card_code = nonstop_net_canid_earned_points.card_type
		where nonstop_card_type.card_code = '01'
		OR nonstop_card_type.card_code = '07'
		and SUBSTRING(nonstop_net_canid_earned_points.can_id, 1, 6) = '111179'
		and CAST(nonstop_net_canid_earned_points.created_at As Date) >=  CAST('2018-05-01' As Date)
		and CAST(nonstop_net_canid_earned_points.created_at As Date) <=  CAST('2018-05-31' As Date)


		END
	 
END

