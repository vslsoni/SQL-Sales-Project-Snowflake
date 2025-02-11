CREATE OR REPLACE PROCEDURE update_fact_and_dim_tables_clone()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Step 1: Insert new data into CUSTOMER_DIM_CLONE
  INSERT INTO CUSTOMER_DIM_CLONE (CUSTOMER_NAME, CONTACT_NO, SHIPPING_ADDRESS)
  SELECT DISTINCT 
    cs.Customer_Name,
    cs.Mobile,
    cs.Delivery_Address
  FROM consolidated_sales_clone cs
  LEFT JOIN CUSTOMER_DIM_CLONE cd ON cs.Customer_Name = cd.CUSTOMER_NAME AND cs.Mobile = cd.CONTACT_NO
  WHERE cd.CUSTOMER_NAME IS NULL;

  -- Step 2: Insert new data into DATE_DIM_CLONE
  INSERT INTO DATE_DIM_CLONE (ORDER_DT, ORDER_YEAR, ORDER_MONTH, ORDER_DAY, ORDER_QUARTER, ORDER_DAYOFWEEK, ORDER_DAYNAME, ORDER_DAYOFMONTH)
  SELECT DISTINCT 
    cs.order_date,
    YEAR(cs.order_date) AS ORDER_YEAR,
    MONTH(cs.order_date) AS ORDER_MONTH,
    DAY(cs.order_date) AS ORDER_DAY,
    QUARTER(cs.order_date) AS ORDER_QUARTER,
    DAYOFWEEK(cs.order_date) AS ORDER_DAYOFWEEK,
    DAYNAME(cs.order_date) AS ORDER_DAYNAME,
    DAYOFMONTH(cs.order_date) AS ORDER_DAYOFMONTH
  FROM consolidated_sales_clone cs
  LEFT JOIN DATE_DIM_CLONE dd ON cs.order_date = dd.ORDER_DT
  WHERE dd.ORDER_DT IS NULL;

  -- Step 3: Insert new data into PAYMENT_DIM_CLONE
  INSERT INTO PAYMENT_DIM_CLONE (PAYMENT_METHOD, PAYMENT_PROVIDER)
  SELECT DISTINCT 
    cs.payment_method,
    cs.payment_provider
  FROM consolidated_sales_clone cs
  LEFT JOIN PAYMENT_DIM_CLONE pd ON cs.payment_method = pd.PAYMENT_METHOD AND cs.payment_provider = pd.PAYMENT_PROVIDER
  WHERE pd.PAYMENT_METHOD IS NULL;

  -- Step 4: Insert new data into PRODUCT_DIM_CLONE
  INSERT INTO PRODUCT_DIM_CLONE (MOBILE_MODEL, BRAND, MODEL_NAME, COLOR, RAM, MEMORY_STORAGE)
  SELECT DISTINCT 
    cs.Mobile_Model,
    SPLIT_PART(cs.Mobile_Model, '/', 1) AS BRAND,
    SPLIT_PART(cs.Mobile_Model, '/', 2) AS MODEL_NAME,
    SPLIT_PART(cs.Mobile_Model, '/', 3) AS COLOR,
    SPLIT_PART(cs.Mobile_Model, '/', 4) AS RAM,
    SPLIT_PART(cs.Mobile_Model, '/', 5) AS MEMORY_STORAGE
  FROM consolidated_sales_clone cs
  LEFT JOIN PRODUCT_DIM_CLONE pd ON cs.Mobile_Model = pd.MOBILE_MODEL
  WHERE pd.MOBILE_MODEL IS NULL;

  -- Step 5: Insert new data into PROMO_CODE_DIM_CLONE
  INSERT INTO PROMO_CODE_DIM_CLONE (PROMOTION_CODE)
  SELECT DISTINCT 
    cs.Promotion_Code
  FROM consolidated_sales_clone cs
  LEFT JOIN PROMO_CODE_DIM_CLONE pcd ON cs.Promotion_Code = pcd.PROMOTION_CODE
  WHERE pcd.PROMOTION_CODE IS NULL;

  -- Step 6: Insert new data into REGION_DIM_CLONE
  INSERT INTO REGION_DIM_CLONE (COUNTRY, REGION)
  SELECT DISTINCT 
    cs.Country,
    cs.Region
  FROM consolidated_sales_clone cs
  LEFT JOIN REGION_DIM_CLONE rd ON cs.Country = rd.COUNTRY AND cs.Region = rd.REGION
  WHERE rd.COUNTRY IS NULL;

  -- Step 7: Insert new data into SALES_FACT_CLONE
  INSERT INTO SALES_FACT_CLONE (
    ORDER_CODE, DATE_ID, REGION_ID, CUSTOMER_ID, PRODUCT_ID, PAYMENT_ID, PROMO_CODE_ID, 
    ORDER_QUANTITY, TOTAL_ORDER_AMT, TAX_AMT
  )
  SELECT 
    cs.Order_ID AS ORDER_CODE,
    d.DATE_ID,
    r.REGION_ID,
    c.CUSTOMER_ID,
    p.PRODUCT_ID,
    pay.PAYMENT_ID,
    pc.PROMO_CODE_ID,
    cs.Quantity,
    cs.TotalPrice_usd,
    cs.GST_usd
  FROM 
    consolidated_sales_clone cs
  JOIN 
    DATE_DIM_CLONE d ON cs.order_date = d.ORDER_DT
  JOIN 
    CUSTOMER_DIM_CLONE c ON cs.Customer_Name = c.CUSTOMER_NAME AND cs.Mobile = c.CONTACT_NO
  JOIN 
    REGION_DIM_CLONE r ON cs.country = r.COUNTRY AND cs.region = r.REGION
  JOIN 
    PRODUCT_DIM_CLONE p ON cs.Mobile_Model = p.MOBILE_MODEL
  JOIN 
    PAYMENT_DIM_CLONE pay ON cs.payment_method = pay.PAYMENT_METHOD AND cs.payment_provider = pay.PAYMENT_PROVIDER
  JOIN 
    PROMO_CODE_DIM_CLONE pc ON cs.Promotion_Code = pc.PROMOTION_CODE
  LEFT JOIN 
    SALES_FACT_CLONE sf ON cs.Order_ID = sf.ORDER_CODE
  WHERE sf.ORDER_CODE IS NULL;

  RETURN 'Fact and dimension tables updated successfully in clones!';
END;
$$;

CALL update_fact_and_dim_tables_clone();