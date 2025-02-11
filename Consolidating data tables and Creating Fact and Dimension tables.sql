-- CREATE CONSOLIDATED DATA TABLE

CREATE OR REPLACE TABLE consolidated_sales (
  Order_ID STRING,
  Customer_Name STRING,
  Mobile_Model STRING,
  Quantity INT,
  PricePerUnit_usd DECIMAL(10,2),
  TotalPrice_usd DECIMAL(10,2),
  Promotion_Code STRING,
  Order_Amount_usd DECIMAL(10,2),
  GST_usd DECIMAL(10,2),
  order_date DATE,
  payment_status STRING,
  shipping_status STRING,
  payment_method STRING,
  payment_provider STRING,
  Mobile STRING,
  Delivery_Address STRING,
  Country STRING,
  Region STRING
);

-- INDIAN DATA ADDITION TO CONSOLIDATED TABLE

INSERT INTO consolidated_sales (
  Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit_usd, TotalPrice_usd, 
  Promotion_Code, Order_Amount_usd, GST_usd, order_date, payment_status, shipping_status, 
  payment_method, payment_provider, Mobile, Delivery_Address, Country, Region
)
SELECT 
  si.Order_ID,
  si.Customer_Name,
  si.Mobile_Model,
  si.Quantity,
  si.PricePerUnit / er.usd2inr AS PricePerUnit_usd,
  si.TotalPrice / er.usd2inr AS TotalPrice_usd,
  si.Promotion_Code,
  si.Order_Amount / er.usd2inr AS Order_Amount_usd,
  si.GST / er.usd2inr AS GST_usd,
  si.order_date,
  si.payment_status,
  si.shipping_status,
  si.payment_method,
  si.payment_provider,
  si.Mobile,
  si.Delivery_Address,
  si.country,
  si.region
FROM 
  sales_in si
JOIN 
  exchange_rate er
ON 
  si.order_date = er.exchange_rate_dt;

-- ADDING FRANCE DATA TO CONSOLIDATED TABLE
INSERT INTO consolidated_sales (
  Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit_usd, TotalPrice_usd, 
  Promotion_Code, Order_Amount_usd, GST_usd, order_date, payment_status, shipping_status, 
  payment_method, payment_provider, Mobile, Delivery_Address, Country, Region
)
SELECT 
  sf.Order_ID,
  sf.Customer_Name,
  sf.Mobile_Model,
  sf.Quantity,
  sf.PricePerUnit / er.usd2eu AS PricePerUnit_usd,
  sf.TotalPrice / er.usd2eu AS TotalPrice_usd,
  sf.Promotion_Code,
  sf.Order_Amount / er.usd2eu AS Order_Amount_usd,
  sf.GST / er.usd2eu AS GST_usd,
  sf.order_date,
  sf.payment_status,
  sf.shipping_status,
  sf.payment_method,
  sf.payment_provider,
  sf.Phone,
  sf.Delivery_Address,
  sf.country,
  sf.region
FROM 
  sales_fr sf
JOIN 
  exchange_rate er
ON 
  sf.order_date = er.exchange_rate_dt;

-- ADDING USA DATA TO CONSOLIDATED TABLE

INSERT INTO consolidated_sales (
  Order_ID, Customer_Name, Mobile_Model, Quantity, PricePerUnit_usd, TotalPrice_usd, 
  Promotion_Code, Order_Amount_usd, GST_usd, order_date, payment_status, shipping_status, 
  payment_method, payment_provider, Mobile, Delivery_Address, Country, Region
)
SELECT 
  su.Order_ID,
  su.Customer_Name,
  su.Mobile_Model,
  su.Quantity,
  su.PricePerUnit AS PricePerUnit_usd,
  su.TotalPrice AS TotalPrice_usd,
  su.Promotion_Code,
  su.Order_Amount AS Order_Amount_usd,
  su.Tax AS GST_usd,
  su.order_date,
  su.payment_status,
  su.shipping_status,
  su.payment_method,
  su.payment_provider,
  su.Phone,
  su.Delivery_Address,
  su.country,
  su.region
FROM 
  sales_us su;

-- CREATING and FILLING DIMENSION TABLES

-- customer dim
CREATE OR REPLACE TABLE CUSTOMER_DIM (
  CUSTOMER_ID INT AUTOINCREMENT PRIMARY KEY,
  CUSTOMER_NAME STRING,
  CONTACT_NO STRING,
  SHIPPING_ADDRESS STRING
);

INSERT INTO CUSTOMER_DIM (CUSTOMER_NAME, CONTACT_NO, SHIPPING_ADDRESS)
SELECT DISTINCT 
  Customer_Name,
  Mobile,
  Delivery_Address
FROM consolidated_sales;

-- date dim
CREATE OR REPLACE TABLE DATE_DIM (
  DATE_ID INT AUTOINCREMENT PRIMARY KEY,
  ORDER_DT DATE,
  ORDER_YEAR INT,
  ORDER_MONTH INT,
  ORDER_DAY INT,
  ORDER_QUARTER INT,
  ORDER_DAYOFWEEK INT,
  ORDER_DAYNAME STRING,
  ORDER_DAYOFMONTH INT,
);

INSERT INTO DATE_DIM (ORDER_DT, ORDER_YEAR, ORDER_MONTH, ORDER_DAY, ORDER_QUARTER, ORDER_DAYOFWEEK, ORDER_DAYNAME, ORDER_DAYOFMONTH)
SELECT DISTINCT 
  order_date,
  YEAR(order_date) AS ORDER_YEAR,
  MONTH(order_date) AS ORDER_MONTH,
  DAY(order_date) AS ORDER_DAY,
  QUARTER(order_date) AS ORDER_QUARTER,
  DAYOFWEEK(order_date) AS ORDER_DAYOFWEEK,
  DAYNAME(order_date) AS ORDER_DAYNAME,
  DAYOFMONTH(order_date) AS ORDER_DAYOFMONTH,
FROM consolidated_sales;

--payment dim
CREATE OR REPLACE TABLE PAYMENT_DIM (
  PAYMENT_ID INT AUTOINCREMENT PRIMARY KEY,
  PAYMENT_METHOD STRING,
  PAYMENT_PROVIDER STRING
);

INSERT INTO PAYMENT_DIM (PAYMENT_METHOD, PAYMENT_PROVIDER)
SELECT DISTINCT 
  payment_method,
  payment_provider
FROM consolidated_sales;

--product dim
CREATE OR REPLACE TABLE PRODUCT_DIM (
  PRODUCT_ID INT AUTOINCREMENT PRIMARY KEY,
  MOBILE_MODEL STRING
);

INSERT INTO PRODUCT_DIM (MOBILE_MODEL)
SELECT DISTINCT 
  Mobile_Model
FROM consolidated_sales;

--promo code dim
CREATE OR REPLACE TABLE PROMO_CODE_DIM (
  PROMO_CODE_ID INT AUTOINCREMENT PRIMARY KEY,
  PROMOTION_CODE STRING
);

INSERT INTO PROMO_CODE_DIM (PROMOTION_CODE)
SELECT DISTINCT 
  Promotion_Code
FROM consolidated_sales;

--region dim
CREATE OR REPLACE TABLE REGION_DIM (
  REGION_ID INT AUTOINCREMENT PRIMARY KEY,
  COUNTRY STRING,
  REGION STRING
);

INSERT INTO REGION_DIM (COUNTRY, REGION)
SELECT DISTINCT 
  Country,
  Region
FROM consolidated_sales;

-- CREATING AND POPULATING FACT TABLE

CREATE OR REPLACE TABLE SALES_FACT (
  ORDER_ID INT AUTOINCREMENT PRIMARY KEY,
  ORDER_CODE STRING,
  DATE_ID INT,
  REGION_ID INT,
  CUSTOMER_ID INT,
  PRODUCT_ID INT,
  PAYMENT_ID INT,
  PROMO_CODE_ID INT,
  ORDER_QUANTITY INT,
  TOTAL_ORDER_AMT DECIMAL(10,2),
  TAX_AMT DECIMAL(10,2),
  FOREIGN KEY (DATE_ID) REFERENCES DATE_DIM(DATE_ID),
  FOREIGN KEY (REGION_ID) REFERENCES REGION_DIM(REGION_ID),
  FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER_DIM(CUSTOMER_ID),
  FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT_DIM(PRODUCT_ID),
  FOREIGN KEY (PAYMENT_ID) REFERENCES PAYMENT_DIM(PAYMENT_ID),
  FOREIGN KEY (PROMO_CODE_ID) REFERENCES PROMO_CODE_DIM(PROMO_CODE_ID)
);


INSERT INTO SALES_FACT (
  ORDER_CODE, DATE_ID, REGION_ID, CUSTOMER_ID, PRODUCT_ID, PAYMENT_ID, PROMO_CODE_ID, 
  ORDER_QUANTITY, LOCAL_TOTAL_ORDER_AMT, LOCAL_TAX_AMT, EXCHANGE_RATE, US_TOTAL_ORDER_AMT, USD_TAX_AMT
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
  cs.GST_usd,
FROM 
  consolidated_sales cs
JOIN 
  exchange_rate er ON cs.order_date = er.exchange_rate_dt
JOIN 
  DATE_DIM d ON cs.order_date = d.ORDER_DT
JOIN 
  CUSTOMER_DIM c ON cs.Customer_Name = c.CUSTOMER_NAME AND cs.Mobile = c.CONTACT_NO
JOIN 
  REGION_DIM r ON cs.country = r.COUNTRY AND cs.region = r.REGION
JOIN 
  PRODUCT_DIM p ON cs.Mobile_Model = p.MOBILE_MODEL
JOIN 
  PAYMENT_DIM pay ON cs.payment_method = pay.PAYMENT_METHOD AND cs.payment_provider = pay.PAYMENT_PROVIDER
JOIN 
  PROMO_CODE_DIM pc ON cs.Promotion_Code = pc.PROMOTION_CODE;