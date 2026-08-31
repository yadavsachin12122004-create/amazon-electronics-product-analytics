USE amazon_electronics;

DROP TABLE IF EXISTS electronics_clean;

CREATE TABLE electronics_clean AS
SELECT
    name,
    ratings,
    no_of_ratings,
    discount_price,
    REGEXP_SUBSTR(actual_price, '₹[0-9,]+') AS actual_price
FROM electronics;
SELECT *
FROM electronics_clean
LIMIT 10;
USE amazon_electronics;

DROP TABLE IF EXISTS electronics_final;

CREATE TABLE electronics_final AS
SELECT
    name,
    ratings,
    no_of_ratings,

    CAST(
        REPLACE(
            REPLACE(discount_price, '₹', ''),
            ',', ''
        ) AS DECIMAL(10,2)
    ) AS selling_price,

    CAST(
        REPLACE(
            REPLACE(actual_price, '₹', ''),
            ',', ''
        ) AS DECIMAL(10,2)
    ) AS original_price

FROM electronics_clean;
SELECT *
FROM electronics_final
LIMIT 10;
USE amazon_electronics;

DROP TABLE IF EXISTS electronics_final;

CREATE TABLE electronics_final AS
SELECT
    name,
    ratings,
    no_of_ratings,

    CAST(
        REPLACE(
            REPLACE(discount_price, '₹', ''),
            ',', ''
        ) AS DECIMAL(10,2)
    ) AS discount_price,

    CAST(
        REPLACE(
            REPLACE(actual_price, '₹', ''),
            ',', ''
        ) AS DECIMAL(10,2)
    ) AS actual_price

FROM electronics_clean;
SELECT COUNT(*) AS total_products
FROM electronics_final;
SELECT
    SUM(name IS NULL OR name = '') AS missing_name,
    SUM(ratings IS NULL) AS missing_ratings,
    SUM(no_of_ratings IS NULL) AS missing_reviews,
    SUM(discount_price IS NULL) AS missing_discount_price,
    SUM(actual_price IS NULL) AS missing_actual_price
FROM electronics_final;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT name) AS unique_products
FROM electronics_final;
SELECT
    name,
    ratings,
    no_of_ratings,
    discount_price,
    actual_price,
    COUNT(*) AS duplicate_count
FROM electronics_final
GROUP BY
    name,
    ratings,
    no_of_ratings,
    discount_price,
    actual_price
HAVING COUNT(*) > 1;
DROP TABLE IF EXISTS electronics_cleaned;
CREATE TABLE electronics_cleaned AS
SELECT DISTINCT
    name,
    ratings,
    no_of_ratings,
    discount_price,
    actual_price
FROM electronics_final;
SELECT COUNT(*) AS total_rows
FROM electronics_cleaned;
SELECT
    name,
    ratings,
    no_of_ratings,
    discount_price,
    actual_price,
    COUNT(*) AS duplicate_count
FROM electronics_cleaned
GROUP BY
    name,
    ratings,
    no_of_ratings,
    discount_price,
    actual_price
HAVING COUNT(*) > 1;
SELECT COUNT(*) AS total_rows
FROM electronics_cleaned;
SELECT
    SUM(discount_price <= 0) AS invalid_discount_price,
    SUM(actual_price <= 0) AS invalid_actual_price
FROM electronics_final;
SELECT
    MIN(ratings) AS minimum_rating,
    MAX(ratings) AS maximum_rating,
    AVG(ratings) AS average_rating
FROM electronics_final;
SELECT
    MIN(no_of_ratings) AS minimum_ratings_count,
    MAX(no_of_ratings) AS maximum_ratings_count,
    AVG(no_of_ratings) AS average_ratings_count
FROM electronics_final;
SELECT
    SUM(no_of_ratings <= 0) AS invalid_ratings_count
FROM electronics_final;
ALTER TABLE electronics_final
ADD COLUMN discount_percent DECIMAL(5,2);
SELECT
    name,
    discount_price,
    actual_price,
    ROUND(
        ((actual_price - discount_price) / actual_price) * 100,
        2
    ) AS discount_percent
FROM electronics_final
LIMIT 10;
SELECT
    ROUND(MIN(
        ((actual_price - discount_price) / actual_price) * 100
    ), 2) AS minimum_discount,

    ROUND(MAX(
        ((actual_price - discount_price) / actual_price) * 100
    ), 2) AS maximum_discount,

    ROUND(AVG(
        ((actual_price - discount_price) / actual_price) * 100
    ), 2) AS average_discount
FROM electronics_final
WHERE actual_price > 0;
SELECT
    name,
    discount_price,
    actual_price,
    ROUND(
        ((actual_price - discount_price) / actual_price) * 100,
        2
    ) AS discount_percent
FROM electronics_final
LIMIT 10;
ALTER TABLE electronics_final
ADD COLUMN product_category VARCHAR(50);
UPDATE electronics_final
SET product_category =
    CASE
        WHEN LOWER(name) REGEXP 'laptop|notebook|macbook|chromebook'
            THEN 'Laptop'

        WHEN LOWER(name) REGEXP 'mobile|smartphone|iphone|galaxy|redmi|poco|oneplus|realme|oppo|vivo|pixel'
            THEN 'Mobile Phone'

        WHEN LOWER(name) REGEXP 'earbud|airpod|tws|airdopes'
            THEN 'Earbuds'

        WHEN LOWER(name) REGEXP 'headphone|headset'
            THEN 'Headphones'

        WHEN LOWER(name) REGEXP 'speaker|soundbar'
            THEN 'Speakers'

        WHEN LOWER(name) REGEXP 'television|smart tv|tv '
            THEN 'Television'

        WHEN LOWER(name) REGEXP 'tablet|ipad'
            THEN 'Tablet'

        WHEN LOWER(name) REGEXP 'camera|dslr|mirrorless|camcorder'
            THEN 'Camera'

        WHEN LOWER(name) REGEXP 'monitor|display'
            THEN 'Monitor'

        WHEN LOWER(name) REGEXP 'smartwatch|smart watch'
            THEN 'Smartwatch'

        WHEN LOWER(name) REGEXP 'printer|scanner'
            THEN 'Printer'

        WHEN LOWER(name) REGEXP 'router|modem|wifi|wi-fi'
            THEN 'Networking'

        WHEN LOWER(name) REGEXP 'keyboard|mouse|webcam|charger|adapter|power bank'
            THEN 'Accessories'

        ELSE 'Other'
    END;
    SELECT
    product_category,
    COUNT(*) AS total_products
FROM electronics_final
GROUP BY product_category
ORDER BY total_products DESC;
ALTER TABLE electronics_final
ADD COLUMN price_segment VARCHAR(30);
UPDATE electronics_final
SET price_segment =
    CASE
        WHEN discount_price < 1000 THEN 'Budget'
        WHEN discount_price < 5000 THEN 'Economy'
        WHEN discount_price < 20000 THEN 'Mid Range'
        WHEN discount_price < 50000 THEN 'Premium'
        ELSE 'Luxury'
    END;
    SELECT
    price_segment,
    COUNT(*) AS total_products,
    ROUND(AVG(discount_price), 2) AS average_price
FROM electronics_final
GROUP BY price_segment
ORDER BY average_price;
ALTER TABLE electronics_final
ADD COLUMN rating_segment VARCHAR(30);
UPDATE electronics_final
SET rating_segment =
    CASE
        WHEN ratings >= 4.5 THEN 'Excellent'
        WHEN ratings >= 4.0 THEN 'Good'
        WHEN ratings >= 3.0 THEN 'Average'
        ELSE 'Poor'
    END;
    SELECT
    rating_segment,
    COUNT(*) AS total_products,
    ROUND(AVG(ratings), 2) AS average_rating
FROM electronics_final
GROUP BY rating_segment
ORDER BY average_rating DESC;
DESCRIBE electronics_final;
UPDATE electronics_final
SET no_of_ratings = REPLACE(no_of_ratings, ',', '');
ALTER TABLE electronics_final
MODIFY COLUMN no_of_ratings INT;
SELECT
    no_of_ratings
FROM electronics_final
LIMIT 20;
ALTER TABLE electronics_final
ADD COLUMN popularity_segment VARCHAR(30);
UPDATE electronics_final
SET popularity_segment =
    CASE
        WHEN no_of_ratings >= 10000 THEN 'Very Popular'
        WHEN no_of_ratings >= 5000 THEN 'Popular'
        WHEN no_of_ratings >= 1000 THEN 'Moderate'
        ELSE 'Low'
    END;
    SELECT
    popularity_segment,
    COUNT(*) AS total_products,
    SUM(no_of_ratings) AS total_ratings
FROM electronics_final
GROUP BY popularity_segment
ORDER BY total_ratings DESC;
DESCRIBE electronics_final;
SELECT COUNT(*) AS total_products
FROM electronics_final;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT name) AS unique_product_names
FROM electronics_final;
SELECT
    name,
    ratings,
    no_of_ratings,
    discount_price,
    actual_price,
    COUNT(*) AS duplicate_count
FROM electronics_final
GROUP BY
    name,
    ratings,
    no_of_ratings,
    discount_price,
    actual_price
HAVING COUNT(*) > 1;
SELECT *
FROM electronics_final;
SHOW VARIABLES LIKE 'secure_file_priv';
SELECT 'name',
       'ratings',
       'no_of_ratings',
       'discount_price',
       'actual_price',
       'product_category',
       'price_segment',
       'rating_segment',
       'popularity_segment'
UNION ALL
SELECT name,
       ratings,
       no_of_ratings,
       discount_price,
       actual_price,
       product_category,
       price_segment,
       rating_segment,
       popularity_segment
FROM electronics_final
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/electronics_final.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

