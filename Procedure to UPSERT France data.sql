CREATE OR REPLACE PROCEDURE append_sales_fr_stage_clone(file_name STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Load data from the specified file in the stage into sales_fr_stage_clone
  EXECUTE IMMEDIATE
  'COPY INTO sales_fr_stage_clone ' ||
  'FROM @Sales.public.%sales_fr_stage_clone/' || file_name || ' ' ||
  'FILE_FORMAT = (FORMAT_NAME = ''my_json_format'') ' ||
  'ON_ERROR = ''CONTINUE'';';

  RETURN 'Data appended to sales_fr_stage_clone from ' || file_name || '!';
END;
$$;


CREATE OR REPLACE PROCEDURE upsert_sales_fr_clone()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Insert or Update Data from Stage to Clone
  MERGE INTO sales_fr_clone t
  USING (
    SELECT
      value:"Order ID"::STRING AS ORDER_ID,
      value:"Customer Name"::STRING AS CUSTOMER_NAME,
      value:"Mobile Model"::STRING AS MOBILE_MODEL,
      value:"Quantity"::INT AS QUANTITY,
      value:"Price per Unit"::INT AS PRICEPERUNIT,
      value:"Total Price"::INT AS TOTALPRICE,
      value:"Promotion Code"::STRING AS PROMOTION_CODE,
      value:"Order Amount"::DECIMAL(10,2) AS ORDER_AMOUNT,
      value:"Tax"::DECIMAL(10,2) AS GST,
      value:"Order Date"::DATE AS ORDER_DATE,
      value:"Payment Status"::STRING AS PAYMENT_STATUS,
      value:"Shipping Status"::STRING AS SHIPPING_STATUS,
      value:"Payment Method"::STRING AS PAYMENT_METHOD,
      value:"Payment Provider"::STRING AS PAYMENT_PROVIDER,
      value:"Phone"::STRING AS PHONE,
      value:"Delivery Address"::STRING AS DELIVERY_ADDRESS
    FROM sales_fr_stage_clone, LATERAL FLATTEN(input => sales_fr_stage_clone.data)
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
      t.GST = s.GST,
      t.ORDER_DATE = s.ORDER_DATE,
      t.PAYMENT_STATUS = s.PAYMENT_STATUS,
      t.SHIPPING_STATUS = s.SHIPPING_STATUS,
      t.PAYMENT_METHOD = s.PAYMENT_METHOD,
      t.PAYMENT_PROVIDER = s.PAYMENT_PROVIDER,
      t.PHONE = s.PHONE,
      t.DELIVERY_ADDRESS = s.DELIVERY_ADDRESS
  WHEN NOT MATCHED THEN
    INSERT (ORDER_ID, CUSTOMER_NAME, MOBILE_MODEL, QUANTITY, PRICEPERUNIT, TOTALPRICE, PROMOTION_CODE, ORDER_AMOUNT, GST, ORDER_DATE, PAYMENT_STATUS, SHIPPING_STATUS, PAYMENT_METHOD, PAYMENT_PROVIDER, PHONE, DELIVERY_ADDRESS)
    VALUES (s.ORDER_ID, s.CUSTOMER_NAME, s.MOBILE_MODEL, s.QUANTITY, s.PRICEPERUNIT, s.TOTALPRICE, s.PROMOTION_CODE, s.ORDER_AMOUNT, s.GST, s.ORDER_DATE, s.PAYMENT_STATUS, s.SHIPPING_STATUS, s.PAYMENT_METHOD, s.PAYMENT_PROVIDER, s.PHONE, s.DELIVERY_ADDRESS);

  RETURN 'Data upserted successfully into sales_fr_clone!';
END;
$$;

TRUNCATE TABLE sales_fr_stage_clone;

CALL append_sales_fr_stage_clone('order-20200115.json');

TRUNCATE TABLE sales_fr_clone;

CALL upsert_sales_fr_clone();