CREATE OR REPLACE PROCEDURE append_sales_us_stage_clone(file_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Load data from the specified file in the stage into sales_us_stage_clone
  EXECUTE IMMEDIATE
  'COPY INTO sales_us_stage_clone ' ||
  'FROM @Sales.public.%sales_us_stage_clone/' || file_name || ' ' ||
  'FILE_FORMAT = (FORMAT_NAME = ''my_parquet_format'') ' ||
  'ON_ERROR = ''CONTINUE'';';

  RETURN 'Data appended to sales_us_stage_clone from ' || file_name || '!';
END;
$$;


CREATE OR REPLACE PROCEDURE upsert_sales_us_clone()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Insert or Update Data from Stage to Clone
  MERGE INTO sales_us_clone t
  USING (
    SELECT
      data:"Order ID"::STRING AS ORDER_ID,
      data:"Customer Name"::STRING AS CUSTOMER_NAME,
      data:"Mobile Model"::STRING AS MOBILE_MODEL,
      data:"Quantity"::INT AS QUANTITY,
      data:"Price per Unit"::INT AS PRICEPERUNIT,
      data:"Total Price"::INT AS TOTALPRICE,
      data:"Promotion Code"::STRING AS PROMOTION_CODE,
      data:"Order Amount"::DECIMAL(10,2) AS ORDER_AMOUNT,
      data:"Tax"::DECIMAL(10,2) AS TAX,
      data:"Order Date"::DATE AS ORDER_DATE,
      data:"Payment Status"::STRING AS PAYMENT_STATUS,
      data:"Shipping Status"::STRING AS SHIPPING_STATUS,
      data:"Payment Method"::STRING AS PAYMENT_METHOD,
      data:"Payment Provider"::STRING AS PAYMENT_PROVIDER,
      data:"Phone"::STRING AS PHONE,
      data:"Delivery Address"::STRING AS DELIVERY_ADDRESS
    FROM sales_us_stage_clone
  ) s
  ON t.ORDER_ID = s.ORDER_ID
  WHEN MATCHED THEN
    UPDATE SET
      t.CUSTOMER_NAME = s.CUSTOMER_NAME,
      t.MOBILE_MODEL = s.MOBILE_MODEL,
      t.QUANTITY = s.QUANTITY,
      t.PRICEPERUNIT = s.PRICEPERUNIT,
      t.TOTALPRICE = s.TOTALPRICE,
      t.PROMOTION_CODE = s.PROMOTION_CODE,
      t.ORDER_AMOUNT = s.ORDER_AMOUNT,
      t.TAX = s.TAX,
      t.ORDER_DATE = s.ORDER_DATE,
      t.PAYMENT_STATUS = s.PAYMENT_STATUS,
      t.SHIPPING_STATUS = s.SHIPPING_STATUS,
      t.PAYMENT_METHOD = s.PAYMENT_METHOD,
      t.PAYMENT_PROVIDER = s.PAYMENT_PROVIDER,
      t.PHONE = s.PHONE,
      t.DELIVERY_ADDRESS = s.DELIVERY_ADDRESS
  WHEN NOT MATCHED THEN
    INSERT (ORDER_ID, CUSTOMER_NAME, MOBILE_MODEL, QUANTITY, PRICEPERUNIT, TOTALPRICE, PROMOTION_CODE, ORDER_AMOUNT, TAX, ORDER_DATE, PAYMENT_STATUS, SHIPPING_STATUS, PAYMENT_METHOD, PAYMENT_PROVIDER, PHONE, DELIVERY_ADDRESS)
    VALUES (s.ORDER_ID, s.CUSTOMER_NAME, s.MOBILE_MODEL, s.QUANTITY, s.PRICEPERUNIT, s.TOTALPRICE, s.PROMOTION_CODE, s.ORDER_AMOUNT, s.TAX, s.ORDER_DATE, s.PAYMENT_STATUS, s.SHIPPING_STATUS, s.PAYMENT_METHOD, s.PAYMENT_PROVIDER, s.PHONE, s.DELIVERY_ADDRESS);

  RETURN 'Data upserted successfully into sales_us_clone!';
END;
$$;

TRUNCATE TABLE sales_us_stage_clone;

CALL append_sales_us_stage_clone('order-20200115.snappy.parquet');

TRUNCATE TABLE sales_us_clone;

CALL upsert_sales_us_clone();