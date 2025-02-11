CREATE OR REPLACE PROCEDURE consolidate_sales_clone()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Step 1: Insert or update data from sales_in_clone table
  MERGE INTO consolidated_sales_clone t
  USING (
    SELECT 
      s.Order_ID,
      s.Customer_Name,
      s.Mobile_Model,
      s.Quantity,
      (s.PricePerUnit / e.usd2inr) AS PricePerUnit_usd,
      (s.TotalPrice / e.usd2inr) AS TotalPrice_usd,
      s.Promotion_Code,
      (s.Order_Amount / e.usd2inr) AS Order_Amount_usd,
      (s.GST / e.usd2inr) AS GST_usd,
      s.order_date,
      s.payment_status,
      s.shipping_status,
      s.payment_method,
      s.payment_provider,
      s.Mobile,
      s.Delivery_Address,
      'India' AS Country,
      'Asia' AS Region
    FROM sales_in_clone s
    JOIN exchange_rate e ON s.order_date = e.exchange_rate_dt
    WHERE NOT EXISTS (
      SELECT 1 FROM consolidated_sales_clone cs WHERE cs.Order_ID = s.Order_ID
    )
  ) s
  ON t.Order_ID = s.Order_ID
  WHEN MATCHED THEN
    UPDATE SET
      t.Customer_Name = s.Customer_Name,
      t.Mobile_Model = s.Mobile_Model,
      t.Quantity = s.Quantity,
      t.PricePerUnit_usd = s.PricePerUnit_usd,
      t.TotalPrice_usd = s.TotalPrice_usd,
      t.Promotion_Code = s.Promotion_Code,
      t.Order_Amount_usd = s.Order_Amount_usd,
      t.GST_usd = s.GST_usd,
      t.order_date = s.order_date,
      t.payment_status = s.payment_status,
      t.shipping_status = s.shipping_status,
      t.payment_method = s.payment_method,
      t.payment_provider = s.payment_provider,
      t.Mobile = s.Mobile,
      t.Delivery_Address = s.Delivery_Address,
      t.Country = s.Country,
      t.Region = s.Region
  WHEN NOT MATCHED THEN
    INSERT (
      Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit_usd, TotalPrice_usd, 
      Promotion_Code, Order_Amount_usd, GST_usd, order_date, payment_status, 
      shipping_status, payment_method, payment_provider, Mobile, Delivery_Address, 
      Country, Region
    )
    VALUES (
      s.Order_ID, s.Customer_Name, s.Mobile_Model, s.Quantity, s.PricePerUnit_usd, 
      s.TotalPrice_usd, s.Promotion_Code, s.Order_Amount_usd, s.GST_usd, 
      s.order_date, s.payment_status, s.shipping_status, s.payment_method, 
      s.payment_provider, s.Mobile, s.Delivery_Address, s.Country, s.Region
    );

  -- Step 2: Insert or update data from sales_fr_clone table
  MERGE INTO consolidated_sales_clone t
  USING (
    SELECT 
      s.Order_ID,
      s.Customer_Name,
      s.Mobile_Model,
      s.Quantity,
      (s.PricePerUnit / e.usd2eu) AS PricePerUnit_usd,
      (s.TotalPrice / e.usd2eu) AS TotalPrice_usd,
      s.Promotion_Code,
      (s.Order_Amount / e.usd2eu) AS Order_Amount_usd,
      (s.GST / e.usd2eu) AS GST_usd,
      s.order_date,
      s.payment_status,
      s.shipping_status,
      s.payment_method,
      s.payment_provider,
      s.Phone AS Mobile,
      s.Delivery_Address,
      'France' AS Country,
      'Europe' AS Region
    FROM sales_fr_clone s
    JOIN exchange_rate e ON s.order_date = e.exchange_rate_dt
    WHERE NOT EXISTS (
      SELECT 1 FROM consolidated_sales_clone cs WHERE cs.Order_ID = s.Order_ID
    )
  ) s
  ON t.Order_ID = s.Order_ID
  WHEN MATCHED THEN
    UPDATE SET
      t.Customer_Name = s.Customer_Name,
      t.Mobile_Model = s.Mobile_Model,
      t.Quantity = s.Quantity,
      t.PricePerUnit_usd = s.PricePerUnit_usd,
      t.TotalPrice_usd = s.TotalPrice_usd,
      t.Promotion_Code = s.Promotion_Code,
      t.Order_Amount_usd = s.Order_Amount_usd,
      t.GST_usd = s.GST_usd,
      t.order_date = s.order_date,
      t.payment_status = s.payment_status,
      t.shipping_status = s.shipping_status,
      t.payment_method = s.payment_method,
      t.payment_provider = s.payment_provider,
      t.Mobile = s.Mobile,
      t.Delivery_Address = s.Delivery_Address,
      t.Country = s.Country,
      t.Region = s.Region
  WHEN NOT MATCHED THEN
    INSERT (
      Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit_usd, TotalPrice_usd, 
      Promotion_Code, Order_Amount_usd, GST_usd, order_date, payment_status, 
      shipping_status, payment_method, payment_provider, Mobile, Delivery_Address, 
      Country, Region
    )
    VALUES (
      s.Order_ID, s.Customer_Name, s.Mobile_Model, s.Quantity, s.PricePerUnit_usd, 
      s.TotalPrice_usd, s.Promotion_Code, s.Order_Amount_usd, s.GST_usd, 
      s.order_date, s.payment_status, s.shipping_status, s.payment_method, 
      s.payment_provider, s.Mobile, s.Delivery_Address, s.Country, s.Region
    );

  -- Step 3: Insert or update data from sales_us_clone table
  MERGE INTO consolidated_sales_clone t
  USING (
    SELECT 
      s.Order_ID,
      s.Customer_Name,
      s.Mobile_Model,
      s.Quantity,
      s.PricePerUnit AS PricePerUnit_usd,
      s.TotalPrice AS TotalPrice_usd,
      s.Promotion_Code,
      s.Order_Amount AS Order_Amount_usd,
      s.Tax AS GST_usd,
      s.Order_Date AS order_date,
      s.Payment_Status AS payment_status,
      s.Shipping_Status AS shipping_status,
      s.Payment_Method AS payment_method,
      s.Payment_Provider AS payment_provider,
      s.Phone AS Mobile,
      s.Delivery_Address,
      'USA' AS Country,
      'North America' AS Region
    FROM sales_us_clone s
    WHERE NOT EXISTS (
      SELECT 1 FROM consolidated_sales_clone cs WHERE cs.Order_ID = s.Order_ID
    )
  ) s
  ON t.Order_ID = s.Order_ID
  WHEN MATCHED THEN
    UPDATE SET
      t.Customer_Name = s.Customer_Name,
      t.Mobile_Model = s.Mobile_Model,
      t.Quantity = s.Quantity,
      t.PricePerUnit_usd = s.PricePerUnit_usd,
      t.TotalPrice_usd = s.TotalPrice_usd,
      t.Promotion_Code = s.Promotion_Code,
      t.Order_Amount_usd = s.Order_Amount_usd,
      t.GST_usd = s.GST_usd,
      t.order_date = s.order_date,
      t.payment_status = s.payment_status,
      t.shipping_status = s.shipping_status,
      t.payment_method = s.payment_method,
      t.payment_provider = s.payment_provider,
      t.Mobile = s.Mobile,
      t.Delivery_Address = s.Delivery_Address,
      t.Country = s.Country,
      t.Region = s.Region
  WHEN NOT MATCHED THEN
    INSERT (
      Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit_usd, TotalPrice_usd, 
      Promotion_Code, Order_Amount_usd, GST_usd, order_date, payment_status, 
      shipping_status, payment_method, payment_provider, Mobile, Delivery_Address, 
      Country, Region
    )
    VALUES (
      s.Order_ID, s.Customer_Name, s.Mobile_Model, s.Quantity, s.PricePerUnit_usd, 
      s.TotalPrice_usd, s.Promotion_Code, s.Order_Amount_usd, s.GST_usd, 
      s.order_date, s.payment_status, s.shipping_status, s.payment_method, 
      s.payment_provider, s.Mobile, s.Delivery_Address, s.Country, s.Region
    );

  RETURN 'Sales data consolidated successfully!';
END;
$$;

CALL consolidate_sales_clone();