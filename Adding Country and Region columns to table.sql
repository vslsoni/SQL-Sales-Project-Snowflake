ALTER TABLE sales_in ADD COLUMN country STRING;
ALTER TABLE sales_in ADD COLUMN region STRING;

UPDATE sales_in
SET country = 'India',
    region = 'Asia';

ALTER TABLE sales_fr ADD COLUMN country STRING;
ALTER TABLE sales_fr ADD COLUMN region STRING;

UPDATE sales_fr
SET country = 'France',
    region = 'Europe';

ALTER TABLE sales_us ADD COLUMN country STRING;
ALTER TABLE sales_us ADD COLUMN region STRING;

UPDATE sales_us
SET country = 'USA',
    region = 'North America';