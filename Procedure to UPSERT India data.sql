CREATE OR REPLACE PROCEDURE load_and_upsert_sales_in_clone(file_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Load data directly into the sales_in_clone table, specifying columns
  EXECUTE IMMEDIATE
  'COPY INTO sales_in_clone (Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit, TotalPrice, Promotion_Code, Order_Amount, GST, order_date, payment_status, shipping_status, payment_method, payment_provider, Mobile, Delivery_Address) ' ||
  'FROM @Sales.public.%sales_in_clone/' || file_name || ' ' ||
  'FILE_FORMAT = (FORMAT_NAME = ''my_csv_format'') ' ||
  'ON_ERROR = ''CONTINUE'';';

  -- Perform the upsert operation
  MERGE INTO sales_in_clone t
  USING (
    SELECT *
    FROM sales_in_clone
  ) s
  ON t.Order_ID = s.Order_ID
  WHEN MATCHED THEN
    UPDATE SET
      t.Customer_Name = s.Customer_Name,
      t.Mobile_Model = s.Mobile_Model,
      t.Quantity = s.Quantity,
      t.PricePerUnit = s.PricePerUnit,
      t.TotalPrice = s.TotalPrice,
      t.Promotion_Code = s.Promotion_Code,
      t.Order_Amount = s.Order_Amount,
      t.GST = s.GST,
      t.order_date = s.order_date,
      t.payment_status = s.payment_status,
      t.shipping_status = s.shipping_status,
      t.payment_method = s.payment_method,
      t.payment_provider = s.payment_provider,
      t.Mobile = s.Mobile,
      t.Delivery_Address = s.Delivery_Address
  WHEN NOT MATCHED THEN
    INSERT (Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit, TotalPrice, Promotion_Code, Order_Amount, GST, order_date, payment_status, shipping_status, payment_method, payment_provider, Mobile, Delivery_Address, Country, Region)
    VALUES (s.Order_ID, s.Customer_Name, s.Mobile_Model, s.Quantity, s.PricePerUnit, s.TotalPrice, s.Promotion_Code, s.Order_Amount, s.GST, s.order_date, s.payment_status, s.shipping_status, s.payment_method, s.payment_provider, s.Mobile, s.Delivery_Address, 'India', 'Asia');

  RETURN 'Data loaded from ' || file_name || ' and upserted into sales_in_clone successfully!';
END;
$$;

TRUNCATE TABLE SALES_IN_CLONE;

CALL load_and_upsert_sales_in_clone('order-20200115.csv.gz');