-- CSV DATA READ FOR SALES INDIA
CREATE OR REPLACE TABLE sales_in (
                                            Order_ID STRING,
                                            Customer_Name STRING,
                                            Mobile_Model STRING,
                                            Quantity INT,
                                            PricePerUnit INT,
                                            TotalPrice INT,
                                            Promotion_Code STRING,
                                            Order_Amount DECIMAL(10,2),
                                            GST DECIMAL(10,2),
                                            order_date DATE,
                                            payment_status STRING,
                                            shipping_status STRING,
                                            payment_method STRING,
                                            payment_provider STRING,
                                            Mobile BIGINT,
                                            Delivery_Address STRING
                                            );

snowsql -q PUT file://C:\temp\sales\in\order-202001**.csv @Sales.public.%sales_in;

CREATE OR REPLACE FILE FORMAT my_csv_format
                                            TYPE = 'CSV'
                                            FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                            SKIP_HEADER = 1
                                            COMPRESSION = 'GZIP'
                                            DATE_FORMAT = 'YYYY-MM-DD';


COPY INTO sales_in
                                            FROM @Sales.public.%sales_in
                                            FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')
                                            ON_ERROR = 'CONTINUE';

-- JSON DATA READ FOR SALES FRANCE
CREATE OR REPLACE TABLE sales_fr_stage (
                                                data VARIANT
                                            );


snowsql -q PUT file://C:\temp\sales\fr\order-202001**.json @Sales.public.%sales_fr_stage;

CREATE OR REPLACE FILE FORMAT my_json_format
    TYPE = 'JSON';

COPY INTO sales_fr_stage
    FROM @Sales.public.%sales_fr_stage
    FILE_FORMAT = (FORMAT_NAME = 'my_json_format')
    ON_ERROR = 'CONTINUE';


CREATE OR REPLACE TABLE sales_fr (
                                                Order_ID STRING,
                                                Customer_Name STRING,
                                                Mobile_Model STRING,
                                                Quantity INT,
                                                PricePerUnit INT,
                                                TotalPrice INT,
                                                Promotion_Code STRING,
                                                Order_Amount DECIMAL(10,2),
                                                GST DECIMAL(10,2),
                                                order_date DATE,
                                                payment_status STRING,
                                                shipping_status STRING,
                                                payment_method STRING,
                                                payment_provider STRING,
                                                Phone STRING,
                                                Delivery_Address STRING
                                            );

INSERT INTO sales_fr
                                            SELECT
                                                value:"Order ID"::STRING,
                                                value:"Customer Name"::STRING,
                                                value:"Mobile Model"::STRING,
                                                value:"Quantity"::INT,
                                                value:"Price per Unit"::INT,
                                                value:"Total Price"::INT,
                                                value:"Promotion Code"::STRING,
                                                value:"Order Amount"::DECIMAL(10,2),
                                                value:"Tax"::DECIMAL(10,2),
                                                value:"Order Date"::DATE,
                                                value:"Payment Status"::STRING,
                                                value:"Shipping Status"::STRING,
                                                value:"Payment Method"::STRING,
                                                value:"Payment Provider"::STRING,
                                                value:"Phone"::STRING,
                                                value:"Delivery Address"::STRING
                                            FROM sales_fr_stage, LATERAL FLATTEN(input => sales_fr_stage.data);

-- PARQUET DATA READ FOR SALES USA
CREATE OR REPLACE FILE FORMAT my_parquet_format
    TYPE = 'PARQUET'
    COMPRESSION = 'SNAPPY';

CREATE OR REPLACE TABLE sales_us_stage (
                                                data VARIANT
                                            );

snowsql -q PUT file://C:\temp\sales\us\*.parquet @Sales.public.%sales_us_stage;

COPY INTO sales_us_stage
                                            FROM @Sales.public.%sales_us_stage
                                            FILE_FORMAT = (FORMAT_NAME = 'my_parquet_format')
                                            ON_ERROR = 'CONTINUE';

CREATE OR REPLACE TABLE sales_us (
                                                Order_ID STRING,
                                                Customer_Name STRING,
                                                Mobile_Model STRING,
                                                Quantity INT,
                                                PricePerUnit INT,
                                                TotalPrice INT,
                                                Promotion_Code STRING,
                                                Order_Amount DECIMAL(10,2),
                                                Tax DECIMAL(10,2),
                                                Order_Date DATE,
                                                Payment_Status STRING,
                                                Shipping_Status STRING,
                                                Payment_Method STRING,
                                                Payment_Provider STRING,
                                                Phone STRING,
                                                Delivery_Address STRING
                                            );

INSERT INTO sales_us
                                            SELECT
                                                data:"Order ID"::STRING,
                                                data:"Customer Name"::STRING,
                                                data:"Mobile Model"::STRING,
                                                data:"Quantity"::INT,
                                                data:"Price per Unit"::INT,
                                                data:"Total Price"::INT,
                                                data:"Promotion Code"::STRING,
                                                data:"Order Amount"::DECIMAL(10,2),
                                                data:"Tax"::DECIMAL(10,2),
                                                data:"Order Date"::DATE,
                                                data:"Payment Status"::STRING,
                                                data:"Shipping Status"::STRING,
                                                data:"Payment Method"::STRING,
                                                data:"Payment Provider"::STRING,
                                                data:"Phone"::STRING,
                                                data:"Delivery Address"::STRING
                                            FROM sales_us_stage;

-- EXCHANGE RATE TABLE

CREATE OR REPLACE TABLE SALES.PUBLIC.EXCHANGE_RATE (
	EXCHANGE_RATE_DT DATE,
	USD2USD NUMBER(38,0),
	USD2EU NUMBER(6,2),
	USD2INR NUMBER(6,2)
);

snowsql -q PUT file://C:\temp\sales\exchange_rate.csv @Sales.public.%EXCHANGE_RATE;

COPY INTO EXCHANGE_RATE
FROM @Sales.public.%EXCHANGE_RATE
FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')
ON_ERROR = 'CONTINUE';