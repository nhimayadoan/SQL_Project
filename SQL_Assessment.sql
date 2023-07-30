-- Q1 - TBH
/* What is the code for province Thái Bình in the database? */
SELECT code
from dbo.city
where name = N'Thái Bình'

-- Q2 - Hà Tĩnh
/* What province stands for code HTH? */
SELECT name
FROM dbo.city
WHERE code = 'HTH'

-- Q3 - 3
/* What's the postion of Hà Nội in the list of province / city of Đồng bằng sông Hồng? */
select c.name, c.id
from dbo.city c
join dbo.sub_region sr on c.sub_region_id = sr.id
where sr.name = N'Đồng bằng sông Hồng'

-- Calculate the total number of provinces in Vietnam
SELECT COUNT (DISTINCT c.name) AS TotalProvinces
FROM dbo.city c 
JOIN dbo.sub_region sr on c.sub_region_id = sr.id

-- Calculate the number of provinces in "Đồng bằng sông Hồng" and "Đồng bằng sông Cửu Long" areas
WITH ProvincesInAreas AS (
    SELECT COUNT (DISTINCT c.name) AS ProvincesInAreasCount
    FROM dbo.city c 
    JOIN dbo.sub_region sr on c.sub_region_id = sr.id
    WHERE sr.name IN (N'Đồng bằng sông Hồng', N'Đồng bằng sông Cửu Long')
)
SELECT ProvincesInAreasCount, TotalProvinces, 
        (ProvincesInAreasCount * 100.0)/ TotalProvinces AS Percentage
FROM ProvincesInAreas, (
    SELECT COUNT (DISTINCT c.name) AS TotalProvinces
    FROM dbo.city c 
    JOIN dbo.sub_region sr on c.sub_region_id = sr.id
) AS TotalProvinces;

    

-- Q4 - 5
/* How many Provinces have name starts with Quảng? */
select count (distinct name)
from dbo.city
where name like N'Quảng%'


-- Q5 - 38.10%
/* What is Percentage of provinces in area Đồng bằng sông Hồng and Đồng bằng sông Cửu Long compare to total provinces in Vietnam (Rounded to 2 decimal places)? */
-- Calculate the total number of provinces in Vietnam
SELECT COUNT (DISTINCT c.name) AS TotalProvinces
FROM dbo.city c 
JOIN dbo.sub_region sr on c.sub_region_id = sr.id

-- Calculate the number of provinces in "Đồng bằng sông Hồng" and "Đồng bằng sông Cửu Long" areas
WITH ProvincesInAreas AS (
    SELECT COUNT (DISTINCT c.name) AS ProvincesInAreasCount
    FROM dbo.city c 
    JOIN dbo.sub_region sr on c.sub_region_id = sr.id
    WHERE sr.name IN (N'Đồng bằng sông Hồng', N'Đồng bằng sông Cửu Long')
)
SELECT ProvincesInAreasCount, TotalProvinces, 
        (ProvincesInAreasCount * 100.0)/ TotalProvinces AS Percentage
FROM ProvincesInAreas, (
    SELECT COUNT (DISTINCT c.name) AS TotalProvinces
    FROM dbo.city c 
    JOIN dbo.sub_region sr on c.sub_region_id = sr.id
) AS TotalProvinces;


-- Q6 - 19
/* How many provinces in the Middle Area (Miền Trung)? */
select count (c.name)
from dbo.city c 
join dbo.sub_region sr on sr.id = c.sub_region_id
join dbo.region r on r.id = sr.region_id
where r.name = N'Miền Trung'


-- Q7 - Hoàng Mai
/* Which province has the highest number of stores in the whole country? */
SELECT COUNT (s.name) AS NbStores, s.district_id, d.name
FROM dbo.store s 
JOIN dbo.city c on c.id = s.city_id
JOIN dbo.district d on d.id = s.district_id
GROUP BY s.district_id, d.name 
ORDER BY COUNT (s.name) DESC 


-- Q8 - 10
/* How many wards in Hà Nội with more than 10 stores? */
SELECT COUNT (s.name) AS NbStores, s.ward_id, w.name
FROM dbo.store s 
JOIN dbo.city c on c.id = s.city_id
JOIN dbo.district d on d.id = s.district_id
JOIN dbo.ward w on w.id = s.ward_id
WHERE s.city_id = 24
GROUP BY s.ward_id, w.name 
HAVING COUNT (s.name) >= 10 


-- Q9 - Cầu Giấy
/* Which province has the highest ratio of number of stores to number of wards? */
WITH TotalStores AS (
    SELECT district_id, COUNT (id) AS TotalStoresCount
    FROM dbo.store 
    GROUP BY district_id
),
TotalWards AS (
    SELECT district_id, COUNT (id) AS TotalWards
    FROM dbo.ward 
    GROUP BY district_id
)
SELECT d.id, d.name, f.Ratio
FROM dbo.district d
JOIN (
    SELECT s.district_id, TotalStoresCount*1.0/TotalWards AS Ratio 
    FROM TotalStores s
    JOIN TotalWards w 
    ON s.district_id = w.district_id
) f 
ON d.id = f.district_id
ORDER BY Ratio DESC 


-- Q10 - VMHNI466, 735, 92
/* Choose 3 stores neareast to store VMHNI60 ? */
DECLARE @lat1 FLOAT, @long1 FLOAT;
SELECT @lat1 = latitude, @long1 = longitude
FROM dbo.store
WHERE code = 'VMHNI60';
SELECT TOP 3 code, latitude, longitude,
       dbo.fnc_calc_haversine_distance(@lat1, @long1, latitude, longitude) AS distance
FROM dbo.store
WHERE code != 'VMHNI60'
ORDER BY distance;

-- Short Answer

-- Q11
/* Requirement: Get a list of cities and provinces in the North. There is information about domain name, domain code, area name, area code, after id, name, code of province/city. 
 The data table is arranged in alphabetical order by domain name, region name and city name. */

SELECT r.code AS region_code, r.name AS region_name, 
    sr.code AS sub_region_code, sr.name AS sub_region_name, 
    c.id AS city_id, c.code AS city_code, c.name AS city_name
FROM dbo.city c 
JOIN dbo.sub_region sr ON sr.id = c.sub_region_id
JOIN dbo.region r ON r.id = sr.region_id 
WHERE r.code = 'MB'
ORDER BY sub_region_code ASC, region_name ASC, city_name ASC

-- Q12
/* On the occasion of the establishment of the first branch in Hoan Kiem district - Hanoi, the company plans to organize a gratitude event for loyal customers. All customers with total accumulated purchase value (including VAT) from October 1, 2020 to October 20, 2020 at stores in Hoan Kiem district over 10 million VND will receive a purchase voucher 1 million dong. 
Knowing that stores in Hoan Kiem district have district_id=1. 

Requirements: Get a list of customers who are eligible to participate in the above promotion. The required information includes: customer code, full name, customer name, total purchase value. Sort by descending total purchase value and customer name in Alphabetical order. */
select TOP (100) *
from dbo.customer 

select TOP (100) *
from dbo.pos_sales_header

select TOP (100) *
from dbo.pos_sales_line

select TOP (100) *
from dbo.purchase_header

SELECT c.id AS id, c.code AS code, c.full_name AS full_name, c.first_name AS first_name, SUM (h.total_amount) AS total_amount
FROM dbo.customer c
JOIN dbo.pos_sales_header h ON c.id = h.customer_id
JOIN dbo.store s ON s.id = h.store_id
WHERE s.district_id = '1'
AND h.transaction_date >= '2020-10-01' AND h.transaction_date <= '2020-10-20'
GROUP BY c.id, c.code, c.full_name, c.first_name
HAVING SUM (h.total_amount) > 1000000
ORDER BY total_amount DESC, c.full_name ASC


-- Q13 -- CASE WHEN 
/* Every week, the lucky spin program will find 5 lucky orders and refund 50% for order not more than 1 million VND. 
The list of winning orders for the week from August 31, 2020 to September 6, 2020 are orders with the following document_code: 
SO-VMHNI4-202009034389708, SO-VMHNI109-202008316193214, SO-VMHNI51-202008316193066, SO-VMHNI64 -202008316193112, SO-VMHNI48-202009016193491. 

Requirements: Retrieve order information, information of lucky customers and the amount of money the customer is refunded. The required information includes: order code, store code, store name, time of purchase, customer code, full name, customer name, 
order value, customer refund amount again. */

SELECT s.document_code, s.store_id, st.code, st.name, s.transaction_date, c.id, c.full_name,
    c.first_name, SUM (s.total_amount) AS total_amount,
    CASE WHEN 0.5 * SUM (s.total_amount) >= 1000000 THEN 1000000 ELSE 0.5 * SUM (s.total_amount) END AS promotion_amount
FROM dbo.pos_sales_header s 
JOIN dbo.customer c ON c.id = s.customer_id
JOIN dbo.store st ON s.store_id = st.id
WHERE s.transaction_date BETWEEN '2020-08-31' AND '2020-09-06'
AND s.document_code IN ('SO-VMHNI4-202009034389708', 'SO-VMHNI109-202008316193214', 
        'SO-VMHNI51-202008316193066', 'SO-VMHNI64-202008316193112', 'SO-VMHNI48-202009016193491')
GROUP BY c.id, c.full_name, s.document_code, s.store_id, st.code, st.name, s.transaction_date, c.first_name
ORDER BY promotion_amount DESC 


-- Q14
/* Requirements: Summarize sales and average number of products purchased each time a customer buys the product “Cháo Yến Mạch, Chà Là Và Hồ Đào | Herritage Mill, Úc (320 G)” in 2020. Know that the product's sku code is 91. */

SELECT p.id AS product_sku_id, l.customer_id, SUM (l.unit_price * l.quantity) AS purchase_amount,
    SUM (l.quantity) AS quantity, COUNT (*) AS nb_purchases, AVG (l.quantity) AS avg_quantity_per_purchases
FROM dbo.pos_sales_line l 
JOIN dbo.product_sku p ON l.product_sku_id = p.id
WHERE p.name = N'Cháo Yến Mạch, Chà Là Và Hồ Đào | Herritage Mill, Úc (320 G)'
AND YEAR (l.transaction_date) = 2020
GROUP BY l.customer_id, p.id
ORDER BY l.customer_id ASC

-- Q15
/* Requirements: Get a list of the top 20 best-selling instant noodles products in 2019 and 2020. Consider products in the instant food group (sub_category_id=19) and the product name has the word "Mì" or the word "Mỳ". Information returned includes year, product code, product name, country of origin, brand, selling price, quantity sold, sales rating by year. The returned list is sorted by year and by product rating. */

SELECT TOP (20) YEAR (l.transaction_date) AS year, p.id AS product_sku_id, p.code, p.name, p.country, p.brand, l.unit_price, 
    SUM (l.quantity) AS quantity, RANK () OVER (PARTITION BY YEAR (l.transaction_date) ORDER BY SUM (l.unit_price*quantity) DESC) AS rk
FROM dbo.product_sku p 
JOIN dbo.pos_sales_line l ON l.product_sku_id = p.id
JOIN dbo.product_subcategory s ON s.id = p.product_subcategory_id
JOIN dbo.product_category c ON c.id = s.product_category_id
WHERE p.product_subcategory_id = 19
AND YEAR (l.transaction_date) IN ('2019', '2020')
AND (p.name LIKE '%Mì%' OR p.name LIKE '%Mỳ%')
GROUP BY p.id, p.code, p.name, p.country, p.brand, l.unit_price, YEAR (l.transaction_date)
ORDER BY YEAR (l.transaction_date) DESC, rk ASC


-- Q16
/* The store “Cụm 6, Xã Sen Chiểu, Huyện Phúc Thọ, Hà Nội” had customers complaining about the service quality and service attitude of the staff on the afternoon of June 13, 2020.
Requirement: Query information about employees working the afternoon shift on June 13, 2020 at the store. */

SELECT s.day_work, s.store_id, st.name, s.shift_name, s.sales_person_id, p.code, p.full_name, p.first_name, p.gender
FROM dbo.emp_shift_schedule s 
JOIN dbo.sales_person p ON p.id = s.sales_person_id
JOIN dbo.store st ON st.id = s.store_id
WHERE s.shift_name = N'Chiều'
AND st.name = N'VM+ HNI Cụm 6 Xã Sen Chiểu'
AND s.day_work = '2020-06-13'


-- Q17
/* Analyze what time frame customers often come to buy in to coordinate enough staff to serve customers' shopping needs.
Requirements: Query the average number of customers who come to buy at each store per day according to each time frame of the day. Sales data is limited to the last 6 months of 2020. 
Let assume a staff to serve 8 customers / 1 hour, calculate at the peak time, how many employees each store needs. */

WITH cus AS (
    SELECT store_id, hour, AVG(nb_customers) AS avg_nb_customers
    FROM (SELECT CAST (transaction_date as date) as dd, store_id, DATEPART (HOUR, transaction_date) as hour,
            COUNT (distinct customer_id)*1.0 AS nb_customers
        FROM dbo.pos_sales_header
        WHERE CAST (transaction_date as date) BETWEEN '2020-06-01' AND '2020-12-31'
        GROUP BY CAST (transaction_date as date), store_id, DATEPART(HOUR, transaction_date)
    ) f
    GROUP BY store_id, [hour]
) 
SELECT cus.store_id,  s.code, s.name AS store_name, cus.[hour], ROUND (avg_nb_customers,2) AS avg_nb_customers
FROM cus
JOIN dbo.store s ON s.id = cus.store_id
ORDER BY store_id, [hour]


-- Q18
/* Currently, the chain is trading in 4 types of tea products: trà khô, trà túi lọc, trà hòa tan, trà chai. Tea products have sub_category_id=27. Based on the product field can be classified as follows: 
  
- product contains word “trà khô” -> product_type=1
- product contains word “trà túi lọc” -> product_type=2
- product contains word “trà hòa tan” -> product_type=3
- product contains word “trà chai” -> product_type=4

Requirements: Calculate the ratio of sales of trà hòa tan to total sales of tea products in 2018, 2019, 2020. */
SELECT Top (100) *
FROM dbo.product_sku
WHERE product_subcategory_id='27'


WITH ps AS (
    SELECT ps.id AS product_sku_id, ps.code AS product_sku_code, ps.name AS product_sku_name,
        product,
        CASE WHEN LOWER (product) LIKE N'Trà khô%' THEN 1
        WHEN LOWER (product) LIKE N'Trà túi lọc%' THEN 2
        WHEN LOWER (product) LIKE N'Trà hoà tan%' THEN 3
        WHEN LOWER (product) LIKE N'Trà chai%' THEN 4
        END AS product_type 
    FROM dbo.product_sku ps 
    JOIN dbo.product_subcategory sc ON ps.product_subcategory_id = sc.id
    WHERE sc.id = '27'
)
SELECT year, 3 AS product_type, N'Trà hoà tan' AS product_type_name, sales_amount_ht, sales_amount,
    sales_amount_ht*1.0/sales_amount AS ratio 
FROM 
(SELECT YEAR (transaction_date) AS year, 
    SUM (CASE WHEN product_type = 3 THEN line_amount END) AS sales_amount_ht,
    SUM (line_amount) AS sales_amount
FROM dbo.pos_sales_line f 
JOIN ps ON ps.product_sku_id = f.product_sku_id
WHERE YEAR (transaction_date) IN (2018,2019,2020)
GROUP BY YEAR(transaction_date)
) p 




-- Q19
/* Based on sales in 2020, classify products into 3 groups A, B, C (ABC Analysis). Sort products by sales descending. Product group A is the products that account for 70% of total revenue, product group B is the products that account for 20% of total revenue, and product group C is the products that account for the remaining 10% of revenue.

Requirement: Query a list of products categorized by ABC group. Sort by line code and product group code, sales descending. */

WITH total_sales AS 
(
    SELECT SUM (line_amount) AS TotalSales 
    FROM dbo.pos_sales_line
    WHERE YEAR (transaction_date) = '2020'
)
SELECT YEAR (l.transaction_date) AS year, p.product_category_id, c.name AS product_category_name, 
    p.product_subcategory_id, s.name AS product_subcategory_name, p.id AS product_sku_id, p.name AS product_sku_name,
    SUM (l.line_amount) AS sales_amount,
    CASE WHEN SUM (l.line_amount)/(SELECT TotalSales FROM total_sales) >= 0.7 THEN 'A'
    WHEN SUM (l.line_amount)/(SELECT TotalSales FROM total_sales) >= 0.2 THEN 'B'
    ELSE 'C'
    END AS type 
FROM dbo.product_sku p 
JOIN dbo.pos_sales_line l ON l.product_sku_id = p.id 
JOIN dbo.product_category c ON p.product_category_id = c.id 
JOIN dbo.product_subcategory s ON s.id = p.product_subcategory_id
WHERE YEAR (l.transaction_date) = '2020'
GROUP BY YEAR (l.transaction_date), p.product_category_id, c.name, p.product_subcategory_id, s.name, p.id, p.name
ORDER BY SUM (l.line_amount) DESC

WITH r AS (
    SELECT year, product_sku_id, sales_amount,
        SUM (sales_amount) OVER (PARTITION BY r.year ORDER BY sales_amount DESC) AS running_total,
        SUM (sales_amount) OVER (PARTITION BY r.year) AS year_total 
    FROM 
    (SELECT YEAR(transaction_date) AS year, product_sku_id, SUM (line_amount) AS sales_amount
    FROM dbo.pos_sales_line
    WHERE YEAR (transaction_date) = '2020'
    GROUP BY YEAR(transaction_date), product_sku_id
    ) r
), dm AS (
    SELECT ps.id AS product_sku_id, ps.code AS product_sku_code, ps.name AS product_sku_name,
    sc.id AS product_subcategory_id, sc.code AS product_subcategory_code,
    sc.name AS product_subcategory_name, pc.id AS product_category_id, 
    pc.code AS product_category_code, pc.name AS product_category_name
    FROM dbo.product_sku ps 
    JOIN dbo.product_subcategory sc ON ps.product_subcategory_id = sc.id
    JOIN dbo.product_category pc ON pc.id = sc.product_category_id
)
SELECT [year], product_category_id, product_category_name, product_subcategory_id,
    product_subcategory_name, r.product_sku_id, product_sku_name, sales_amount,
    CASE WHEN p<70 THEN 'A'
    WHEN p<90 THEN 'B'
    ELSE 'C' END AS type 
FROM (
    SELECT r.*, running_total/year_total*100 AS p 
    FROM r
) r 
JOIN dm on r.product_sku_id = dm.product_sku_id
ORDER BY r.[year], product_category_id, product_subcategory_id, product_sku_id


-- Q20
/* Requirement: Get the TOP 3 stores by sales in Hanoi to award the store of the month of October 2020. Know that stores in Hanoi have city_id=24. */

SELECT TOP (3) h.store_id, s.code AS store_code, s.name AS store_name, SUM (h.total_line_amount) AS sales_amount_10_2020
FROM dbo.store s 
JOIN dbo.pos_sales_header h ON s.id = h.store_id
WHERE h.transaction_date BETWEEN '2020-10-01' AND '2020-10-31'
AND s.city_id = 24
GROUP BY h.store_id, s.code, s.name 
ORDER BY sales_amount_10_2020 DESC 
